defmodule StatefulCounterTest do
  use ExUnit.Case
  doctest StatefulCounter

  test "it can be streamed" do
    assert(
      StatefulCounter.new(40)
      |> Stream.take(5)
      |> Stream.filter(&Kernel.rem(&1, 2) == 0)
      |> Enum.into([]) == [40, 42, 44]
    )
  end

  test "it is statefull" do
    counter = StatefulCounter.new
    taken = 5
    assert(
      counter |> Stream.take(taken) |> Stream.map(&Kernel.+(&1, taken)) |> Enum.into([]) == counter |> Stream.take(taken) |> Enum.into([])
    )
  end

  test "it contain initial value" do
    assert(
      StatefulCounter.new(100)
      |> Enum.member?(100)
    )
  end

  test "it does not contain numbers below initial value" do
    refute(
      StatefulCounter.new(100)
      |> Enum.member?(99)
    )
  end

  test "it does contain numbers above initial value" do
    assert(
      StatefulCounter.new(100)
      |> Enum.member?(1000)
    )
  end
end

