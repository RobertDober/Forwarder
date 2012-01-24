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

## Parameters ##

The first parameter, (or paramters in the case of `forward_all`) is (are)
a symbol(s) or string(s) indicating the message to be forwarded. That is
a message of which the receiver is an instance of the module in which
`forward` was called.

Ater this we have a hash style parameter which needs a *target* specification,
indicated by `:to`, `:to_chain` or `:to_object`. It can contain an optional
`:as` parameter translating the method name and an equally optional `:with`
paramter allowing us to provide paramters to the forwarded message.
I refer to the `:as` parameter as the *translation* and the `:with` parameter
as the *parametrization*.

This might be confusing at first, but the follwing examples shall demonstrate
how simple things really are.


## Examples ##

### The forward Method ###

#### Target specified with :to ####

The `:to` keyword parameter and can be either a `Symbol` (or `String`), thus representing 
an instance method or an instance variable of the receiver. It can also be a lambda that 
will be evaluated in the receiver's context. If an arbitrary object shall be the receiver of the
message, than the `:to` keyword can be replaced by the `:to_object`, and if the target of
the message shall bet the result of chained method calls on the receiver `:to_chain` is
at your service.

       class Employee
         extend Forwarder
         forward :complaints, to: :boss
       end

This design, implementing some wishful thinking that will probably not pass
acceptance tests, will forward the ```complaints``` message, sent to an instance
of ```Employee```, to the object returned by this very instance's ```boss``` method.

As feared the implementation did not live up to the expectations (hence the desperate
need of foraml specifications) and the following adjustment was made, in some desperate 
hope to fix the *bug*:

      class Employee
        extend Forwarder
        forward :complaints, to: :boss, as: :suggestions
      end

This behavior being clearly preferable to the one implemented before because the
receiver of ```complaints``` is still forwarding the call to the result of the
call of its ```boss``` method, but to it's `suggestions` method. (Well that is
not precise wording, but we shall make an abstraction about how the object returned
by `boss` handles the `suggestions` message.)

Finally, however, the implementation looked like this

      class Boss
        extend Forwarder
        forward :complaints, to: first_employee
        forward :problems, to: first_employee
        forward :tasks, to: first_employee
      end

However this did not work as no `first_employee` was defined yet. This seems
a task so simple that a method for this seems almost too much code. 
Forwarder let us allow an implementation on itself.
The other thing that catches (or should, at least) the reader's eye is the terrible code repetition.
To get rid of it, we will indulge us by looking ahead to the `forward_all` method, which of course
is just short for three `forward` calls with each of its positional parameters.

      class Boss
        extend Forwarder
        forward :first_employee, to: :@employees, as: :[], with: 0
        forward_all :complaints, :problems, :tasks, to: :first_employee
      end

Here we see the first use case of a *parametrization*, paired with a *translation*.
Please note that the first does not necessarily imply the second, the following example
might be reasonable code.

      class Train
        extend Forwarder
        forward :signal, to: :@signaller, with: {strength: 10, tone: 42}
      end

As a side note, I do not enourage the exposure of instance variables as in the
examples above, but it still might make your code shorter, which is an asset
of its own of course. Furthermore it allows a faster transation from `Forwardable`
if it is used to delegate to instance variables.
      
The above `Boss` case was badely written of course as `Array#first` gives us the
perfect opportunity to get rid of the `with:` parameter, which is somehow a little
bit of a code smell, I admit. Let us do better:

      class Boss
        extend Forwarder
        forward :first_employee, to: :@employees, as: :first
        forward_all :complaints, :problems, :tasks, to: first_employee
      end


### forward_all ###

`forward_all` allows us to forward more then one message to a target. It is a shortcut
for calling `forward` to each of its method parameters. As one can see in the next
example it supports all kinds of target parameters, :to, :to_chain, but also :to_object

#### Target :to_chain ####

The example above is still too verbose. For what we know there is no need to define a
delagation for the `first_employee` method. And this is the use case where `:to_chain`
seems the right tool to use, let us see it's application at work:

      class Boss
        extend Forwarder
        forward_all :complaints, :problems, :tasks, to_chain: [:@employees, :first]
      end

As you might guess, the `complaints` message is sent to the result of sending `first`
to the `@employees` instance variable. As (no pun intended) with the `to:` version
of `forward`, one can change the message name with the `as:` parameter.

It is uncommon, but not impossible to use a *translation* in `forward_all`

      class Boss
        extend Forwarder
        forward_all :complaints, :problems, :tasks, 
                    to_chain: [:@employees, :first],
                    as: :request
      end

Here we go, seems quite a realistic model to me.


## Performance ##

If you are concerned about performance, but you should not yet, I have good news for you. Using
`Forwarder` will be a performance hit. Now why should that be good news? Well it is good news
for two reasons. Firstly by using `Forwarder` the performance hit notwithstanding you show that
you are not concerned by premature optimization but much more with clean, concise and readnale
design. Secondly if you run into performance issues and profiling shows that a forward target
is hit frequently, chances are that you found one of your performance bottlenecks. Just implement
the forward lmanually as a method and you shoud see quite some improvement. Now I am sure
you'd wish that all your performance issues are *that* *easy* to fix.

As I said: *Two* pieces of Good News!

## License ##

This software is licensed under the MIT license, which shall be attached to any deliverable of
this software (LICENSE) or can be found here http://www.opensource.org/licenses/MIT 
