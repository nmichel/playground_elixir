defmodule Tuto.Stream.StatelessCounterTest do
  use ExUnit.Case, async: true

  alias Tuto.Stream.StatelessCounter

  test "it can be streamed" do
    assert(
      %StatelessCounter{counter: 40}
      |> Stream.take(5)
      |> Stream.filter(&Kernel.rem(&1, 2) == 0)
      |> Enum.into([]) == [40, 42, 44]
    )
  end

  test "it is stateless" do
    c = %StatelessCounter{}
    assert(
      c |> Stream.take(5) |> Enum.into([]) == c |> Stream.take(5) |> Enum.into([])
    )
  end

  test "it contain initial value" do
    assert(
      %StatelessCounter{counter: 100}
      |> Enum.member?(100)
    )
  end

  test "it does not contain numbers below initial value" do
    refute(
      %StatelessCounter{counter: 100}
      |> Enum.member?(99)
    )
  end

  test "it does contain numbers above initial value" do
    assert(
      %StatelessCounter{counter: 100}
      |> Enum.member?(1000)
    )
  end
end

