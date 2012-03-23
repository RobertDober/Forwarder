require 'spec_helper'
require 'forwarder/helpers/integer_helper'

describe Forwarder do
  before :each do
    @klass = Class.new do
      extend Forwarder
      def a_hash; { a: 42, b: [], c: "gamma" } end
      def adding a, b; a + b end

      def initialize *args
        @name = args.shift
        @rest = args
      end
    end
  end
  subject do
    @klass.new "subject", 1, 2, 3
  end
  describe "not fowarding" do
    it "must be declared first" do
      lambda{ subject.sum }.should raise_error(NoMethodError)
    end
  end # describe "not fowarding"
  describe "forwarding" do
    it "forwards to ivar" do
      @klass.module_eval do
        forward :size, to: :@rest
      end
      subject.size.should == 3
    end

    it "forwards with renaming (as: other)" do
      @klass.module_eval do
        forward :count, to: :@name, as: :length
      end
      subject.count.should == 7
    end

    it "forwards with additional parameters" do
      @klass.module_eval do
        forward :a, to: :a_hash, as: :[], with: :a
      end
      subject.a.should == 42
    end

    it "forwards with additional parameters and after filter" do
      @klass.module_eval do
        forward :a, to: :a_hash, as: :[], with: :a, after: Integer.succ
      end
      subject.a.should == 43
      
    end

    it "forwards as a partial application" do
      @klass.module_eval do
        forward_to_self :sum1, as: :adding, with: 1
      end
      subject.sum1( 23 ).should == 24
    end

    it "can use a return value for the partial application too" do
      @klass.module_eval do
        forward :sum, to: :@rest, as: :inject, with: 4, applying: :+
      end
      subject.sum.should == 10
    end
  end # describe "forwarding"
end # describe Forwarder
