require "./lexer.rb"
require "./environment.rb"

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
      z = ask(prompt)
      case z when ":quit", ":q" then return;
             when ":vars", ":v" then puts env.foo;
             when ":help", ":h" then help;
      else begin
          puts Lexer.eval(Lexer.parse(z), env) unless z == ""
        rescue Lexer::LispSyntaxError => e
          puts "ERROR: " + e.message
        end
      end
    end
  end
  
  def Repl.help
    puts ":help -> Display this menu\n:quit -> Exit\n:vars -> Display local memory"
  end
end
