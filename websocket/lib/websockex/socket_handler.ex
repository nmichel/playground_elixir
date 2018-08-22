defmodule Websockex.SocketHandler do
  @behaviour :cowboy_websocket_handler

  require Logger
 
  def init(_type, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end
  
  def websocket_init(type, req, opts) do
    Logger.info("Socket init. type #{inspect type} // request #{inspect req} // options #{inspect opts}")
    state = %{}
    {:ok, req, state} # Possibly a 4th parameter : timeout in ms
  end
  
  def websocket_handle(frame = {:text, data}, req, state) do
    Logger.info("Echoing text frame #{inspect data}")
    {:reply, frame, req, state}
  end
  def websocket_handle({type, data}, req, state) do
    Logger.info("Dropping #{inspect type} frame #{inspect data}")
    {:ok, req, state}
  end

  def websocket_info(_msg, req, state) do
    {:ok, req, state}
  end
  
  def websocket_terminate(reason, _req, _state) do
    Logger.info("Socket terminate. reason #{inspect reason}")
    :ok
  end
end
