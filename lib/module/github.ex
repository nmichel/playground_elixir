defmodule Tuto.Module.GitHub do
  HTTPotion.start
  
  "https://api.github.com/users/nmichel/repos"
  |> HTTPotion.get([headers: ["User-Agent": "Elixir"]])
  |> Map.get(:body)
  |> Poison.decode!
  |> Enum.each fn repo ->
    def unquote(String.to_atom(repo["name"]))() do
      unquote(Macro.escape(repo))
    end
  end
end
