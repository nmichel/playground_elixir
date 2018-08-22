defmodule Tuto.GenStage.Counting.MiddleTest do
  use ExUnit.Case
  doctest Tuto.GenStage.Counting.Middle

  test "Middle stage multiplies input data by 2" do
    {:ok, consumer} = Tuto.GenStage.Counting.Middle.start_link(&(&1 * 2))
    {:ok, producer} = GenStage.from_enumerable([1, 2, 3])
    GenStage.sync_subscribe(consumer, to: producer)
    assert(
      [{consumer, cancel: :transient}]
      |> GenStage.stream()
      |> Enum.to_list() == [2, 4, 6])
  end

  test "Middle stage add 5 to input data" do
    {:ok, consumer} = Tuto.GenStage.Counting.Middle.start_link(&(&1 + 5))
    {:ok, producer} = GenStage.from_enumerable([1, 2, 3])
    GenStage.sync_subscribe(consumer, to: producer)
    assert(
      [{consumer, cancel: :transient}]
      |> GenStage.stream()
      |> Enum.to_list() == [6, 7, 8])
  end
end

