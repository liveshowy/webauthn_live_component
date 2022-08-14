defmodule ComponentCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  setup do
    :ok
  end

  using do
    quote do
      import Phoenix.LiveViewTest
      import Phoenix.LiveView.Helpers
    end
  end
end
