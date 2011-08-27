# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rocket-io"
  gem.homepage = "http://github.com/actsasbuffoon/rocket-io"
  gem.license = "MIT"
  gem.summary = %Q{Realtime web application framework}
  gem.description = %Q{Realtime web applicatioin framework that uses Web Sockets for (nearly) everything}
  gem.email = "michaeltomer@gmail.com"
  gem.authors = ["Michael Tomer"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rocket-io #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Generate all documentation"
task :docs do
  puts "Generating documentation"
  # FileUtils.rm_rf "doc_files/output"
  # FileUtils.mkdir_p "doc_files/output"
  puts "Creating Ruby Rocco documentation"
  # `rocco -l ruby -c \\# -o doc_files/output/rocco_rb lib/*.rb lib/lib/*.rb lib/lib/**/*.rb`
  puts "Creating Javascript Rocco documentation"
  # `rocco -l javascript -c // -o doc_files/output/rocco_js lib/public/javascripts/rocket.js lib/public/javascripts/rocket_utils.js lib/public/javascripts/formtacular.js`
  puts "Compiling SASS"
  require 'sass'
  FileUtils.mkdir_p "doc_files/output/css"
  Dir["doc_files/sass/*.sass"].each do |file|
   File.open("doc_files/output/css/#{file.split("/").last.sub(/\.sass$/, ".css")}", "w") {|f| f.write Sass::Engine.new(File.read file).render}
  end
  puts "Compiling markdown"
  require 'haml'
  require 'rdiscount'
  Haml::Engine.instance_variable_set "@options".to_sym, {format: :html5}
  args = {
    rb_files: Dir["doc_files/output/rocco_rb/**/*.html"],
    js_files: Dir["doc_files/output/rocco_js/**/*.html"],
    pages: Dir["doc_files/pages/**/*.markdown"]
  }
  Dir["doc_files/pages/*.markdown"].each do |file|
    File.open("doc_files/output/#{file.split("/").last.sub(/\.markdown$/, ".html")}", "w") do |f|
      f.write Haml::Engine.new(File.read "doc_files/layout.haml").render(Object.new, args.merge(current_file: file)) do
        Markdown.new(File.read file).to_html
      end
    end
  end
  puts "Compiling CoffeeScript"
  require 'coffee-script'
  FileUtils.mkdir_p "doc_files/output/js"
  Dir["doc_files/coffee/*.coffee"].each do |file|
    File.open("doc_files/output/js/#{file.split("/").last.sub(/\.coffee$/, ".js")}", "w") do |f|
      f.write CoffeeScript.compile(File.read(file), bare: true)
    end
  end
  puts "Copying images"
  FileUtils.cp_r "doc_files/images", "doc_files/output/images"
end

desc "Move docs to gh-pages branch"
task :pages do
  require 'git'
  g = Git.open(".")
  if g.lib.diff_files.keys.length > 0 || g.status.added.keys.length > 0 || g.status.changed.keys.length > 0 || g.status.deleted.keys.length > 0
    puts "You have uncommitted changes. Aborting."
  else
    Dir["doc_files/output/**/*"].each do |f|
      `touch #{f}`
    end
    g.stash_save "Prepping GH-PAGES #{Time.now}"
    g.checkout "gh-pages"
    Dir["*"].each {|f| FileUtils.rm f}
    `git stash pop`
    FileUtils.mv "doc_files/output/**/*", "."
    FileUtils.rm_rf "doc_files"
  end
end