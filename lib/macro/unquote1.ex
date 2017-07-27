defmodule Tuto.Macro1 do
    defmodule Unquote do
        IO.puts ~s(#1)

        defmacro defdef(name, do: block) do
            IO.puts ~s(#4 - "defdef" expansion [for #{inspect name}] in #{__MODULE__})
            quote do
                unquote(IO.puts ~s(#5 - "defdef" expansion [for AST #{inspect name}] in #{__MODULE__}))
                def unquote(name) do
                    unquote(block)
                end
            end
        end

        def foo do
            IO.puts ~S("foo" is called)
            unquote(IO.puts ~s(#2 - "foo" expansion in #{__MODULE__}))
        end

        def bar do
            IO.puts ~s("bar" is called)
            unquote(IO.puts ~s(#3 - "bar" expansion in #{__MODULE__}))
        end
    end

    defmodule UnquoteTest do
        import Unquote

        defdef neh do
            IO.puts ~s("neh" is called)
            unquote(IO.puts ~s(#6 - "neh" expansion in #{__MODULE__}))
        end

        defdef doh do
            IO.puts ~s("doh" is called)
            unquote(IO.puts ~s(#7 - "doh" expansion in #{__MODULE__}))
        end
    end
end

Tuto.Macro1.Unquote.foo
Tuto.Macro1.Unquote.bar
Tuto.Macro1.UnquoteTest.neh
Tuto.Macro1.UnquoteTest.doh
