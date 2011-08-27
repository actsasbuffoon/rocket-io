// This file provides utility classes for Rocket.

// Set up empty callbacks for the user to override.
Rocket = {}
Rocket.onopen = function() {}
Rocket.onclose = function() {}
Rocket.onmessage = function() {}
Rocket.first_connect = function() {}

// Determine if we need to use a vendor specific slice method for chunking files.
if (window.Blob != undefined) {
  if (Blob.prototype.slice != undefined) {
    var file_api_slice_method = "slice"
  }
  else if (Blob.prototype.webkitSlice != undefined) {
    var file_api_slice_method = "webkitSlice"
  }
  else if (Blob.prototype.mozSlice != undefined) {
    var file_api_slice_method = "mozSlice"
  }
}

// Create a link that uses the Rocket API. This looks a lot like the link_to helper
// in Rails. Writing something like "link_to('Show', {'User.show': {id: 1}})" would
// create a link that when clicked will call the "User.show" server side action and
// pass the nested object as an argument. Note that you can override the tag type,
// and even what the onclick callback should be.
var link_to = function(text, args, attrs) {
  attrs = attrs || {}
  if (attrs.tag_type) {
    tag_type = attrs.tag_type
    delete(attrs.tag_type)
  }
  else {
    tag_type = "a"
  }
  attrs.href = attrs.href || "#"
  attrs.onclick = args.onclick || "rocket(" + JSON.stringify(args) + ")"
  t = []
  for (var k in attrs) {
    t.push(k + "='" + attrs[k].replace("'", "\\'") + "'")
  }
  str = "<" + tag_type + " " + t.join(" ") + ">" + text + "</" + tag_type + ">"
  return str
}

// Utility function to reduce a byte count to something easier to read. Useful
// for file uploads.
var size_estimator = function(bytes) {
  n = false
  if (bytes < 1024) {
    n = [bytes, "B"]
  }
  else if (bytes < 1024 * 1024) {
    n = [bytes / 1024.0, "KB"]
  }
  else if (bytes < 1024 * 1024 * 1024) {
    n = [bytes / 1024.0 / 1024, "MB"]
  }
  else if (bytes < 1024 * 1024 * 1024 * 1024) {
    n = [bytes / 1024.0 / 1024 / 1024, "GB"]
  }
  else if (bytes < 1024 * 1024 * 1024 * 1024 * 1024) {
    n = [bytes / 1024.0 / 1024 / 1024 / 1024, "TB"]
  }
  else {
    n = [bytes / 1024.0 / 1024 / 1024 / 1024 / 1024, "PB"]
  }
  return "" + (Math.round(n[0]*100)/100) + n[1]
}

// Store all current file uploads
var file_uploads = []

var RocketUploader = function(elem, form) {
  
  var RocketFileFirstUpload = function(uploader, file, real_input, action) {
    this.file_chunk_size = 1024 * 100
    this.uploader = uploader
    this.file = file
    this.action = action
    this.real_input = real_input
    this.form = this.uploader.form
    this.history = []

    this.set_temp_id = function(t_id) {
      this.temp_id = t_id
      this.upload_chunk()
    }
    
    this.file_first = function(start) {
      this.req_id = Math.random()
      file_uploads[this.req_id] = this
      this.form.wait_for(this.req_id)
      v = {}
      v[this.action + "_request_tempfile"] = {req_id: this.req_id}
      rocket(v)
      this.uploader.elem.attr("data-rocket-upload", "file_uploads["+this.req_id+"]")
      
      this.oncomplete = function() {
        this.real_input.val(this.temp_id)
        this.form.finished_with(this.req_id)
      }
      
      this.upload_chunk = function(start) {
        r = new FileReader()
        r.rocket_upload = this
        
        r.onload = function(e) {
          d = new Date()
          t = d.getTime() + (d.getMilliseconds() / 1000.0)
          r.rocket_upload.history.push({time: t, size: r.rocket_upload.file_chunk_size})
          this.rocket_upload.uploader.elem.trigger("uploaded_chunk")
          
          if (r.rocket_upload.start + r.rocket_upload.file_chunk_size < r.rocket_upload.file.fileSize) {
            v = {}
            v[r.rocket_upload.action + "_receive_file"] = {chunk: btoa(e.target.result), complete: false, index: r.rocket_upload.start + r.rocket_upload.file_chunk_size, id: r.rocket_upload.temp_id, req_id: r.rocket_upload.req_id}
            rocket(v)
            r.rocket_upload.upload_chunk(r.rocket_upload.start + r.rocket_upload.file_chunk_size)
          }
          else {
            v = {}
            v[r.rocket_upload.action + "_receive_file"] = {chunk: btoa(e.target.result), complete: true, index: r.rocket_upload.file_chunk_size, id: r.rocket_upload.temp_id, req_id: r.rocket_upload.req_id}
            rocket(v)
          }
        }
        r.onerror = function(e) {
          console.log(e)
        }
        
        if (start == undefined) {
          this.start = 0
        }
        else {
          this.start = start
        }
        // Is this the last chunk of the file or not?
        if (this.start + this.file_chunk_size < this.file.fileSize) {
          f = this.file[file_api_slice_method](this.start, this.start + this.file_chunk_size)
          r.readAsBinaryString(f)
        }
        else {
          f = this.file[file_api_slice_method](this.start, this.file.fileSize)
          r.readAsBinaryString(f)
        }
      }
    }
    
    this.file_first()
  }
  
  var RocketSimpleUpload = function(uploader, file, real_input) {
    
    this.simple_read = function() {
      this.id = Math.random()
      this.form.wait_for(this.id)
      r = new FileReader()
      r.rocket_upload = this
      r.onload = function(e) {
        real_input.val(btoa(e.target.result))
        this.rocket_upload.form.finished_with(this.rocket_upload.id)
      }
      r.onerror = function(e) {
        console.log(e)
      }
      r.readAsBinaryString(this.file)
    }
    
    this.uploader = uploader
    this.form = this.uploader.form
    this.file = file
    this.real_input = real_input
    this.simple_read()
  }
  
  this.form = form
  this.elem = elem
  type = $(elem).children(".upload_type").val()
  action = $(elem).children(".upload_action").val()
  real_input = $(elem).children(".rocket_real_file_input")
  file_input = $(elem).children("input[type='file']")[0]
  for (i = 0; i < file_input.files.length; i++) {
    if (type == "simple") {
      new RocketSimpleUpload(this, file_input.files[i], real_input)
    }
    else if (type == "file_first") {
      new RocketFileFirstUpload(this, file_input.files[i], real_input, action)
    }
  }
}

// Override the submission of forms to use the submit_callback function.
$("input[type=submit]").live("click", function(evnt) {submit_callback(evnt)})

// Prevent the form from being submitted and create a new RocketForm form the HTML form.
submit_callback = function(evnt) {
  evnt.preventDefault()
  new RocketForm(evnt)
}

// Takes an HTML form and allows it to be uploaded. Purposes include:
// * Dealing with file uploads
// * Deferring the upload based on callbacks (could be useful for uploads or validation)
// * Paramifying form data
var RocketForm = function(evnt) {
  this.waiting = []
  
  this.wait_for = function(key) {
    console.log("Waiting for " + key)
    this.waiting.push(key)
  }
  
  this.finished_with = function(key, ret) {
    console.log("No longer waiting for " + key)
    console.log(key)
    for (i = 0; i < this.waiting.length; i++) {
      if (this.waiting[i] == key) {
        console.log(this.waiting[i])
        this.waiting.splice(key, 1)
      }
    }
    this.check_submission(ret)
  }
  
  this.check_submission = function(args) {
    console.log("Checking submission")
    if (args != undefined) {
      console.log("Received args:")
      console.log(args)
    }
    if (this.waiting.length == 0) {
      console.log("Ready!")
      this.submit()
    }
    else {
      console.log("Not ready.")
      console.log(this.waiting)
      return false
    }
  }
  
  this.submit = function() {
    console.log("Called submit!")
    var frm = this
    this.frm.find("input, textarea, select").each(function(i, e) {
      el = $(e)
      if (el.attr("type") == "file") {
        console.log("Found a file uploader")
        if (el.parent().children(".upload_type").val() == "simple") {
          frm.vals[el.parent().children(".rocket_real_file_input").attr("name")] = el.parent().children(".rocket_real_file_input").val()
        }
        else if (el.parent().children(".upload_type").val() == "file_first") {
          frm.vals[el.parent().children(".rocket_real_file_input").attr("name")] = el.parent().children(".rocket_real_file_input").val()
        }
      }
      else if (el.parent().hasClass("rocket_file_upload")) {
        
      }
      else {
        if (el.val()) {
          frm.vals[el.attr("name")] = el.val()
        }
        else {
          if (el.attr("type") == "submit") {
            frm.vals["submit"] = null
          }
        }
      }
    })
    console.log(this.vals)
    obj = {}
    obj[this.frm.attr("action")] = this.vals
    rocket(obj)
  }
  
  this.elem = $(evnt.target)
  this.frm = $(this.elem.parents("form"))
  this.vals = {}
  this.vals["_method"] = this.frm.attr("method") || "POST"
  var ul = this
  this.frm.find("input, textarea, select").each(function(i, e) {
    el = $(e)
    if (el.attr("type") == "file") {
      console.log("Found a file uploader")
      new RocketUploader(el.parent(), ul)
    }
  })
  this.check_submission()
}