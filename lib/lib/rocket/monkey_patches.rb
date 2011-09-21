# This file contains a series of monkey patches to make it work with other libs
# or that are merely convenient.

# Mongoid initializer bombs without this.
def silence_warnings
  yield
end

class String
  
  # Takes a string in the form of "my\_awesome\_class" and returns "MyAwesomeClass".
  def class_case
    r = self[0].upcase
    r += self[1..self.length]
    r = r.gsub(/_(\w)/) {|s| $1.upcase}
    r
  end
  
  # Takes a string in the form of "MyAwesomeClass" and returns "my\_awesome\_class".
  def snake_case
    self.gsub(/([a-z])([A-Z])/) {|s| "#{s[0]}_#{s[1]}"}.gsub(/([A-Z])([A-Z][a-z])/) {|s| "#{s[0]}_#{s[1..2]}"}.downcase
  end
  
end

# Fix for a weird issue that causes BSON IDs to throw an argument error when you
# try to convert them to JSON.
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
      
      # Patch Async Sinatra to be compatible with EM-Synchrony
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