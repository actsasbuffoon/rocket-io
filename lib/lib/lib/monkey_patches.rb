class String
  
  def class_case
    r = self[0].upcase
    r += self[1..self.length]
    r = r.gsub(/_(\w)/) {|s| $1.upcase}
    r
  end
  
  def snake_case
    self.gsub(/([a-z])([A-Z])/) {|s| "#{s[0]}_#{s[1]}"}.gsub(/([A-Z])([A-Z][a-z])/) {|s| "#{s[0]}_#{s[1..2]}"}.downcase
  end
  
end

module BSON
  class ObjectId
    def to_json(*args)
      v = super
      v
    end
  end
end

module Sinatra
  module Async
    module Helpers
      
      def async_schedule(&b)
        if settings.environment == :test
          settings.set :async_schedules, [] unless settings.respond_to? :async_schedules
          settings.async_schedules << lambda { async_catch_execute(&b) }
        else
          native_async_schedule { Fiber.new {async_catch_execute(&b)}.resume }
        end
      end
      
    end
  end
end