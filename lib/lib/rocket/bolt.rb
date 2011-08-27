# Bolt is a simple plugin system inspired by John Nunemaker's Mongo Mapper.
# You can set up a class/module with a module called ClassMethods and another
# called InstanceMethods. The methods defined on them will be put onto whatever
# bolts them. Additionally, if your base class has a method named "bolted", then
# it will be called, and the calling class will be passed as an argument.
class Class
  
  def bolt(mod)
    mod.bolted(self) if mod.respond_to?(:bolted)
    self.send(:include, mod::InstanceMethods) if mod::InstanceMethods
    self.class.send(:include, mod::ClassMethods) if mod::ClassMethods
  end
  
end