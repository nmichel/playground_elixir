defmodule Tuto.GenStage.Counting.Middle do
  use GenStage

  def start_link(transfoFn) do
    GenStage.start_link(__MODULE__, transfoFn)
  end

  def init(transfoFn) do
    {:producer_consumer, transfoFn}
  end

  def handle_events(events, _from, transfoFn) do
    events = Enum.map(events, transfoFn)
    {:noreply, events, transfoFn}
  end

  def handle_cancel({:down, :normal}, _from, state) do
    {:noreply, [], state}
  end

  def handle_cancel({:cancel, :normal}, _from, state) do
    {:noreply, [], state}
  end
end
