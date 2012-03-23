require 'forwardable'

require 'forwarder/meta'
require 'forwarder/options'

module Forwarder

  # delegates (forwards) a message to an object (indicated by :to)
  def forward message, opts={}, &blk
    opts = Options.new( opts.update( message: message, blk: blk) )
#    p opts: opts
    forward_without_parsing opts
  end

  def forward_all *messages, &blk
    opts = messages.pop
    raise ArgumentError, "need a Hash as last arg" unless Hash === opts
    messages.each do | msg |
      forward_without_parsing Options.new( opts.merge( message: msg, blk: blk ) )
    end
  end

  def forward_to_self message, opts={}, &blk
    opts = Options.new opts.merge( to: Meta::SelfContainer, blk: blk, message: message )
    # TODO: is the merge below really needed
    forwarding_with opts.merge( with: opts.with( [] ) )
  end

  private

#<<<<<<< HEAD
  def forwarding_to_object opts
#    p [:forwarding_to_object, opts]
    # TODO: Need to get rid of to_object here?
    debugger
    forwarding_with Options.new( opts.merge( to: Meta::ObjectContainer.new(opts.object), with: opts.with( [] ) ) )
  end

  # Whenever the forward(s) cannot be implemented by def_delegator(s) eventually
  # this method is called
  def forwarding_with opts
#    p opts
    application, as, message, to, with = opts.values_at( :applying, :as, :message, :to, :with )
    as ||= message
    to ||= opts.chain?

   # define_method( :__eval_receiver__, &Meta.eval_receiver_body )
    define_method( message, &Meta.eval_body( application, as, to, with ) )
  end

  def forward_with_blk opts
    return false unless opts.blk?
    application, as, message, to, with = opts.values_at( :blk, :as, :message, :to, :with )
    as ||= message
    to ||= opts.chain?
    define_method( message, &Meta.eval_body( application, as, to, with ) )
  end
  def forward_with_forwardable opts
# =======
#   # Triggered by the presence of :to_object in forward's parameters
#   def forwarding_to_object message, opts
#     target = opts[ :to_object ]
#     forwarding_with message, opts.merge( to: Meta::ObjectContainer.new(target), with: opts.fetch( :with, [] ) )
#   end
# 
#   # Handles the cases, where Forwardable can be used behind the scenes
#   # as a matter of fact :to was indicating a method or instance variable
#   # and :as was passed in (or defaults to the original message).
#   def forward_with_forwardable message, opts
#     to = opts.fetch :to
# >>>>>>> master
    extend Forwardable
    def_delegator( *opts.params_for_delegator )
  end

#<<<<<<< HEAD
  def forward_with_chain opts
    return false unless opts.chain?
    if opts.blk?
      forward_with_blk opts
      true
    else
      forwarding_with opts
      true
    end
# =======
#   # Triggered by the presence of :to_chain in forward's parameters
#   def forward_with_chain message, opts
#     return false unless opts[:to_chain]
#     forwarding_with message, opts
# >>>>>>> master
  end
  # Transform blk into a normal parameter call the metaprogramming
  # stuff if needed and return nil iff we can do it with Forwardable
  def forward_with_meta opts
   p [:forward_with_meta, opts]
    if opts.with?
      forwarding_with opts
      true
    elsif opts.object?
      forwarding_to_object opts
      true
    end
  end

  def forward_without_parsing opts
#    p [:forward_without_parsing, opts]
    return if forward_with_meta opts
    return if forward_with_chain opts
    return if forward_with_blk opts
    forward_with_forwardable opts
  end

end # class Module
