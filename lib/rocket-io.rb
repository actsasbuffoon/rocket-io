require 'base64'
require 'fileutils'
require 'rubygems'
require 'mongoid'
#require 'em-synchrony'
#require 'em-synchrony/em-redis'
#require 'em-synchrony/mongoid'
require File.expand_path(File.join APP_ROOT, "vendor", "em-synchrony", "lib", "em-synchrony.rb")
require File.expand_path(File.join APP_ROOT, "vendor", "em-synchrony", "lib", "em-synchrony", "em-redis.rb")
#require File.expand_path(File.join APP_ROOT, "vendor", "em-synchrony", "lib", "em-synchrony", "mongo.rb")
require 'thin'
require 'sinatra/async'
require 'em-websocket'
require 'json'
require 'v8'
require 'nokogiri'

require File.join("lib", "rocket", 'monkey_patches.rb')
require File.join("lib", "rocket", 'bolt.rb')
require File.join("lib", "rocket", 'initializer.rb')
require File.join("lib", "rocket", 'rocket_user.rb')
require File.join("lib", "rocket", 'controller.rb')
require File.join("lib", "rocket", 'runner.rb')