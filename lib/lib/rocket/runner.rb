# The main application loop.
class Rocket
  
  attr_accessor :redis, :redis_message_queue_connection, :server_id
  
  # Show errors along with a backtrace in the event of an error happening in a controller action.
  def show_error(ex)
    puts "ERROR: #{$!}"
    puts "#{ex.message}\n#{ex.class}"
    puts "#{ex.backtrace.join "\n"}"
  end
  
  # This is a really simple processing queue that is pretty much a miniature implementation of
  # pub/sub. It is primarily used if a user is unavailable when the server tries to send a
  # message to them. This is all automatic, so you shouldn't have to worry about it.
  #
  # The whole thing is built on Redis's blpop operation, which is a blocking pop.
  # Normally blpop would watch a given key and block until a value is put into the list. Once
  # something goes into the list, it pops the value from the list and returns it. However,
  # since Rocket is completely event driven, it only blocks this particular Redis connection.
  # It may sound strange, but if you spend a few minutes looking at it, you'll realize it's
  # just leveraging events to recreate pub/sub in 20 lines of Ruby.
  #
  # Yes, I'm aware Redis supports pub/sub already, but I've had people ask if it would be possible
  # to use something other than Redis for this purpose. While that's not the case yet, I'd rather
  # not tie myself down to Redis's pub/sub just in case.
  def process_message_queue
    # Wrapped in a fiber to support Synchrony.
    Fiber.new {
      # Wrapped in a begin/rescue block to keep going if there's an error in a controller action.
      begin
        message = @redis_message_queue_connection.blpop("message_queue_#{@server_id}", 0)
        message = JSON.parse(message[1])
        user_id = message.delete "rocket_user_id"
        user = RocketUser.find(user_id)
        # Transmit to the user if possible, if not then put the message back in the queue.
        if user && user.web_socket
          transmit(user, message)
          process_message_queue
        else
          message.merge! :rocket_user_id => user_id
          ROCKET.redis.rpush("message_queue_#{ROCKET.server_id}", message.to_json)
          process_message_queue
        end
      rescue => ex
        show_error ex
      end
    }.resume
  end
  
  # Send the message to the client via a web socket connection.
  def transmit(user, message)
    if user
      user.web_socket.send message.to_json
    end
  end
  
  # Pass the args along to the controller action.
  def process_command(user, controller, command, args)
    @@controllers[controller].new.process_command(user, command, args)
  end
  
  # Set up Async Sinatra to serve static files.
  class StaticController < Sinatra::Base
    register Sinatra::Async
    set :root, APP_ROOT
    set :static, true
    set :public, File.join(APP_ROOT, "public")
  end
  
  # Parse the API commands. Takes {"Song.show" => {id: 1}} and calls the show action on the
  # song controller, passing along the hash as an argument.
  def parse_command(user, msg)
    if msg.class == Array
      msg.each do |m|
        m.each_pair do |k, v|
          controller, mthd = *k.split(".")
          process_command user, controller.to_sym, mthd, v
        end
      end
    elsif msg.class == Hash
      msg.each_pair do |k, v|
        controller, mthd = *k.split(".")
        process_command user, controller.to_sym, mthd, v
      end
    end
  end
  
  # The loop where everything happens.
  def run
    EventMachine.synchrony do
      
      # Call any initializers. It seems a little funny to hold off on this until we
      # get this far in, but initializing a DB connection outside the event loop
      # will throw an error.
      Dir[File.join APP_ROOT, "config", "initializers", "*.rb"].each do |file|
        require file
      end
      
      # Create two Redis connections; one for dealing with clients, and another for
      # handling the processing queue.
      @redis = EM::Protocols::Redis.connect
      @redis_message_queue_connection = EM::Protocols::Redis.connect
      
      # The server gets a unique ID from Redis so other servers can identify it. This
      # becomes useful when trying to communicate with a client connected to another
      # server.
      @server_id = @redis.incr "server_ids"
      
      # Start the message processing queue.
      process_message_queue
      
      # Start the web socket listener.
      EventMachine::WebSocket.start(host: "0.0.0.0", port: 9185) do |ws|
        
        # Create a new client. Perhaps we should provide a callback here.
        ws.onopen do
          Fiber.new {RocketUser.create(ws)}.resume
        end
        
        # We don't do anything here yet, but we should probably provide a callback and
        # clean the disconnected user out of the database.
        ws.onclose do
          
        end
        
        # Deals with incoming messages. We should probably provide a callback.
        ws.onmessage do |json_msg|
          # Wrapped in a fiber for Synchrony.
          Fiber.new {
            # In a begin block to keep going if there's an error in a controller action.
            begin
              # Grab the user and deal with their input.
              user = get_local_user(ws.signature)
              if user
                msg = JSON.parse(json_msg)
                parse_command(user, msg)
              end
            rescue => ex
              show_error ex
            end
          }.resume
        end
      end
      
      # Run Async Sinatra.
      Rack::Handler::Thin.run StaticController, Port: 9346
    end
  end
end