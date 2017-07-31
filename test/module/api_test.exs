defmodule Tuto.Module.ApiTest do
  use ExUnit.Case
  doctest Tuto.Module.Api.Builder

  defmodule Api do
    use Tuto.Module.Api.Builder
    alias Tuto.Module.Api.Builder, as: Builder

    "./test/module/api.txt"
    |> File.stream!()
    |> Enum.each(&Builder.buildEntry/1)

    f = fn -> "test()" end
    buildEntry(f.())
  end

  test "Generated module functions return call parameters values" do
    assert Api.foo() == %{}
    assert Api.bar(1, 2) == %{a: 1, b: 2}
    assert Api.neh(:a, :b, :c) == %{a: :a, b: :b, c: :c}
  end

  test "Generated module functions have expected arity" do
    assert Api.__info__(:functions)[:foo] == 0
    assert Api.__info__(:functions)[:bar] == 2
    assert Api.__info__(:functions)[:neh] == 3
  end

  test "Generated module functions have expected parameters names" do
    assert Api.bar(1, 2) |> Map.keys() |> Enum.sort() == [:a, :b]
    assert Api.foo() |> Map.keys() == []
    assert Api.neh(1, 2, 3) |> Map.keys() |> Enum.sort() == [:a, :b, :c]
  end

  test "Dyn module functions test" do
    assert Api.test() == %{}
  end
end
