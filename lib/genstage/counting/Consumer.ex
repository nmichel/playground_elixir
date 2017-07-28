defmodule Tuto.GenStage.Counting.Consumer do
  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    {:consumer, :ok}
  end

  def handle_events(events, _from, state) do
    IO.inspect(events)
    {:reply,  [], state}
  end
end
