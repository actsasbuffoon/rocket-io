class Rocket
  
  @@controllers = {}

  def self.controllers
    @@controllers
  end
  
  module Controller
    
    def self.bolted(other)
      Rocket.controllers[other.to_s.sub(/Controller$/, "").to_sym] = other
      other.send :attr_accessor, :args, :params, :current_user
    end
    
    module ClassMethods
      def define_action(name, &blk)
        @actions ||= {}
        @actions[name.to_sym] = blk
      end
      
      def actions
        @actions
      end
      
      # Upload the file
      # Provide the locations to the object in a special array (or hash?)
      def file_first(name, &blk)
        
        define_action "#{name}_request_tempfile".to_sym do
          id = "#{self.class.to_s}_#{name}_#{Time.now.to_i.to_s}_#{rand(9999999).to_s}"
          File.open(File.join(APP_ROOT, "tmp", id), "w") {|f| f.write ""}
          current_user.transmit("App.tempfile" => {id: id, req_id: params["req_id"]})
        end
        
        define_action "#{name}_receive_file".to_sym do
          File.open(File.join(APP_ROOT, "tmp", params["id"]), "ab") {|f| f.write Base64.decode64(params["chunk"])}
          if params["complete"]
            current_user.transmit({"App.finished_upload" => {id: params["id"], req_id: params["req_id"]}})
          end
        end
      end
      
      # Send the form
      # Get a record ID back
      # Attach ID to RocketUpload instance and transmit file
      # Run a serverside callback on the record once complete
      def form_first(name, &blk)
        
      end
    end
    
    module InstanceMethods
      def paramify(hsh)
        #puts "Attempting to paramify #{hsh.class}: #{hsh.inspect}"
        return {} if hsh == ""
        t = {}
        hsh.each_pair do |k, v|
          #puts "Working on #{k}: #{v.inspect}"
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
      
      def actions
        self.class.actions
      end
      
      def redirect(command)
        ROCKET.parse_command(current_user, command)
      end
      
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
  
  Dir[File.join(APP_ROOT, "app", "controllers", "*.rb")].each do |f|
    require File.expand_path(f)
  end
  
end