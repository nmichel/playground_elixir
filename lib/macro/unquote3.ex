defmodule Tuto.Macro3 do
  defmodule Unquote do
    IO.puts ~s(#1)
    
    defmacro defdef(name) do
      IO.puts ~s(#2 - "defdef" expansion [for #{inspect name}] in #{__MODULE__})
      
      quote do
        IO.puts ~s(#3 - "defdef" code fragment expansion [for #{inspect unquote(name)}] in #{__MODULE__})
        def unquote(name)(arg) do
          IO.puts ~s(Calling #{unquote(name)} with #{inspect arg})
        end
      end
    end
  end
  
  defmodule UnquoteTest do
    import Unquote
    
    defdef(:foo)
    defdef(:bar)
  end
end

Tuto.Macro3.UnquoteTest.foo 42
Tuto.Macro3.UnquoteTest.bar "42"
