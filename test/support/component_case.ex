defmodule ComponentCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  setup_all do
    TestEndpoint.start_link()
    :ok
  end

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
