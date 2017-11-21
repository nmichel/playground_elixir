# As per great article http://www.east5th.co/blog/2017/10/30/grokking-the-y-combinator-with-elixir/
# See Tuto.YTest for a progressive makingoff of this function.

defmodule Tuto.Y do
  def y(f) do
    (fn
      x ->
        x.(x)
    end).(fn
      x ->
        f.(fn
          t ->
            (x.(x)).(t)
        end)
    end)
  end
end
