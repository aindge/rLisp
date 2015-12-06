require "./environment.rb"

module Lexer
  def Lexer.tokenize(ex)
    #returns an array of tokens.
    return ex.gsub("(", " ( ").gsub(")", " ) ").split()
  end
  
  def Lexer.parse(ex)
    return read_tokens(tokenize(ex))
  end
  
  def Lexer.read_tokens(tokens)
    raise LispSyntaxError, "Unexpected EOF while reading" if tokens.empty?
    token = tokens.shift
    if token == '('
      result = []
      while tokens[0] != ')'
        result << read_tokens(tokens)
      end
      tokens.shift #Chomp ')'
      return result
    elsif token == ')'
      raise LispSyntaxError, "Unexpected ')'"
    else
      return atomize(token)
    end
  end
  
  def Lexer.atomize(token)
    if token == '='
      return :eq?
    elsif token == '#t'
      return true
    elsif token == '#f'
      return false
    else
      begin return Integer(token)
      rescue ArgumentError
        return token.to_f if token.to_f.to_s == token
        return token.to_sym
      end
    end      
  end
  
  def Lexer.eval(x, env, funcall = true)
    if x.nil?
      return nil
    elsif x.is_a?(Symbol) && !env.data[x].nil?
      return env.data[x] 
    elsif !x.is_a? Array
      return x
    elsif x.size == 1 && !x[0].is_a?(Symbol)
      return eval(x[0], env)
    elsif x[0] == :else
      return true
    elsif x[0] == :cond
      raise LispSyntaxError, "Too few arguments for cond." if x.size < 2
      exp = nil
      (1...x.size).each do |i|
        if eval(x[i][0], env)
          exp = x[i][1]
          break;
        end
      end
      return eval(exp, env)
    elsif x[0] == :if
      raise LispSyntaxError, "Too few arguments for if." if x.size != 4
      exp = nil
      if eval(x[1], env)
        exp = x[2]
      else
        exp = x[3]
      end
      return eval(exp, env)
    elsif x[0] == :define.
      env.new_var(x[1], eval(x[2], env))
      return
    elsif x[0] == :set!
      env.find(x[1])[x[1]] = eval(x[2], env)
    elsif x[0] == :lambda
      return Lambda.new(x[1], x[2], env)
    else
      lam = eval(x[0], env)
      raise LispSyntaxError, "Can't find the function " + x[0].to_s unless lam.is_a? Proc or lam.is_a? Lambda
      args = []
      (1...x.size).each do |i|
        args << eval(x[i], env)
      end
      begin return lam.call(args)
      rescue LispArgCountError => e
        if args.size == 0
          return lam
        else
          raise LispSyntaxError, "Wrong number of arguments for #{x[0]} : " + e.message
        end
      rescue StandardError => e
        puts "ERROR: In " + x[0].to_s + " : " + e.message
      end
    end
  end
  
  class Lambda
    def initialize(params, body, env)
      @params = params
      @body = body
      @env = env
    end
    def call(args)
      raise LispArgCountError, "Expected " + @params.size.to_s + ", got " + args.size.to_s + "." unless args.size == @params.size
      q = {}
      (0..@params.size).each do |i|
        q.merge!({@params[i] => args[i]})
      end
      #Lexer.eval because naming conflict :(
      return Lexer.eval(@body, Environment::Vspace.new(@env.data.merge(q), @env))
    end
  end
  
  class LispSyntaxError < StandardError
  end
  
  class LispArgCountError < StandardError
  end
end