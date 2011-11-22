require 'spec_helper'
describe Forwarder do
  
  let :body do
    lambda do | *args |
      extend Forwarder
      forward :size, :to_object => []
    end
  end

  describe "in classes" do
    before :each do
      @c =Class.new( &body )
    end
    it "works in the class" do
      @c.new
      .size
      .should be_zero
    end
    it "works in inherited classes" do
      Class.new( @c, &body )
        .new
        .size
        .should be_zero 
    end
  end
  it "can be used in modules" do
   m = Module.new( &body )
   c = Class.new
   c.send :include, m
   c.new.size.should be_zero
  end
  it "can be used in singletons" do
    m = Module.new( &body )
    m.extend m
    m.size.should be_zero
  end
end # describe Forwarder
