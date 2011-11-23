class Proc
  class << self
    def identity
      new{ |x| x }
    end
    def sum
      new{ |a,b| a+b }
    end
  end # class << self
end # class Proc
