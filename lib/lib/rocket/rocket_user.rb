# This is the class that deals with connected clients. This should probably
# be renamed to client rather than user.
class Rocket
  
  # Stores all connected clients in a hash with their ID as the key.
  @@connected_users = {}
  
  # Adds a client to the hash.
  def add_local_user(id, user)
    @@connected_users[id.to_s.to_sym] = user
  end
  
  # Removes a client from the hash.
  def remove_local_user(id)
    @@connected_users.delete id.to_s.to_sym
  end
  
  # Finds a local user.
  def get_local_user(id)
    @@connected_users[id.to_s.to_sym]
  end
  
  class RocketUser
    
    attr_accessor :server, :id, :web_socket, :web_socket_id
    
    # Determines whether or not this server is the one managing a given client's connection.
    def local?
      ROCKET.server_id.to_s == @server.to_s
    end
    
    # Creates a new client taking a hash of attributes. The valid attributes are:
    # * server
    # * id
    # * web_socket
    # * web_socket_id
    def initialize(args = {})
      args.each_pair do |k, v|
        send "#{k}=", v
      end
    end
    
    # Allows you to call RocketUser.find(client_id)
    def self.find(id)
      r = ROCKET.redis.hget("rocket_users", id)
      r = JSON.parse(r)
      user = self.new(r.merge id: id, server: r.delete("server_id"), web_socket_id: r.delete("websocket_id"))
      user = Rocket.get_local_user(user.web_socket_id) if user.local?
    end
    
    def self.create(socket)
      @id = ROCKET.redis.incr "user_ids"
      @server = ROCKET.server_id
      ROCKET.add_local_user(socket.signature, RocketUser.new(server: @server, id: @id, web_socket: socket, web_socket_id: socket.signature))
      ROCKET.redis.hset "rocket_users", @id.to_s, {server_id: @server, websocket_id: socket.signature}.to_json
    end
    
    def transmit(args = {})
      puts "Calling RocketUser.transmit"
      if local?
        puts "User is local"
        @web_socket.send args.to_json
      else
        puts "User is remote"
        args.merge! :rocket_user_id => @id
        ROCKET.redis.rpush("message_queue_#{ROCKET.server_id}", args.to_json)
      end
    end
    
  end
end