defmodule Tuto.Macro2 do
    defmodule Unquote do
        IO.puts ~s(#1)

        defmacro defdef(name) do
            IO.puts ~s(#2 - "defdef" expansion [for #{inspect name}] in #{__MODULE__})

            quote bind_quoted: [name: name] do
                IO.puts ~s(#3 - "defdef" code fragment expansion [for #{inspect name}] in #{__MODULE__})
                def unquote(name)() do
                    IO.puts ~s(Calling #{unquote(name)})
                end
                def unquote(name)(arg) do
                    IO.puts ~s(Calling #{unquote(name)} with #{inspect arg})
                end
            end
        end
    end

    defmodule UnquoteTest do
        import Unquote

        v = :foo
        defdef(v)
        defdef(:bar)

        [:neh, :doh]
        |> Enum.each(&defdef(&1))
    end
end

Tuto.Macro2.UnquoteTest.foo
Tuto.Macro2.UnquoteTest.bar 42
Tuto.Macro2.UnquoteTest.neh
Tuto.Macro2.UnquoteTest.doh
