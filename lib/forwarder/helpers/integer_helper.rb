class Integer
  class << self
    def pred
      lambda{ |a| a.pred }
    end
    def succ
      lambda{ |a| a.succ }
    end
    def sum
      lambda{ |a,b| a+b }
    end
  end # class << self
end # class Proc
