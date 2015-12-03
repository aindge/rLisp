module Environment
  class LispEnvironment
    def initialize(env = {})
      @env = env;
    end
  end
  
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
        #:= => lambda{|a, b| a == b ? 1 : 0},
        :car => lambda{|x| x[0] },
        :cdr => lambda{|x| x[1] },
        :cons => lambda{|a| [a[0], a[1]]},
        :cons? => lambda{|x| x.is_a? Array ? 1 : 0},
        :number? => lambda{|x| x.is_a? Numeric ? 1 : 0},
        :null? => lambda{|x| x.nil? ? 1 : 0},
        :eq? => lambda{|a| a[0] == a[1] ? 1 : 0},
        :not => lambda{|x| x == 0 ? 1 : 0},
        :or => lambda{|a| a[0] == 1 or a[1] == 1},
        :and => lambda{|a| a[0] == 1 and a[1] == 1},
        :else => 1,
        :t => 1,
        :T => 1
      })
    end
    
    def data
      return @data
    end
    
    def new_var(name, value = nil)
      raise ArgumentError, "A variable must have a name." if name.nil?
      @data.merge!({name.to_sym => value})
    end
    
    def foo
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
        return outer.find(key)
      else
        return self
      end
    end
  end
end