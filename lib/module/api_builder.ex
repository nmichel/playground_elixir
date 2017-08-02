defmodule Tuto.Module.ApiBuilder do
  defmacro __using__(_opt) do
    quote do
      import unquote(__MODULE__)

      @parser ~r/(?<name>\D+\w*)\((?<params>.*)\)/
    end
  end

  def build_param_list(names, mod) do
    names |> Enum.map(&({&1, [], mod}))
  end

  defmacro buildEntry(spec) do
    quote bind_quoted: [spec: spec] do
      %{"name" => namestr, "params" => params} = Regex.named_captures(@parser, spec)

      name = String.to_atom(namestr)
      param_atoms = params |> String.split(",", trim: true) |> Stream.map(&String.trim/1) |> Enum.map(&String.to_atom/1)
      param_asts = param_atoms |> build_param_list(__MODULE__)

      def unquote(name)(unquote_splicing(param_asts)) do
        [unquote(param_atoms), unquote(param_asts)]
        |> Stream.zip()
        |> Map.new()
      end
    end
  end
end
