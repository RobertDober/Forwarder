require 'forwardable'

require 'forwarder/meta'
module Forwarder

  def forward message, opts={}, &blk
    return if forward_with_meta message, opts, blk
    forward_with_forwardable message, opts
  rescue IndexError
    raise ArgumentError, "need :to keyword param to indicate target of delegation"
  end

  def forward_all *messages
    opts = messages.pop
    raise ArgumentError, "need a Hash as last arg" unless Hash === opts
    to = opts.fetch :to do
      raise ArgumentError, "need :to keyword param to indicate target of delegation"
    end
    extend Forwardable
    messages.each do | msg |
      def_delegator to, msg, msg
    end
  end

  def forward_to_self message, opts={}
    forwarding_with message, opts.merge( to: lambda{ |*args| self } )
  end

  private

  def forward_with_forwardable message, opts
    to = opts.fetch :to
    extend Forwardable
    as = opts.fetch( :as, message )
    def_delegator to, as, message
  end

  # Transform blk into a normal parameter call the metaprogramming
  # stuff if needed and return nil iff we can do it with Forwardable
  def forward_with_meta message, opts, blk
    opts = opts.merge applying: blk if blk
    if opts[:applying] || opts[:with]
      forwarding_with message, opts
      true
    elsif opts[:to_object]
      forwarding_to_object message, opts
      true
    end
  end

  def forwarding_to_object message, opts
    target = opts[ :to_object ]
    forwarding_with message, opts.merge( to: [ target ], with: opts.fetch( :with, [] ) )
  end

  def forwarding_with message, opts
#    p opts
    to = opts.fetch :to do
      raise ArgumentError, "need :to keyword param to indicate target of delegation"
    end
    application, as, with = opts.values_at( :applying, :as, :with )
    as ||= message

   # define_method( :__eval_receiver__, &Meta.eval_receiver_body )
    define_method( message, &Meta.eval_body( application, as, to, with ) )
  end
    
end # class Module
