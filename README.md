# Forwarder #

Delegation made readable.

## Rational ##

It seems that Ruby's built in ```Forwardable``` module does a decent job
to provide for delegation. However its syntax is more than terse, it is, IMHO,
unreadable. At a certain moment it came to me that relearning the correct
application of ```def_delegator```, frequent usage non withstanding is *not*
what I want to use my time for.

From that desire ```Forwarder``` was created. As ```Forwardable``` it is not
intruisive but once a module is extended with it the following methods spring
into live: ```forward```, ```forward_all``` and ```forward_to_self```. The
first two replace and enhance the functionality of ```def_delegator``` and
```def_delegators```, while the third is a kind of a ```alias_method``` on
steroids.

## Examples ##

* forward

Forwards to a target. The target must be specified by the ```:to``` keyword 
parameter and can be either a ```Symbol``` (or ```String```), thus representing 
an instance method or an instance variable, a lambda that will be evaluated 
in the instance's context. If an arbitrary object shall be the receiver of the
message, than the ```:to``` keyword can be replaced by the ```:to_object```
keyword parameter. 

       class Employee
         extend Forwarder
         forward :complaints, to: :boss
       end

This design, implementing some wishful thinking that will probably not pass
acceptance tests, will send the ```complaints``` message, sent to an instance
of ```Employee``` to the object returned by her ```boss``` method.

The following adjustment was made, in desperate hope to fix the *bug*:

      class Employee
        extend Forwarder
        forward :complaints, to: :boss, as: :suggestions
      end

This behavior being clearly preferable to the one implemented before.

Finally, however, the implementation looked like this

      class Boss
        extend Forwarder
        forward_all :complaints, :problems, :tasks, to: first_employee
      end

However this did not work as no ```first_employee``` was defined. This seems
simple enough a task, so that a method for this seems to much code bloat, here
are two possible implementations with ```Forwarder```

      class Boss
        extend Forwarder
        forward :first_employee, to: :@employees, as: :[], with: 0
        forward_all :complaints, :problems, :tasks, to: :first_employee
      end

As a side note, I do not enourage the exposure of instance variables as in the
example above, but I do not like to impose. As ```Forwardable``` can delegate to
instance variables I decided to provide the same functionality with
```Forwarder```.
      
Or alternatively

      class Boss
        extend Forwarder
        forward :first_employee, to: :@employees, as: :first
        forward_all :complaints, :problems, :tasks, to: first_employee
      end


Again one could argue that a message chain forwarding approach would be nice
here, it might as well be implemented in a later version.

      class Boss
        extend Forwarder
        forward_all :complaints, :problems, :tasks, to_chain: [:@employees, :first]
      end