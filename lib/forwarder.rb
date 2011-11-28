require 'forwardable'

require 'forwarder/meta'
module Forwarder

  def forward message, opts={}, &blk
    opts = parse_opts message, opts, blk
#    p opts: opts
    forward_without_parsing opts
  end

  def forward_all *messages, &blk
    opts = messages.pop
    raise ArgumentError, "need a Hash as last arg" unless Hash === opts
    opts = parse_opts nil, opts, blk
    messages.each do | msg |
      forward_without_parsing( opts.merge( message: msg ) )
    end
  end

  def forward_to_self message, opts={}, &blk
    opts = parse_opts message, opts.merge( to_self: true), blk
    forwarding_with opts.merge( to: Meta::SelfContainer, with: opts.fetch( :with, [] ) )
  end

  private

  def forwarding_to_object opts
#    p [:forwarding_to_object, opts]
    forwarding_with opts.merge( to: Meta::ObjectContainer.new(opts[:to_object]), with: opts.fetch( :with, [] ) )
  end

  # Whenever the forward(s) cannot be implemented by def_delegator(s) eventually
  # this method is called
  def forwarding_with opts
#    p opts
    application, as, message, to, with = opts.values_at( :applying, :as, :message, :to, :with )
    as ||= message

   # define_method( :__eval_receiver__, &Meta.eval_receiver_body )
    define_method( message, &Meta.eval_body( application, as, to, with ) )
  end

  def forward_with_forwardable opts
    extend Forwardable
    to, message = opts.values_at :to, :message
    as = opts.fetch( :as, message )
    def_delegator to, as, message
  end

  def forward_with_chain opts
    return false unless opts[:to_chain]
    forwarding_with opts
  end
  # Transform blk into a normal parameter call the metaprogramming
  # stuff if needed and return nil iff we can do it with Forwardable
  def forward_with_meta opts
#    p [:forward_with_meta, opts]
    if opts[:applying] || opts[:with]
      forwarding_with opts
      true
    elsif opts[:to_object]
      forwarding_to_object opts
      true
    end
  end

  def forward_without_parsing opts
#    p [:forward_without_parsing, opts]
    return if forward_with_meta opts
    return if forward_with_chain opts
    forward_with_forwardable opts
  end

  def parse_opts msg, opts, blk
    opts.update message: msg
    params = opts.values_at :to_chain, :to, :to_object, :to_self
    params.compact.tap do | pms |
      if pms.size != 1
        raise ArgumentError, 
          "must passin exactly one of these kwd arguments: :to, :to_object, :to_self or :to_chain, but found #{pms.join(", ")}"
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
