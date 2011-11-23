require 'spec_helper'
describe Forwarder do
  before :each do
    @klass = Class.new do
      extend Forwarder
      forward :name, to_object: "name", as: :dup
    end
  end
  subject do
    @klass.new
  end
  it "forwards to the object" do
    subject.name.should == "name"
  end
end # describe Forwarder
