require 'forwardable'
class Module
  def forward message, opts={}
    return forwarding_with message, opts if opts[:with]
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

  private

  def forwarding_with message, opts
    to = opts.fetch :to do
      raise ArgumentError, "need :to keyword param to indicate target of delegation"
    end
    with = opts[:with]
    as = opts.fetch(:as, message )

    define_method :__eval_receiver__ do | name |
      case "#{name}"
      when /\A@/
        instance_variable_get name
      else
        send name rescue private_send name
      end
    end
    define_method message do |*args, &blk|
      arguments = [ with ].flatten + args
      __eval_receiver__( to ).send( as, *arguments, &blk )
    end
    
  end
  
end # class Module
