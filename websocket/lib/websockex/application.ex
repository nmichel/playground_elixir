defmodule Websockex.Application do
  @moduledoc false

  use Application

  @impl
  def start(_type, _args) do
    children = [
      {Plug.Adapters.Cowboy, scheme: :http, plug: Websockex.Router, options: [dispatch: dispatch(), port: 6001]}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one, name: Websockex.Supervisor])
  end

  defp dispatch do
    [
      {
        :_, [
          {"/ws", Websockex.SocketHandler, []},
          {:_, Plug.Adapters.Cowboy.Handler, {Websockex.Router, []}}
        ]
      }
    ]
  end
end
