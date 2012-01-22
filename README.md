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

### forward ###

* forward to:

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
acceptance tests, will forward the ```complaints``` message, sent to an instance
of ```Employee```, to the object returned by this very instance's ```boss``` method.

The following adjustment was made, in desperate hope to fix the *bug*:

      class Employee
        extend Forwarder
        forward :complaints, to: :boss, as: :suggestions
      end

This behavior being clearly preferable to the one implemented before because the
receiver of ```complaints``` is still forwarding the call to the result of the
call of its ```boss``` method, but to the ```suggestion``` method.

Finally, however, the implementation looked like this

      class Boss
        extend Forwarder
        forward :complaints, to: first_employee
        forward :problems, to: first_employee
        forward :tasks, to: first_employee
      end

However this did not work as no ```first_employee``` was defined. This seems
simple enough a task, so that a method for this seems too much code bloat, here
are two possible implementations with ```Forwarder```. The other thing that
catches (or should, at least) the reader's eyes is the terrible code repetition.
The next chapter describing `forward_all`, will show us, how to get rid of this.

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


* forward to_chain:

The above, however is a little bit verbose, we can shorten it with the `:to_chain`
parameter

      class Boss
        extend Forwarder
        forward_all :complaints, :problems, :tasks, to_chain: [:@employees, :first]
      end

As you might guess, the `complaints` message is sent to the result of sending `first`
to the `@employees` instance variable. As (no pun intended) with the `to:` version
of `forward`, one can change the message name with the `as:` parameter.

### forward_all ###

`forward_all` allows us to forward more then one message to a target. It is a shortcut
for calling `forward` to each of its method parameters



# License #

This software is licensed under the MIT license, which shall be attached to any deliverable of
this software (LICENSE) or can be found here http://www.opensource.org/licenses/MIT 
