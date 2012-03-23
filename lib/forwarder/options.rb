module Forwarder
  class Options
    attr_reader :opts, :target
    def after?; opts[:after] end
    def before?; opts[:before] end

    def blk?; opts[:blk] end
    def chain?; opts[:to_chain] end
    def object; opts[:to_object] end
    def object?; opts[:to_object] end

    def merge hashlike
      opts.merge hashlike
    end
    def params_for_delegator
      to = target
      message,as = opts.values_at :message, :as
      as ||= message
#      p [to, message, as]
      [to, as, message]
    end
      
    def values_at *keys
      opts.values_at( *keys )
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
        @target = pms.first
      end
#      @target = params.compact.first
    end

    def legal_key? key
      self.class.legal_keys.include? key
    end

    def legal!
      params = opts.values_at :to_chain, :to, :to_object, :to_self
      check_for_unique_target! params
      if params.first
        opts.merge to: params.first
      else
        opts
      end
      opts.fetch( :message ){ raise ArgumentError, "message not defined, dunno what to send :(" }
    end

    def noillegal!
      error_keys = opts.keys.inject [] do | r, k |
        if legal_key? k
          r
        else
          r << k
        end
      end
      raise ArgumentError, "all these kwds are illeagal #{error_keys.inspect}, legal kwds are #{self.class.legal_keys.inspect}" unless
        error_keys.empty?
    end  
    
    def initialize opts
      @opts = opts
      noillegal!
      legal!
    end
    

    class << self
      def legal_keys
        @__legal_keys__ ||= [:after, :applying, :as, :before, :blk, :message, :to, :to_chain, :to_object, :with]
      end
    end
  end # class Options
end # module Forwarder
