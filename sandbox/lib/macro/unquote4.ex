defmodule Tuto.Macro4 do
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
    
    c = quote do
      [:foo]
      |> Enum.stream(&defdef(&1))
      # defdef(:foo)
    end
    IO.puts ~s(Quote code:\n #{inspect c}\n)
  end
end
