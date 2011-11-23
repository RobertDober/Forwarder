module Forwarder
  module Meta extend self
    def eval_receiver_body
      lambda do | name |
        case name
        when Proc
          instance_eval( &name )
        when Array
          name.first
        when String, Symbol
          Meta.eval_symbolic_receiver name, self
        end
      end
    end

    def eval_symbolic_receiver name, context
      case "#{name}"
      when /\A@/
        context.instance_variable_get name
      else
        context.send name rescue context.private_send name
      end
    end
  end # module Meta
end # module Forwarder
