module Forwarder
  module Meta extend self
    def eval_body application, as, to, with
      lambda do |*args, &blk|
        arguments = ( [ with ].flatten + args ).compact
#         rcv = __eval_receiver__( to )
        rcv = Meta.eval_receiver to, self
  #      p as: as, to: to, rcv: rcv, args: arguments, app: application
        rcv.send( as, *arguments, &(application||blk) )
      end
    end
    def eval_receiver name, context
      case name
      when Proc
        context.instance_eval( &name )
      when Array
        name.first
      when String, Symbol
        Meta.eval_symbolic_receiver name, context
      end
    end
    def eval_receiver_body
      lambda do | name |
      end
    end

    def eval_symbolic_receiver name, context
      case "#{name}"
      when /\A@/
        context.instance_variable_get name
      else
        context.send name
      end
    end
  end # module Meta
end # module Forwarder
