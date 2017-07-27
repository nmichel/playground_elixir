defmodule Shortcut do
    import Kernel, except: [defmodule: 2]

    defmacro __using__(root: root) do
        quote do
            import unquote(__MODULE__)
            Module.register_attribute __MODULE__, :root, []
            @root unquote(root)
        end
    end

    defmacro defmodule(name, do: block) do
        quote do
            modname = Atom.to_string(unquote(name))
            mod = 
                case modname do
                    "Elixir." <> rest ->
                        String.to_atom(rest)
                    _ ->
                        unquote(name)
                end
            real_mod_name = [@root, mod]
            |> Enum.map(&Atom.to_string/1)
            |> Enum.join(".")
            |> String.to_atom

            Kernel.defmodule(real_mod_name, do: unquote(block))
        end
    end

    defmacro defmodule2(name, do: block) do
        quote bind_quoted: [name: name, block: Macro.escape(block)], unquote: true do
            modname = Atom.to_string(name)
            mod = 
                case modname do
                    "Elixir." <> rest ->
                        String.to_atom(rest)
                    _ ->
                        name
                end
            real_mod_name = [@root, mod]
            |> Enum.map(&Atom.to_string/1)
            |> Enum.join(".")
            |> String.to_atom

            Kernel.defmodule(real_mod_name, do: unquote(block))
        end
    end
end
