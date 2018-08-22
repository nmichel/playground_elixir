defmodule Tuto.GenStage.Linebreak.LineBuilder do
  use GenStage

  # API

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Callbacks

  def init(:ok) do
    {:producer_consumer, "", subscribe_to: [Tuto.GenStage.Linebreak.KeystrokeProducer]}
  end

  def handle_events(keys, _from, acc) do
    {lines, [acc]} =
      acc
      |> Kernel.<>(Enum.join(keys))
      |> String.split(~r/\r\n?|\n/)
      |> Enum.split(-1)
    {:noreply, lines, acc}
  end
end
