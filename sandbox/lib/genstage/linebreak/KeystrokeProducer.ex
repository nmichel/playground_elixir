defmodule Tuto.GenStage.Linebreak.KeystrokeProducer do
  use GenStage

  ## API

  def loop(io) do
    case IO.getn(io, "> ", 1) do
      :eof ->
        :ok
      c ->
        sync_notify(c)
        loop(io)
    end
  end

  def start_link(io \\ :stdio) do
    r = {:ok, pid} = GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
    send pid, {:boot, io}
    r
  end

  def sync_notify(event) do
    GenStage.call(__MODULE__, {:notify, event}, :infinity)
  end

  ## Callbacks

  def init(:ok) do
    {:producer, {:queue.new, 0}}
  end

  def handle_call({:notify, event}, from, {queue, pending_demand}) do
    queue = :queue.in({from, event}, queue)
    dispatch_events(queue, pending_demand, [])
  end

  def handle_demand(new_demand, {queue, pending_demand}) do
    dispatch_events(queue, new_demand + pending_demand, [])
  end

  def handle_info({:boot, io}, state) do
    {:ok, _pid} = Task.start_link(__MODULE__, :loop, [io])
    {:noreply, [], state}
  end

  ## Internals

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, {from, event}}, queue} -> 
        GenStage.reply(from, :ok)
        dispatch_events(queue, demand-1, [event | events])
      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end
end
