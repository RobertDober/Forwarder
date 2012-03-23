require 'spec_helper'
require 'forwarder/helpers'

module Mixin
  extend Forwarder
end
class Example
  include Mixin
  extend Forwarder
  forward :sizes, to: :@values, as: :map, applying: :size
  forward :sum, to: :sizes, as: :inject do |a,e| a + e end
  forward :parents, to: self, as: :ancestors
  forward :sum1, to: :sizes, as: :inject, applying: Integer.sum
  def value_at idx
    @values[idx]
  end
  def initialize *values
    @values = values
  end
end # class Example

describe Example do
  subject do
    described_class.new( *%w{alpha beta gamma} )
  end
  it "has sizes" do
    subject.sizes.should == [5, 4, 5]
  end
  it "has parents" do
    subject.parents.should include( Mixin )
  end
  it "has a sum" do
    subject.sum.should == 14
  end

  describe "with helpers" do
    it "has a sum1" do
      subject.sum1.should == 14
    end
    it "can use identity" do
      Example.send :forward, :elements, to: :@values, as: :map, applying: Proc.identity
      subject.elements.should == %w{alpha beta gamma}
    end
  end # describe "with helpers"
end # describe Example
