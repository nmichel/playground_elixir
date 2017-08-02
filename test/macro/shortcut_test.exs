defmodule Tuto.Macro.ShortcutTest do
  use ExUnit.Case
  import Kernel, except: [defmodule: 2]
  alias Tuto.Macro.Shortcut
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
