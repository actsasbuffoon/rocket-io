# This file is where everything related to controllers is written.
require "base64"

class Rocket
  
  # We use a class variable on the Rocket class to hold a hash of all controllers.
  @@controllers = {}

  def self.controllers
    @@controllers
  end
  
  module Controller
    
    # This callback adds the new class to the controller hash. It strips "Controller" off
    # the end of the class name in order to simplify the API. This way you can call
    # "rocket('User.Show': {id: 1})" rather than "rocket('UserController.Show': {id: 1})".
    # It also sets up an attr_accessor for args, params, and current_user.
    def self.bolted(other)
      Rocket.controllers[other.to_s.sub(/Controller$/, "").to_sym] = other
      other.send :attr_accessor, :args, :params, :current_user
    end
    
    module ClassMethods
      # This is how actions are defined. As you can see, it's incredibly simple. Just take the
      # block and put it into the actions class instance variable. Note that @action is not an
      # instance variable on the object, but an instance variable on the class.
      #
      # Everything is a class in Ruby, including classes. Since all objects can have instance
      # variables, and classes are objects, classes can have instance variables. Make sense?
      # If not, check out this great post by John Nunemaker:
      # [http://railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/](http://railstips.org/blog/archives/2006/11/18/class-and-instance-variables-in-ruby/)
      def define_action(name, &blk)
        @actions ||= {}
        @actions[name.to_sym] = blk
      end
      
      # Allows you to access the class instance variable, which is tricky otherwise.
      def actions
        @actions
      end
      
      # This is a controller helper that sets you with with a "File First" upload.
      # It defines two controller actions for the user. Note that the "Simple Upload"
      # does not need a controller action, as everything happens client side.
      def file_first(name, &blk)
        # The first action creates a tempfile and gives the client an ID to reference
        # it by. Since a client could upload multiple files simultaneously, this is
        # necessary.
        define_action "#{name}_request_tempfile".to_sym do
          id = "#{self.class.to_s}_#{name}_#{Time.now.to_i.to_s}_#{rand(9999999).to_s}"
          File.open(File.join(APP_ROOT, "tmp", id), "w") {|f| f.write ""}
          current_user.transmit("App.tempfile" => {id: id, req_id: params["req_id"]})
        end
        
        # The second action receives the base64 encoded file chunks, decodes them, and
        # writes them to the temp file. Once the upload is complete, it sends a callback
        # to the user to let them know the file is ready.
        define_action "#{name}_receive_file".to_sym do
          File.open(File.join(APP_ROOT, "tmp", params["id"]), "ab") {|f| f.write Base64.decode64(params["chunk"])}
          if params["complete"]
            current_user.transmit({"App.finished_upload" => {id: params["id"], req_id: params["req_id"]}})
          end
        end
      end
    end
    
    module InstanceMethods
      # This is the code that turns your params pseudo hash into a true hash.
      # It always groups things as a hash, even things that would normally be
      # an array. Arrays come out as as a hash with stringified numbers as keys.
      # That will be fixed soon. In fact, I'm considering having the client take
      # care of generating the params, as I don't see any reason for the server
      # to waste time performing the calculations.
      def paramify(hsh)
        return {} if hsh == ""
        t = {}
        hsh.each_pair do |k, v|
          chunks = k.split("[").map {|s| s.sub /\]$/, ""}
          if chunks.length > 1
            iter = t
            chunks.each_with_index do |c, i|
              if i+1 == chunks.length
                iter[c] = v
              else
                iter[c] ||= {}
              end
              iter = iter[c]
            end
          else
            t[k] = v
          end
        end
        t
      end
      
      # Link to the class instance variable that holds the actions.
      def actions
        self.class.actions
      end
      
      # Not a true HTTP redirect obviously, as we aren't using HTTP. This is simply
      # how you call one controller action from another.
      def redirect(command)
        ROCKET.parse_command(current_user, command)
      end
      
      # This is the method that runs the controller action. It hands over the current
      # user, and the paramified args.
      def process_command(user, command, args, params = nil)
        command = command.to_sym
        if actions.include?(command)
          @current_user = user
          @params = paramify(args)
          puts "-> #{self.class}.#{command}"
          self.instance_exec &actions[command.to_sym]
        else
          raise "Class #{self.class} does not have an action named #{command}"
        end
      end
    end
  end
  
  # Pulls in all of the controllers defined in app/controllers. This should probably
  # be recursive to support namespacing.
  Dir[File.join(APP_ROOT, "app", "controllers", "*.rb")].each do |f|
    require File.expand_path(f)
  end
  
end