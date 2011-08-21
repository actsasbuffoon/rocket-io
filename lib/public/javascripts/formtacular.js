var text_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><input type='text' name='"+name+"' id='"+id+"' value='"+vl+"' /></div>"
}

var hidden_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<input type='hidden' name='"+name+"' id='"+id+"' value='"+vl+"' />"
}

var textarea_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><textarea name='"+name+"' id='"+id+"' >"+vl+"</textarea></div>"
}

var file_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><input type='file' name='"+name+"' id='"+id+"' >"+vl+"</input></div>"
}

var simple_upload = function(vr, args) {
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><span class='rocket_file_upload'><input type='hidden' class='upload_type' value='simple' /><input type='hidden' name='"+name+"' id='"+id+"' class='rocket_real_file_input' /><input type='file' name='"+name+"_dummy' id='"+id+"_dummy' /></span></div>"
}

var file_first_upload = function(vr, vl, args) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><span class='rocket_file_upload "+args["class"]+"'><input type='hidden' class='upload_type' value='file_first' /><input type='hidden' class='upload_action' value='"+args['action']+"' /><input type='hidden' name='"+name+"' id='"+id+"' class='rocket_real_file_input' /><input type='file' name='"+name+"' id='"+id+"' /></span></div>"
}

var form_first_upload = function(vr, vl, args) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><span class='rocket_file_upload "+ args["class"] +"'><input type='hidden' class='upload_type' value='form_first' /><input type='hidden' class='upload_action' value='"+args['action']+"' /><input type='file' name='"+name+"' id='"+id+"' /></span></div>"
}