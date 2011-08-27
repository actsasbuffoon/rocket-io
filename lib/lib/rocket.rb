# APP_ROOT is just what it sounds like; a reference to the root directory
# of your Rocket project.
APP_ROOT = File.join *File.dirname(File.expand_path __FILE__).split("/").slice(0..-2)

require "rocket-io"

# This pulls in all of the models defined in app/models. Currently it only
# pulls files in the model directory, but we should probably make it nested
# at some point. People might want that for namespacing.
Dir[File.join APP_ROOT, "app", "models", "*.rb"].each do |file|
  require file
end

ROCKET = Rocket.new

# This compiles all of you JS and CoffeeScript files and dumps them in the
# public directory.
ROCKET.prepare_js

# Start the main loop.
ROCKET.run