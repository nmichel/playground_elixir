defmodule Tuto.GenStage.Counting.ProducerTest do
  use ExUnit.Case
  doctest Tuto.GenStage.Counting.Producer

  test "Producer stage yields numbers starting from 10" do
    {:ok, producer} = Tuto.GenStage.Counting.Producer.start_link(10);
    assert(
      [{producer, cancel: :transient}]
      |> GenStage.stream()
      |> Stream.take(3)
      |> Enum.to_list() == [10, 11, 12])
  end

  test "Producer stage yields numbers starting from 0" do
    {:ok, producer} = Tuto.GenStage.Counting.Producer.start_link(0);
    assert(
      [{producer, cancel: :transient}]
      |> GenStage.stream()
      |> Stream.take(4)
      |> Enum.to_list() == [0, 1, 2, 3])
  end
end

