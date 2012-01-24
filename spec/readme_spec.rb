require 'spec_helper'

describe "assuring that the examples in README behave as described" do
  describe "The forward Method" do
    describe "Target specified with :to" do
      subject do
        @klass.new
      end
      it "forwards to boss" do
        @klass = Class.new do
          extend Forwarder
          forward :complaints, :to => :boss
        end
        boss = double
        boss.should_receive( :complaints ).with( 42 )
        subject.stub( :boss ).and_return( boss )
        subject.complaints 42
      end
      it "forwards to boss as sugestions" do
        @klass = Class.new do
          extend Forwarder
          forward :complaints, :to => :boss, :as => :suggestions
        end
        boss = double
        boss.should_receive( :suggestions ).with( 42 )
        subject.stub( :boss ).and_return( boss )
        subject.complaints 42
      end
      describe "but boss forwards back" do
        before :each do
          # Make worker bees available as closed in local var
          # for the initializer as well as ivar for the examples
          @worker_bees = worker_bees = double
          @poor_worker_bee = double
          @boss = Class.new do
            extend Forwarder
            forward :first_employee, :to => :@employees, :as => :[], :with => 0
            forward_all :complaints, :problems, :tasks, :to => :first_employee
            define_method :initialize do
              @employees = worker_bees
            end
          end
        end
        subject do
          @boss.new
        end
        it "complaints" do
          @poor_worker_bee.should_receive( :complaints )
          @worker_bees.should_receive( :[] ).with( 0 ).and_return @poor_worker_bee
          subject.complaints
        end
        it "tasks" do
          @poor_worker_bee.should_receive( :tasks )
          @worker_bees.should_receive( :[] ).with( 0 ).and_return @poor_worker_bee
          subject.tasks
        end
        it "problems" do
          @poor_worker_bee.should_receive( :problems )
          @worker_bees.should_receive( :[] ).with( 0 ).and_return @poor_worker_bee
          subject.problems
        end
      end # describe "but boss forwards back"

    end # describe "Target specified with :to"

   describe "parametrization without translation" do
     it "still works" do
       signaller = double
       train = Class.new do
         extend Forwarder
         forward :signal, to: :@signaller, with: {:strength => 10, :tone => 42}
         define_method :initialize do
           @signaller = signaller
         end
       end
       signaller.should_receive( :signal ).with( :strength => 10, :tone => 42 )
       train.new.signal
     end
   end # describe "parametrization without translation"
  end # describe "The forward Method"

  describe "The forward_all Method" do
    describe "with :to_chain target" do
      before :each do
        @worker_bees = worker_bees = double
        @poor_worker_bee = double
        @boss = Class.new do 
          extend Forwarder
          forward_all :complaints, :problems, :tasks, to_chain: [:@employees, :first]
          define_method :initialize do
            @employees = worker_bees
          end
        end
      end
      it "fowards complaints to the chain" do
        @worker_bees.should_receive( :first ).and_return @poor_worker_bee
        @poor_worker_bee.should_receive( :complaints )
      end
    end # describe "with :to_chain target"
  end # describe "The forward_all Method"
end # describe "assuring that the examples in README behave as described"
