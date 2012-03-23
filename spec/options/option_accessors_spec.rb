require 'spec_helper'

describe Forwarder::Options do
  describe :access_to_fields do
    subject do
      described_class.new as: :hello, to: :content, message: :howdy, with: :love, after: :later, before: :earlier
    end
    it "accesses after" do
      subject.after?.should eq( :later )
    end
    it "accesses before" do
      subject.before?.should eq( :earlier )
    end
  end # describe :access_to_fields

  describe :error_handling do
    it "raises an error on illegal params" do
      lambda do
        described_class.new whatever: 42, to: :content, message: :hello
      end
        .should raise_error( ArgumentError )
    end
    it "raises an error on conflicting params" do
      lambda do
        described_class.new to: :a, to_chain: []
      end
        .should raise_error( ArgumentError )
    end
    it "raises an error on missing parameters" do
      lambda do
        described_class.new message: :hello
      end
        .should raise_error( ArgumentError )
      lambda do
        described_class.new to: :hello
      end
        .should raise_error( ArgumentError )
    end
  end # describe :error_handling do
end # describe Forwarder::Options
