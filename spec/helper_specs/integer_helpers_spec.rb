require 'spec_helper'
require 'forwarder/helpers'

describe Integer do
  describe :sum do
    it "returns sum of two objects" do
      described_class.sum.(1, 41).should eq( 42 )
    end
  end # describe :identity

  describe :succ do
    it "returns successor" do
      described_class.succ.( 41 ).should eq( 42 )
    end
  end # describe :succ
  describe :pred do
    it "returns predecessor" do
      described_class.pred.( 43 ).should eq( 42 )
    end
  end # describe :pred
end # describe Proc
