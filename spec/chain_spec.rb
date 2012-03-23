require 'spec_helper'

describe Forwarder do
  
  before :each do
    @klass = Class.new do
      extend Forwarder
      forward :first, to_chain: [ :elements, :first, :chars ]
      forward :first_first, to_chain: [ :elements, :first ], as: :[], with: 0
      forward :middle, to_chain: [ :eleary, :first ], as: :[], with: 1
      forward :first_blk, to_chain: [ :eleary, :first ], as: :instance_eval do reverse end
      forward_all :second, :last_but_one, to_chain: [ :eleary, :first ], as: :[], with: 1
      forward_all :second_blk, :last_but_one_blk, to_chain: [ :eleary, :first ], as: :instance_eval do |x| x[1] end
      def elements; %w{alpha beta gamma} end
      def eleary; [ elements ] end
    end
  end
  subject do
    @klass.new
  end
  describe "chain with forward" do
    it "gets first letter of first" do
      subject.first.should == "a"
    end
    it "gets first letter of first (with as: and with:)" do
      subject.first_first.should == "a"
    end
    it "gets middle" do
      subject.middle.should == "beta"
    end
  end # describe "forwarding"

  describe "chain with block" do
    it "gets first block" do
      subject.first_blk.should eq( %w{gamma beta alpha} )
    end
    
  end # describe "chain with block"

  describe "chain with forward_all" do
    it "gets second" do
      subject.second.should == "beta"
    end
  end

  describe "chain with forward_all" do
    it "gets last_but_one" do
      subject.last_but_one.should == "beta"
    end
  end # describe "chain with forward_all"

  describe "chain with forward_all and block" do
    
    it "gets second_blk" do
      subject.second_blk.should == "beta"
    end
    it "gets last_but_one_blk" do
      subject.last_but_one_blk.should == "beta"
    end
  end # describe "chain with forward_all and block"
end # describe Forwarder
