require 'spec_helper'
describe Forwarder do
  before :each do
    @klass = Class.new do
      extend Forwarder
      def elements; %w{alpha beta gamma} end
    end
  end
  subject do
    @klass.new
  end
  describe "forwarding map" do
    it "forwards with a symbol" do
      @klass.module_eval do
        forward :map, to: :elements, applying: :to_sym
      end
      subject.map.should == [:alpha, :beta, :gamma]
    end
    it "forwards with a block" do
      @klass.module_eval do
        forward :map, to: :elements do |x| x.to_sym end
      end
      subject.map.should == [:alpha, :beta, :gamma]
    end
  end # describe "forwarding"
end # describe Forwarder

