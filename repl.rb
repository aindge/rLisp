require "./lexer.rb"
require "./environment.rb"
require "readline"

module Repl
  def Repl.ask(prompt)
    print prompt
    return gets.strip
  end

  def Repl.go(prompt = "rLisp> ")
    #Main Read-Eval-Print Loop
    puts "rLisp is a Lisp/Scheme interpreter. ':quit' to quit, ':help' for more."
    env = Environment::Vspace.new
    while(true)
      #Get query
      z = Readline.readline(prompt, true)
      case when z == ":quit" then return;
           when z == ":vars" then puts env.print_space;
           when z == ":help" then puts help;
           when z.split()[0] == ":run" then run_lisp(z.split()[1], env);
           when z.split()[0] == ":load" then load_ruby(z.split()[1], env);
      else begin
          q = Lexer.eval(Lexer.parse(z), env) unless z == ""
          puts q unless ((q.is_a? Lexer::Lambda) or (q.is_a? Proc))
        rescue Lexer::LispSyntaxError => e
          puts "ERROR: " + e.message
        end
      end
    end
  end
  
  def Repl.run_lisp(name, env)
    if name.nil?
      puts "ERROR: Need a filename. Try typing :run my_lisp.lisp"
      return nil
    end
    begin f = File.new(name, "r")
    rescue
      puts "ERROR: '" + name + "' can't be found."
    end
    z = f.read
    begin
      q = Lexer.eval(Lexer.parse(z), env) unless z == ""
      puts q unless ((q.is_a? Lexer::Lambda) or (q.is_a? Proc))
    rescue Lexer::LispSyntaxError => e
      puts "ERROR: " + e.message
    end
  end
  
  def Repl.load_ruby(name, env)
    if name.nil?
      puts "ERROR: Need a filename. Try typing :load my_ruby.rb"
      return nil
    end
    begin f = File.new(name, "r")
    rescue
      puts "ERROR: '" + name + "' can't be found."
    end
    z = f.read
    begin 
      q = eval(z)
      if not q.is_a? Hash
        puts "ERROR: Loaded ruby needs to be in a hash {:symbol => lambda or constant value}"
        return 
      end
      q.each do |key, value|
        if not (key.is_a?(Symbol) and (value.is_a?(Proc) or value.is_a?(Numeric) or value.is_a(Boolean)))
          puts "ERROR: Loaded ruby needs to be in a hash {:symbol => lambda or constant value}"
          return 
        end
        env.new_var(key.to_s, value)
      end
    rescue StandardError => e
      puts "ERROR: Something in your file caused an exception."
      puts e.message
      puts e.backtrace
    end
  end
  
  def Repl.help
    "
    :help -> Display this information
    
    :quit -> Exit rLisp
    
    :vars -> Display working memory
      car : CAR is a function.
      pi : 3.14 is a constant.
    
    :run [filename] -> Runs lisp code located at filename.
      This affects working memory. As such, it's useful to define functions. 
      File might contain:
        (define square (lambda (x) (* x x)))
      
      So you can later call:
        (square 3) => 9
        
      Note that if there are symbols in the given Lisp code, rLisp will assume 
        they are in working memory when the function is evaluated.
    
    :load [filename] -> Loads filename, which contains ONLY a Ruby hash, into the working memory.
      Each element in the hash should be as follows:
      :constant_name => 3
      :function_name => lambda{|x| x[0]}
      
      rLisp handles Ruby integers, floats, booleans, and symbols as Lisp objects. Your function should return one of these.
      
      For functions, rLisp will pass in an array of arguments. Therefore:
      
      :equals? => lambda{|a,b| a == b} is INCORRECT
      :equals? => lambda{|a| a[0] == a[1]} is CORRECT
      
      Note that due to the way Ruby handles symbols, some names are invalid and will cause an error.
    "
  end
end
