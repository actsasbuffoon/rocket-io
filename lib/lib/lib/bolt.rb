class Class
  
  def bolt(mod)
    mod.bolted(self) if mod.respond_to?(:bolted)
    self.send(:include, mod::InstanceMethods) if mod::InstanceMethods
    self.class.send(:include, mod::ClassMethods) if mod::ClassMethods
  end
  
end