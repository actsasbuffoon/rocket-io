def pygmentize_markdown(markdown)
  in_code = false
  lang = nil
  ret = []
  code = nil
  markdown.split("\n").each_with_index do |line, i|
    if line =~ /^\s*```\s*(\S+)\s*/
      code = []
      lang = line.sub(/^\s*```\s*/, "").strip
      in_code = true
    elsif line =~ /^\s*```\s*$/
      in_code = false
      cd = Pygments.highlight(code.join("\n"), lexer: lang, formatter: 'html')
      t = []
      cd.sub!('<div class="highlight"><pre>', "").sub!("</pre>\n</div>", "")
      cd.split("\n").each do |cl|
        t << "<pre>#{cl}</pre>"
      end
      tx = "<div class='code_example'>" + t.join("") + "</div>"
      ret << tx
    else
      if in_code
        code << line.sub(/^\s{4}/, "")
      else
        ret << line
      end
    end
  end
  ret.join("\n")
end