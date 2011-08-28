// This file deals with shortcuts and helpers for forms and other view related
// things.
//
// Most of these methods deal with generating form inputs. For those methods, they
// create a label that is linked to the input and wrap everything in an element
// (usually a div, but can be overridden).

// Create a text input.
var text_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  vl = "" + vl
  vl = vl.replace(/"/g, '\"')
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + '</label><input type="text" name="'+name+'" id="'+id+'" value="'+vl+'" /></div>'
}

// Create a hidden input
var hidden_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<input type='hidden' name='"+name+"' id='"+id+"' value='"+vl+"' />"
}

// Create a textarea
var textarea_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><textarea name='"+name+"' id='"+id+"' >"+vl+"</textarea></div>"
}

// Create a checkbox input.
var checkbox_input = function(vr, vl) {
  checked = ""
  if (vl == undefined || vl == false) {
    checked = ""
  }
  else {
    checked = "checked='true'"
  }
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><input type='checkbox' name='"+name+"' id='"+id+"' "+checked+" /></div>"
}

// Create a file_input that doesn't make use of Rocket's upload functionality.
var file_input = function(vr, vl) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><input type='file' name='"+name+"' id='"+id+"' >"+vl+"</input></div>"
}

// Creates a file that makes use of Rocket's "Simple Upload". Simple Upload reads the
// contents of a file via the javascript file API, base64 encodes it, and passes the
// data to the server side controller action as part of the form.
//
// Simple Upload doesn't require any configuration, but has some drawbacks. For one,
// it doesn't deal well with large amounts of data. Second, the read happens in one pass,
// so there is no opportunity to present the user with a progress bar.
//
// Simple Upload is probably inadvisable except for very small files.
//
// Note that this function does a little more than the simpler form helpers. It puts a
// few extra elements in that make it possible for the upload script to work. If you do
// not wish to use Formtacular in your project, be sure to include the extra elements
// with your file input, or the uploads will not work.
var simple_upload = function(vr, args) {
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><span class='rocket_file_upload'><input type='hidden' class='upload_type' value='simple' /><input type='hidden' name='"+name+"' id='"+id+"' class='rocket_real_file_input' /><input type='file' name='"+name+"_dummy' id='"+id+"_dummy' /></span></div>"
}

// Creates a file input that uses the "Form First" uploader. Form First does exactly what
// it sounds like; it uploads the file first, and submits the form after. Note that you
// need to set up some special controller actions for this to work. Look at the server
// framework under Rocket::Controller for more information.
//
// Like Simple Upload, this function includes extra elements needed to make the upload work.
// Be sure to include the extra elements with your file input.
var file_first_upload = function(vr, vl, args) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><span class='rocket_file_upload "+args["class"]+"'><input type='hidden' class='upload_type' value='file_first' /><input type='hidden' class='upload_action' value='"+args['action']+"' /><input type='hidden' name='"+name+"' id='"+id+"' class='rocket_real_file_input' /><input type='file' name='"+name+"' id='"+id+"' /></span></div>"
}

// Does not serve a purpose yet.
var form_first_upload = function(vr, vl, args) {
  if (vl == undefined) {vl = ""}
  parts = vr.split(".")
  label_text = parts[parts.length - 1]
  name = parts[0] + "[" + parts.slice(1, parts.length).join("][") + "]"
  id = vr.replace(/\./m, "_").replace(/__+/m, "_")
  return "<div class='field'><label for='"+id+"'>" + label_text + "</label><span class='rocket_file_upload "+ args["class"] +"'><input type='hidden' class='upload_type' value='form_first' /><input type='hidden' class='upload_action' value='"+args['action']+"' /><input type='file' name='"+name+"' id='"+id+"' /></span></div>"
}