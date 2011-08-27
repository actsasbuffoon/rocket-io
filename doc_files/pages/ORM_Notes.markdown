Rocket does not include a model layer. There are many reasons for this, but it is primarily because the choice of database is too important for the framework to make for you.

In order to get an ORM up and running, add a ruby file to the APP\_ROOT/config/initializers directory and require your files and perform any necessary setup.

Your database must be compatible with EventMachine in order to work optimally with Rocket. Additionally, if your ORM is compatible with EM-Synchrony then you won't need to write callbacks.

Mongoid and ActiveRecord both have EM-Synchrony variants, and there are undoubtedly others.

At some point in the future Rocket may include an option in the generator to get you up and running with an ORM.