module Forwarder
  module Meta extend self
    # Special Target Representations
    SelfContainer   = Object.new
    ObjectContainer = Struct.new( :object )

    def eval_body application, as, to, with
      lambda do |*args, &blk|
        arguments = ( [ with ].flatten + args ).compact
#         rcv = __eval_receiver__( to )
        rcv = Meta.eval_receiver to, self
#        p as: as, to: to, rcv: rcv, args: arguments, app: application, self: self
        rcv.send( as, *arguments, &(application||blk) )
      end
    end

    def eval_chain names, context
      names.inject context do | ctxt, name |
        Meta.eval_symbolic_receiver name, ctxt
      end
    end

    def eval_receiver name, context
      case name
      when Proc
        context.instance_eval( &name )
      when String, Symbol
#        p name: name, context: context
        Meta.eval_symbolic_receiver name, context
      when SelfContainer
        context
      when ObjectContainer
        name.object
      when Array
        Meta.eval_chain name, context
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
