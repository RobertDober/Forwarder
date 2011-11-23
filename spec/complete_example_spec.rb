require 'spec_helper'

module Mixin
  extend Forwarder
  
end
class Example
  include Mixin
  extend Forwarder
  forward :sizes, to: :@values, as: :map, applying: :size
  forward :parents, to: self, as: :ancestors
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
end # describe Example
