module Environment
  
  class Vspace
    def initialize(data = {}, outer = nil)
      @outer = outer
      @data = data
      #Add default values
      @data.merge!({
        :+ => lambda{|a| a[0] + a[1]},
        :- => lambda{|a| a[0] - a[1]},
        :* => lambda{|a| a[0] * a[1]},
        :/ => lambda{|a| a[0] / a[1]},
        :< => lambda{|a| a[0] < a[1] ? 1 : 0},
        :> => lambda{|a| a[0] > a[1] ? 1 : 0},
        #:= => lambda{|a, b| a == b ? 1 : 0},
        :car => lambda{|x| x[0][0] },
        :cdr => lambda{|x| x[0][1] },
        :cons => lambda{|a| [a[0], a[1]]},
        :cons? => lambda{|x| (x[0].is_a?(Array) and x[0].size == 2)},
        :list? => lambda{|x| (x[0].is_a?(Array) and x[0].size == 2)},
        :number? => lambda{|x| x[0].is_a?(Numeric)},
        :null? => lambda{|x| x[0].nil?},
        :eq? => lambda{|a| (a[0] == a[1])},
        :not => lambda{|x| (x[0].nil?)},
        :or => lambda{|a| ((a[0]) or (a[1]))},
        :and => lambda{|a| ((a[0]) and (a[1]))}
      })
    end
    
    def data
      return @data
    end
    
    def new_var(name, value = nil)
      raise ArgumentError, "A variable must have a name." if name.nil?
      @data.merge!({name.to_sym => value})
    end
    
    def print_space
      z = ""
      @data.each do |key, value|
        if !value.is_a?(Proc) and !value.is_a?(Lexer::Lambda)
          z << key.to_s + " : " + value.inspect + "\n"
        else
          z << key.to_s + " : " + key.to_s.upcase + "\n"
        end
      end
      return z
    end
    
    def find(key)
      if @data[key].nil?
        return @outer.find(key) unless @outer.nil?
        return nil
      else
        return self
      end
    end
  end
end