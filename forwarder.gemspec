Gem::Specification.new do |s|
  s.name        = 'forwarder'
  s.version     = '0.1.0'
  s.summary     = "Making Delegation finally readable"
  s.description = %{Ruby's core Forwardable gets the job done(barely) and produces most unreadable code.
    This is a nonintrusive (as is Forwardable) module that allos to delegate methods to instance variables,
    objects returned by instance_methods, other methods of the same receiver (method_alias on steroids)
    and some more sophisticated use cases}
  s.authors     = ["Robert Dober"]
  s.email       = 'robert.dober@gmail.com'
  s.files       = Dir.glob("lib/**/*.rb")
  s.files      += %w{LICENSE README.md}
  s.homepage    = 'https://github.com/RobertDober/Forwarder'
  s.license     = %w{MIT}

  s.required_ruby_version = '>= 1.8.7'
end
