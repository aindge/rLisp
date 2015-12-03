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
           when z == ":vars" then puts env.foo;
           when z == ":help" then help;
           when z.split()[0] == ":load" then load_new(z.split()[1], env);
      else begin
          q = Lexer.eval(Lexer.parse(z), env) unless z == ""
          puts q unless ((q.is_a? Lexer::Lambda) or (q.is_a? Proc))
        rescue Lexer::LispSyntaxError => e
          puts "ERROR: " + e.message
        end
      end
    end
  end
  
  def Repl.help
    puts ":help -> Display this menu\n:quit -> Exit\n:vars -> Display local memory"
  end
  
  def Repl.load_new(name)
    raise Lexer::LispSyntaxError, "Load what?" if name.nil?
    begin f = File.new(name, "r")
    rescue
    
    end
  end
end
