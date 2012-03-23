class Proc
  class << self
    def identity
      new{ |x| x }
    end
  end # class << self
end # class Proc
