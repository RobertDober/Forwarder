require 'forwardable'

require 'forwarder/meta'
module Forwarder

  def forward message, opts={}, &blk
    opts = parse_opts opts, blk
#    p opts: opts
    forward_without_parsing message, opts
  end

  def forward_all *messages, &blk
    opts = messages.pop
    raise ArgumentError, "need a Hash as last arg" unless Hash === opts
    opts = parse_opts opts, blk
    messages.each do | msg |
      forward_without_parsing msg, opts
    end
  end

  def forward_to_self message, opts={}
    forwarding_with message, opts.merge( to: lambda{ |*args| self } )
  end

  private

  def forwarding_to_object message, opts
    target = opts[ :to_object ]
    forwarding_with message, opts.merge( to: Meta::ObjectContainer.new(target), with: opts.fetch( :with, [] ) )
  end

  def forward_with_forwardable message, opts
    to = opts.fetch :to
    extend Forwardable
    as = opts.fetch( :as, message )
    def_delegator to, as, message
  end

  def forward_with_chain message, opts
    return false unless opts[:to_chain]
    forwarding_with message, opts
  end
  # Transform blk into a normal parameter call the metaprogramming
  # stuff if needed and return nil iff we can do it with Forwardable
  def forward_with_meta message, opts
#    p [:forward_with_meta, opts]
    if opts[:applying] || opts[:with]
      forwarding_with message, opts
      true
    elsif opts[:to_object]
      forwarding_to_object message, opts
      true
    end
  end

  # Whenever the forward(s) cannot be implemented by def_delegator(s) eventually
  # this method is called
  def forwarding_with message, opts
#    p opts
    application, as, to, with = opts.values_at( :applying, :as, :to, :with )
    as ||= message

   # define_method( :__eval_receiver__, &Meta.eval_receiver_body )
    define_method( message, &Meta.eval_body( application, as, to, with ) )
  end

  def forward_without_parsing message, opts
#    p [:forward_without_parsing, opts]
    return if forward_with_meta message, opts
    return if forward_with_chain message, opts
    forward_with_forwardable message, opts
  end

  def parse_opts opts, blk
    params = opts.values_at :to_chain, :to, :to_object
    params.compact.tap do | pms |
      if pms.size != 1
        raise ArgumentError, 
          "must passin exactly one of these kwd arguments: :to, :to_object or :to_chain, but found #{pms.join(", ")}"
      end
    end
    opts.update applying: blk if blk
    if params.first
      opts.merge to: params.first
    else
      opts
    end
  end
    
end # class Module
