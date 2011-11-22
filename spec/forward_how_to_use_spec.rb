require 'spec_helper'
describe Forwarder do
  it "is not intruisive" do
    lambda do
      Class.new do
        forward :a, :to => :b
      end
        .should raise_error(NoMethodError)
    end
  end # describe "is not intruisive"
  
  it "but it can be used via extend" do
    Class.new do
      forward :size, to: :content
      def initiali
    end
  end
end # describe Forwarder
