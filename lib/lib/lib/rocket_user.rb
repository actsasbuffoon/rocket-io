class Rocket
  
  @@connected_users = {}
  
  def add_local_user(id, user)
    @@connected_users[id.to_s.to_sym] = user
  end
  
  def remove_local_user(id)
    @@connected_users.delete id.to_s.to_sym
  end
  
  def get_local_user(id)
    @@connected_users[id.to_s.to_sym]
  end
  
  class RocketUser
    
    attr_accessor :server, :id, :web_socket, :web_socket_id
    
    def local?
      ROCKET.server_id.to_s == @server.to_s
    end
    
    def initialize(args = {})
      args.each_pair do |k, v|
        send "#{k}=", v
      end
    end
    
    def self.find(id, &blk)
      r = ROCKET.redis.hget("rocket_users", id)
      r = JSON.parse(r)
      user = self.new(r.merge id: id, server: r.delete("server_id"), web_socket_id: r.delete("websocket_id"))
      user = Rocket.get_local_user(user.web_socket_id) if user.local?
      blk.call(user)
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