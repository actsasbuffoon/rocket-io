APP_ROOT = File.join *File.dirname(File.expand_path __FILE__).split("/").slice(0..-2)

#APP_NAME = "test_app"

require "rocket"

Dir[File.join APP_ROOT, "app", "models", "*.rb"].each do |file|
  require file
end

ROCKET = Rocket.new

ROCKET.prepare_js
ROCKET.run