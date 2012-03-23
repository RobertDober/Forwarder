require 'spec_helper'
require 'forwarder/helpers'

describe Proc do
  describe :identity do
    let :anon do double("any object") end
    it "returns receiver" do
      described_class.identity.(anon).should eq(anon) 
    end
  end # describe :identity
end # describe Proc
