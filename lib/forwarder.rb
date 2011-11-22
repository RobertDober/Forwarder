require 'forwardable'
module Forwarder
  def forward message, opts={}, &blk
    opts = opts.merge applying: blk if blk
    return forwarding_with message, opts if opts[:applying] 
    return forwarding_with message, opts if opts[:with]
    return forwarding_to_object message, opts if opts[:to_object]
    to = opts.fetch :to do
      raise ArgumentError, "need :to keyword param to indicate target of delegation"
    end
    extend Forwardable
    as = opts.fetch( :as, message )
    def_delegator to, as, message
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

  def forwarding_to_object message, opts
    target = opts[ :to_object ]
    forwarding_with message, opts.merge( to: [ target ], with: opts.fetch( :with, [] ) )
  end

  def forwarding_with message, opts
#    p opts
    to = opts.fetch :to do
      raise ArgumentError, "need :to keyword param to indicate target of delegation"
    end
    with = opts[:with]
    as = opts.fetch(:as, message )
    application = opts[:applying]

    define_method :__eval_receiver__ do | name |
      if Proc === name
        return instance_eval( &name )
      end
      if Array === name
        return name.first
      end
      case "#{name}"
      when /\A@/
        instance_variable_get name
      else
        send name rescue private_send name
      end
    end
    define_method message do |*args, &blk|
      arguments = ( [ with ].flatten + args ).compact
      rcv = __eval_receiver__( to )
#      p as: as, to: to, rcv: rcv, args: arguments, app: application
      rcv.send( as, *arguments, &(application||blk) )
    end
  end
    
end # class Module
