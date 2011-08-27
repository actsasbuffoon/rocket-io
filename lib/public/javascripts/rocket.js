// This file gets Rocket up and running. It depends on rocket_utils.js

var jade = require('jade')

// socket is where we will store the web socket conection.
var socket = false

// This gets flipped on once the user has connected for the first time.
var first_connect = false

// Send the data to the server.
rocket = function(msg) {
  // Make sure the socket is connected. If not, wait to send the message until later.
  if (socket && socket.readyState == 1) {
    console.log("Sending message to server:")
    console.log(msg)
    socket.send( JSON.stringify(msg) )
  }
  else {
    setTimeout(function() {
      rocket(msg)
    }, reconnect_interval)
  }
}

$(document).ready(function() {
  // The interval between reconnection attempts should we lose our connection to the server.
  reconnect_interval = 5000
  
  // Connect to the server.
  connect = function() {
    if (!socket || socket.readyState != 1) {
      console.log("Attempting to connect to the WebSocket server.")
      socket = new WebSocket("ws://localhost:9185")

      try {
        socket.onopen = function() {
          if (!first_connect) {
            // Run the Rocket.first_connect callback.
            Rocket.first_connect()
          }
          first_connect = true
          // Run the Rocket.onopen callback.
          Rocket.onopen()
          console.log("Connected to server")
        }
        
        // Deals with the incoming web socket messages.
        socket.onmessage = function(msg) {
          console.log("Received message: " + msg.data)
          cmd = JSON.parse(msg.data)
          // Iterate over the message and call the appropriate client side controller actions.
          //
          // The API for this very simple, and is identical between the client and server.
          //
          // Send just a string like this: "User.show" and Rocket will call the show action on
          // the user controller without any arguments. 
          //
          // Send a hash like this: "{'User.show' => {id: 1}}" and Rocket will call the same
          // controller and action as before, but will pass the hash value as an argument.
          for (var k in cmd) {
            k_parts = k.split(".")
            k_parts[0] = k_parts[0] + "Controller"
            sk = k_parts.join(".")
            console.log("controllers." + sk)
            fnc = eval("controllers." + sk)
            fnc(cmd[k])
          }
          // Call the Rocket.onmessage callback. Should we provide before and after callbacks?
          Rocket.onmessage()
        }
        
        // Continuously tries to reconnect until successful.
        socket.onclose = function() {
          console.log("Lost connection to server.")
          socket = false
          Rocket.onclose()
          setTimeout(function() {
            connect()
          }, reconnect_interval)
        }
      }
      catch(err) {
        console.log("Could not connect: " + err)
      }
    }
  }
  
  connect()
})