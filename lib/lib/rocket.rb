# APP_ROOT is just what it sounds like; a reference to the root directory
# of your Rocket project.
APP_ROOT = File.join *File.dirname(File.expand_path __FILE__).split("/").slice(0..-2)

require "rocket-io"

require File.join(APP_ROOT, "config", "config.rb")

ROCKET = Rocket.new

# This compiles all of you JS and CoffeeScript files and dumps them in the
# public directory.
ROCKET.prepare_js

# Start the main loop.
ROCKET.run