class Generator < Thor
  
  desc "name", "The name of the new project"
  def create(name)
    puts "You wanted to create a new project called #{name}"
  end
  
end