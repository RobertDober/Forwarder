$:.unshift( File.expand_path( "../lib", __FILE__ ) )
require 'forwarder/version'
Gem::Specification.new do |s|
  s.name        = 'forwarder19'
  s.version     = Forwarder::VERSION 
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

  s.add_development_dependency 'ruby-debug19', '~> 0.11'
  s.add_development_dependency 'rake', '~> 0.9.2.2'
  s.add_development_dependency 'rspec', '~> 2.9.0'
  s.add_development_dependency 'maruku', '~> 0.6.0'
  s.add_development_dependency 'wirble', '~> 0.1.3'

  s.required_ruby_version = '>= 1.9.2'
end
