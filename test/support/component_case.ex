defmodule ComponentCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  setup_all do
    TestEndpoint.start_link()
    :ok
  end

  setup do
    socket = %Phoenix.LiveView.Socket{}
    %{socket: socket}
  end

  using do
    quote do
      import Phoenix.LiveViewTest
      import Phoenix.LiveView.Helpers
      import LiveIsolatedComponent
    end
  end
end
