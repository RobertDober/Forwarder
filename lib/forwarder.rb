require 'forwardable'

require 'forwarder/meta'
require 'forwarder/options'

module Forwarder

  def forward message, opts={}, &blk
    opts = Options.new message, opts, blk
#    p opts: opts
    forward_without_parsing opts
  end

  def forward_all *messages, &blk
    opts = messages.pop
    raise ArgumentError, "need a Hash as last arg" unless Hash === opts
    messages.each do | msg |
      forward_without_parsing Options.new( opts.merge( message: msg ) )
    end
  end

  def forward_to_self message, opts={}, &blk
    opts = Options.new message, opts.merge( to: Meta::SelfContainer ), blk
    # TODO: is the merge below really needed
    forwarding_with opts.merge( with: opts.with( [] ) )
  end

  private

  def forwarding_to_object opts
#    p [:forwarding_to_object, opts]
    forwarding_with opts.merge( to: Meta::ObjectContainer.new(opts.object), with: opts.with( [] ) )
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
    def_delegator( *opts.params_for_delegator )
  end

  def forward_with_chain opts
    return false unless opts.chain?
    forwarding_with opts
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
    forward_with_forwardable opts
  end

end # class Module
