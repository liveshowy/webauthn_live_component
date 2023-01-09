defmodule ComponentCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  setup do
    conn = Phoenix.ConnTest.build_conn()
    socket = %Phoenix.LiveView.Socket{}
    %{conn: conn, socket: socket}
  end

  using do
    quote do
      import Phoenix.LiveViewTest
      import Phoenix.LiveView.Helpers
    end
  end
end
