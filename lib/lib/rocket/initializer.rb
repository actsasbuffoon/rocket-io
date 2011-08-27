require 'coffee-script'

# This is where everything related to compiling your Javascript into files
# for the user happens.
class Rocket
  # .to_json doesn't normally output functions, so this is a hack to take care of that.
  def recursive_object_dump(obj, prev = "")
    code = []
    if prev != ""
      code << "#{prev} = {}"
    end
    obj.each do |k, v|
      p = prev != "" ? prev + ".#{k}" : k
      code << "\n\n// * * * * * Dump of #{p} * * * * *\n\n"
      if v.class == V8::Object
        code << recursive_object_dump(v, p)
      elsif v.class == V8::Function
        code << "#{prev + "." if prev != ""}#{k} = #{v}"
      end
    end
    code.join("\n")
  end
  
  # This takes care of compiling the templates in app/views. This is recursive, so if you
  # have app/views/admin/song/index.jade, it will be made available to the client as
  # templates.admin.song.index
  #
  # The views are compiled down to a Javascript function that takes a hash of arguments and
  # returns rendered HTML. We only support [Jade](http://jade-lang.com) at the moment, but other templating languages
  # should be supported in the future.
  def compile_templates
    puts "Compiling Templates"
    js = V8::Context.new
    js.eval "window = {}"
    js.load File.join(APP_ROOT, "public", "javascripts", "jade.js")
    js.load File.join(APP_ROOT, "public", "javascripts", "formtacular.js")
    js.eval "var jade = require('jade')"
    js.eval "templates = {}"
    Dir[File.join(APP_ROOT, "app", "views", "**", "*.jade")].each do |file|
      begin
        chunks = (file.sub(/^#{APP_ROOT}\/app\/views/, "")).split("/").slice(1..-1)
        (chunks.length - 1).times do |i|
          scrpt = <<-EOS
            if (templates.#{chunks.slice(0..i).join(".")} == undefined) {
              templates.#{chunks.slice(0..i).join(".")} = {};
            };
          EOS
            js.eval scrpt
        end
        chunks[-1] = chunks[-1].sub(/\.jade$/, "")
        js['template_text'] = File.read(file)
        js.eval "templates.#{chunks.join(".")} = jade.compile(template_text)"
      rescue
        raise "ERROR IN TEMPLATE: #{file} (#{$!})"
      end
    end
    File.open(File.join(APP_ROOT, "public", "javascripts", "rocket_templates.js"), "w") {|f| f.write recursive_object_dump(js["templates"], "templates")}
    puts "Finished compiling templates."
  end
  
  # This method takes the controllers defined in app/controllers and sticks them onto a
  # variable named "controllers" for the client.
  def compile_controllers
    puts "Compiling Controllers"
    js = V8::Context.new
    js.eval "window = {}"
    js.eval "controllers = {}"
    Dir[File.join(APP_ROOT, "app", "controllers", "**", "*.*")].each do |file|
      ext = file.split(".").last
      filename = file.split("/").last.split(".").first
      next unless %w[js coffee].include?(ext)
      scrpt = File.read(file)
      scrpt = CoffeeScript.compile(scrpt, bare: true) if ext == "coffee"
      scrpt = <<-EOS
#{scrpt}
controllers['#{filename.class_case}Controller'] = new #{filename.class_case}Controller()
EOS
      js.eval scrpt
    end
    File.open(File.join(APP_ROOT, "public", "javascripts", "rocket_controllers.js"), "w") {|f| f.write recursive_object_dump(js["controllers"], "controllers")}
    puts "Finished Compiling Controllers"
  end
  
  # Just calls the other two methods.
  def prepare_js
    compile_templates
    compile_controllers
  end
  
end