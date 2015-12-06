{
  :square => lambda{|x| x[0] * x[0]},
  :sqrt => lambda{|x| begin Math.sqrt(x[0])
    rescue ArgumentError
      raise Lexer::LispSyntaxError, "Argument for sqrt must be a nonnegative integer."
    end
  },
  :sin => lambda{|x| Math.sin(x[0]) }
}