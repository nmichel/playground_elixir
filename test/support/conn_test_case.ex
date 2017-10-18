defmodule Tuto.Plug.ConnTestCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: true
      use Plug.Test
    end
  end
end
