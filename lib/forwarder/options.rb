module Forwarder
  class Options
    attr_reader :opts, :target
    def chain?; opts[:to_chain] end
    def object; opts[:to_object] end
    def object?; opts[:to_object] end

    def params_for_delegator
      to = target
      message,as = opts.values_at :message, :as
      as ||= message
#      p [to, message, as]
      [to, message, as]
    end
      
    def with defval=nil
      opts.fetch( :with, defval )
    end
    def with?
      with( false ) || opts[:applying ]
    end
    private
    def check_for_unique_target! params
      params.compact.tap do | pms |
        if pms.size != 1
          raise ArgumentError, 
            "must passin exactly one of these kwd arguments: :to, :to_object, :to_self or :to_chain, but found #{pms.join(", ")}"
        end
      end
      @target = params.compact.first
    end

    def legal!
      params = opts.values_at :to_chain, :to, :to_object, :to_self
      check_for_unique_target! params
      if params.first
        opts.merge to: params.first
      else
        opts
      end
    end
      
    def initialize msg, opts, blk
      @opts = opts.dup
      parse_opts msg, blk
#      p [:initialize, self.opts]
    end

    def parse_opts msg, blk
      opts.update message: msg
      legal!
      opts.update applying: blk if blk
    end
    
  end # class Options
end # module Forwarder
