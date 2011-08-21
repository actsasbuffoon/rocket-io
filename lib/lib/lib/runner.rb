class Rocket
  
  attr_accessor :redis, :redis_message_queue_connection, :server_id, :mongo
  
  def show_error(ex)
    puts "ERROR: #{$!}"
    puts "#{ex.message}\n#{ex.class}"
    puts "#{ex.backtrace.join "\n"}"
  end
  
  def process_message_queue
    Fiber.new {
      begin
        message = @redis_message_queue_connection.blpop("message_queue_#{@server_id}", 0)
        message = JSON.parse(message[1])
        user_id = message.delete "rocket_user_id"
        RocketUser.find(user_id) do |user|
          if user && user.web_socket
            transmit(user, message)
            process_message_queue
          else
            message.merge! :rocket_user_id => user_id
            ROCKET.redis.rpush("message_queue_#{ROCKET.server_id}", message.to_json)
            process_message_queue
          end
        end
      rescue => ex
        show_error ex
      end
    }.resume
  end
  
  def transmit(user, message)
    if user
      user.web_socket.send message.to_json
    end
  end
  
  def process_command(user, controller, command, args)
    @@controllers[controller].new.process_command(user, command, args)
  end
  
  class StaticController < Sinatra::Base
    register Sinatra::Async
    set :root, APP_ROOT
    set :static, true
    set :public, File.join(APP_ROOT, "public")
  end
  
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
  
  def run
    EventMachine.synchrony do
      
      Dir[File.join APP_ROOT, "config", "initializers", "*.rb"].each do |file|
        require file
      end
      
      @redis = EM::Protocols::Redis.connect
      @redis_message_queue_connection = EM::Protocols::Redis.connect
      
      @server_id = @redis.incr "server_ids"
      process_message_queue
      
      EventMachine::WebSocket.start(host: "0.0.0.0", port: 9185) do |ws|
        ws.onopen do
          Fiber.new {RocketUser.create(ws)}.resume
        end
        
        ws.onclose do
          
        end
        
        ws.onmessage do |json_msg|
          Fiber.new {
            begin
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
      
      Rack::Handler::Thin.run StaticController, Port: 9346
    end
  end
end