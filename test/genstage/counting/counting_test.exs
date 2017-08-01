defmodule Tuto.GenStage.CountingTest do
  use ExUnit.Case

  test "Producer and Middle stages yields numbers multiple of 3" do
    {:ok, producer} = Tuto.GenStage.Counting.Producer.start_link(10);
    {:ok, middle} = Tuto.GenStage.Counting.Middle.start_link(&(&1 * 3))
    GenStage.sync_subscribe(middle, to: producer)
    assert(
      [{middle, cancel: :transient}]
      |> GenStage.stream()
      |> Stream.take(3)
      |> Enum.to_list() == [30, 33, 36])
  end
end

