class Rocket
  def compile_docs
    page_paths = Dir[File.join(APP_ROOT, "doc", "*.jade")].sort
    layout_path = page_paths.find {|p| p =~ /layout\.jade$/}
    page_paths.delete layout_path
    navigation_path = page_paths.find {|p| p =~ /navigation\.jade$/}
    page_paths.delete navigation_path

    js = V8::Context.new
    
    js.load File.join(APP_ROOT, "public", "javascripts", "jade.js")
    jade = js.eval("require('jade')")
    
    pages = js["pages"] = []
    
    page_paths.each do |page|
      pg = {
        "filename" => page,
        "html_filename" => page.sub(/\.jade$/, ".html")
      }
      pg["content"] = jade.render(File.read(page))
      noko = Nokogiri::HTML.parse pg["content"]
      pg["title"] = noko.css("h1").first.text
      pages.push(pg)
    end
    
    args = js["args"] = {}
    
    layout_template = js["layout_template"] = File.read(layout_path)
    layout = js["layout"] = jade.compile(layout_template)
    
    nav_template = js["nav_template"] = File.read(navigation_path)
    args['navigation'] = jade.render(nav_template, {"locals" => {"pages" => pages}})
    
    pages.each do |page|
      args["title"] = page['title']
      args["content"] = page['content']
      File.open(page['html_filename'], "w") {|f| f.write layout.call args}
    end

  end
end