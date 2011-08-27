One of the most important differences between Rocket and other frameworks is the API for calling remote code from the client or server. Rocket gives you a set of Ruby controllers on the server, and Javascript controllers on the client. Client controllers can call server controllers, and vice versa. Let's look at some examples.

Our directory structure looks like this:

<ul class='dir_tree'>
  <li>
    <img src='images/icon_dir.png'/>app
    <ul>
      <li>
        <img src='images/icon_dir.png'/>controllers
        <ul>
          <li>
            <img src='images/icon_ruby.png'/>
            example.rb
          </li>
          <li>
            <img src='images/icon_js.png'/>
            example.js
          </li>
        </ul>
      </li>
    </ul>
    <ul>
      <li>
        <img src='images/icon_dir.png'/>
        views
        <ul>
          <li>
            <img src='images/icon_other.png'/>
            example.jade
          </li>
        </ul>
      </li>
    </ul>
  </li>
  <li>
    <img src='images/icon_dir.png'/>
    public
    <ul>
      <li>
        <img src='images/icon_dir.png'/>
        html
        <ul>
          <li>
            <img src='images/icon_other.png'/>
            index.html
          </li>
        </ul>
      </li>
      <li>
        <img src='images/icon_dir.png'/>
        javascripts
        <ul>
          <li>
            <img src='images/icon_js.png'/>
            app.js
          </li>
          <li>
            <img src='images/icon_js.png'/>
            formtacular.js
          </li>
          <li>
            <img src='images/icon_js.png'/>
            jade.js
          </li>
          <li>
            <img src='images/icon_js.png'/>
            jquery.js
          </li>
          <li>
            <img src='images/icon_js.png'/>
            rocket.js
          </li>
          <li>
            <img src='images/icon_js.png'/>
            rocket_controllers.js
          </li>
          <li>
            <img src='images/icon_js.png'/>
            rocket_templates.js
          </li>
          <li>
            <img src='images/icon_js.png'/>
            rocket_utils.js
          </li>
        </ul>
      </li>
    </ul>
  </li>
</ul>

public/html/index.html
----------------------
``` html
    <html>
      <head>
        <title>Example App</title>
        <script type='text/javascript' src='javascripts/jade'/></script>
        <script type='text/javascript' src='javascripts/jquery'/></script>
        <script type='text/javascript' src='javascripts/formtacular'/></script>
        <script type='text/javascript' src='javascripts/rocket_utils'/></script>
        <script type='text/javascript' src='javascripts/rocket_controllers.js'/></script>
        <script type='text/javascript' src='javascripts/rocket_templates.js'/></script>
        <script type='text/javascript' src='javascripts/app.js'/></script>
        <script type='text/javascript' src='javascripts/rocket.js'/></script>
      <body>
        
      </body>
    </html>
```

This is actually the default content of this file. We merely show it here so you can see that the static HTML page is only used to bootstrap the framework by loading the necessary Javascript files.

public/javascripts/app.js
------

``` javascript
    // Set up empty callbacks for the user to override.
    Rocket = {}
    
    // Called whenever the user connects (Not just the first time)
    Rocket.onopen = function() {
      
    }
    
    // Called when a user connection is terminated
    Rocket.onclose = function() {
      
    }
    
    // Called whenever the user receives a message from the server
    Rocket.onmessage = function() {
      
    }
    
    // Called when the user first connects to the web socket server
    Rocket.first_connect = function() {
      $("body").html(templates.example.index())
    }
```

This file is meant to be modified by the user to get your custom code bootstrapped. In this case, we just need to load a template into the body of the page when the user first connects to the web socket server.

app/views/example/index.jade
----------------------------

``` jade
    != link_to("O hai, server!", {"Example.say_hello": {name: "actsasbuffoon"}})
```

This is the template that gets loaded. The only content is a link that will call a server action. Notice that link\_to is quite similar to the link_to helper in Rails. The first argument is the link text, the second is the server action and any arguments you'd like to pass, and there is an optional third parameter for various options like a class to attach to the link.

The last argument to link_to is an example of the transmission API. The API is the same on both the client and server, so you don't need to learn two different ways to send data.

Let's examine the argument:

``` javascript
    {
      "Example.say_hello": {
        name: "actsasbuffoon"
      }
    }
```

As you can see, it is a simple hash (or object, to use the Javascript lingo) with a single key/value pair. The key is the server side controller and action taking the following format: "controller.action".

The value is a hash of arguments to pass to the action. They will be made available to the controller as the _params_ hash.

To put it all together, the code above will call the _say\_hello_ action on the server side _ExampleController_ and pass the following params: {name: "actsasbuffoon"}

Pretty simple, right?

app/controllers/example.rb
--------------------------

``` ruby
    class ExampleController
      bolt Rocket::Controller
      
      define_action :say_hello do
        current_user.transmit({"Example.be_greeted" => {message: "Howdy, #{params["name"]}!"}})
      end
      
    end
```

This is our server side controller. There is one action on the controller called _say\_hello_, which transmits a bit of JSON back to the user.

_params_ works pretty much just like it does in Rails. It is a combination of the variables explicitly passed as arguments to the action, as well as any form values.

_current_user.transmit_ is how we send data back to the user. It follows the same transmission rules as the client. This particular code will call the _be\_greeted_ action on the client side _ExampleController_, passing along {message: "Howdy, #{params[:name]}"}.

app/controllers/example.js
--------------------------

``` javascript
    ExampleController = function() {
      
      this.be_greeted = function(args) {
        alert(args.message)
      }
      
    }
```

This is the client side controller. It has a single action called _be\_greeted_ that will create a message box with the contents of the _args["message"]_ variable. Looking at the server side controller in the last section, we can see the message will be "Howdy, #{params[:name]}!".

Summary
-------

So this simple app create a single button that calls the server side _ExampleController.say\_hello_ passing along {name: "actsasbuffoon"}. The controller will call the client _ExampleController.be\_greeted_ passing along {message: "Howdy, actsasbuffoon!"}. The client action will then create a message box with "Howdy, actsasbuffoon!" inside.

This example is obviously very contrived, and more than a little complicated to set up something so simple. However, hopefully this gives you some idea of how to pass information from the client to the server and vice/versa.