defmodule Tuto.GenStage.LinebreakTest do
  use ExUnit.Case
  alias Tuto.GenStage.Linebreak.{KeystrokeProducer, LineBuilder}

  test "Break raw binary into lines" do
    {:ok, io} = StringIO.open("ceci\nest\nun\ntest")
    {:ok, _p} = KeystrokeProducer.start_link(io)
    {:ok, pc} = LineBuilder.start_link()

    assert(
      [{pc, cancel: :transient}]
      |> GenStage.stream()
      |> Stream.take(3)
      |> Enum.to_list() == ["ceci", "est", "un"])
  end
end