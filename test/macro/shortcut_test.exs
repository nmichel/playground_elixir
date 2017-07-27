defmodule ShortcutTest do
  use ExUnit.Case
  doctest Shortcut
  import Kernel, except: [defmodule: 2]
  use Shortcut, root: Toto.Titi.Tutu

  defmodule MyMod do
    def foo do
      42
    end
  end

  test "it add the root prefix to module name" do
    assert Elixir.Toto.Titi.Tutu.MyMod.foo == 42
  end

  defmodule2 MyMod2 do
    def foo do
      PI
    end
  end

  test "it add the root prefix to module name evene with bind_quoted" do
    assert Elixir.Toto.Titi.Tutu.MyMod2.foo == PI
  end
end
