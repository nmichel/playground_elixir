defmodule Tuto.GenStage.Counting.Producer do
  use GenStage

  def start_link(base) do
    GenStage.start_link(__MODULE__, base)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, counter) do
    events = Enum.to_list(counter..counter+demand-1)
    {:noreply, events, counter + demand}
  end
end
