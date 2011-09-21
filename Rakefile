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
  gem.description = %Q{Realtime web application framework that uses Web Sockets for (nearly) everything}
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

namespace :docs do

  desc "Generate all documentation"
  task :compile do
    puts "Generating documentation"
    ['docs:clear', 'docs:ruby', 'docs:js', 'docs:sass', 'docs:coffee', 'docs:copy_static', 'docs:markdown'].each do |t|
      Rake::Task[t].invoke
    end
  end

  desc "Clear doc_files"
  task :clear do
    puts "Clearing doc_files"
    FileUtils.rm_rf "doc_files/output"
    FileUtils.mkdir_p "doc_files/output"
  end

  desc "Generate Ruby Rocco docs"
  task :ruby do
    puts "Creating Ruby Rocco documentation"
    `rocco -l ruby -c \\# -o doc_files/output/rocco_rb lib/*.rb lib/lib/*.rb lib/lib/**/*.rb`
  end

  desc "Generate Javascript Rocco docs"
  task :js do
    puts "Creating Javascript Rocco documentation"
    `rocco -l javascript -c // -o doc_files/output/rocco_js lib/public/javascripts/rocket.js lib/public/javascripts/rocket_utils.js lib/public/javascripts/formtacular.js`
  end

  desc "Compile SASS into css for docs"
  task :sass do
    puts "Compiling SASS"
    require 'sass'
    FileUtils.mkdir_p "doc_files/output/css"
    Dir["doc_files/sass/*.sass"].each do |file|
     File.open("doc_files/output/css/#{file.split("/").last.sub(/\.sass$/, ".css")}", "w") {|f| f.write Sass::Engine.new(File.read file).render}
    end
  end

  desc "Compile markdown docs"
  task :markdown do
    puts "Compiling markdown"
    require 'haml'
    require 'rdiscount'
    require 'pygments'
    require File.expand_path('utils.rb')
    Haml::Engine.instance_variable_set "@options".to_sym, {format: :html5}
    args = {
      rb_files: Dir["doc_files/output/rocco_rb/**/*.html"],
      js_files: Dir["doc_files/output/rocco_js/**/*.html"],
      pages: Dir["doc_files/pages/**/*.markdown"]
    }
    Dir["doc_files/pages/*.markdown"].each do |file|
      File.open("doc_files/output/#{file.split("/").last.sub(/\.markdown$/, ".html")}", "w") do |f|
        f.write Haml::Engine.new(File.read "doc_files/layout.haml").render(Object.new, args.merge(current_file: file)) do
          markdown = File.read file
          markdown = pygmentize_markdown(markdown)
          Markdown.new(markdown).to_html
        end
      end
    end
  end

  desc "Compile CoffeeScript for docs"
  task :coffee do
    puts "Compiling CoffeeScript"
    require 'coffee-script'
    FileUtils.mkdir_p "doc_files/output/js"
    Dir["doc_files/coffee/*.coffee"].each do |file|
      File.open("doc_files/output/js/#{file.split("/").last.sub(/\.coffee$/, ".js")}", "w") do |f|
        f.write CoffeeScript.compile(File.read(file), bare: true)
      end
    end
  end

  desc "Copy static files for docs"
  task :copy_static do
    puts "Copying images"
    FileUtils.cp_r "doc_files/images", "doc_files/output/"
  end

  desc "Move docs to gh-pages branch"
  task :pages do
    require 'git'
    g = Git.open(".")
    if g.lib.diff_files.keys.length > 0 || g.status.added.keys.length > 0 || g.status.changed.keys.length > 0 || g.status.deleted.keys.length > 0
      puts "You have uncommitted changes. Aborting."
    else
      puts "Copying files outside root"
      fname = "rocket_doc_files_#{Time.now.to_i}"
      FileUtils.cp_r "doc_files/output", "../#{fname}"
      puts "Checking out gh-pages"
      g.checkout "gh-pages"
      Dir["*"].each {|f| puts "deleting #{f}"; FileUtils.rm_rf f}
      FileUtils.mv "../#{fname}", "."
      puts "Copying files from output"
      Dir["#{fname}/*"].each {|f| FileUtils.mv f, "."}
      puts "Removing doc_files"
      FileUtils.rm_rf fname
      `git add . -u`
      `git add .`
      `git commit -m "Updating documentation for Github Pages"`
      `git push origin gh-pages`
      `git checkout master`
    end
  end
end