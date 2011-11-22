require 'spec_helper'
describe Forwarder do
  
  it "can be used in classes" do
    Class.new do
      extend Forwarder
      forward :size, :to_object => []
    end
      .new
      .size
      .should be_zero
  end
end # describe Forwarder
