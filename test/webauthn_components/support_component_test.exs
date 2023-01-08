defmodule WebauthnComponents.SupportComponentTest do
  use ComponentCase, async: true
  alias WebauthnComponents.SupportComponent

  @endpoint TestEndpoint

  defmodule TestLiveView do
    use Phoenix.LiveView

    def mount(_session, _params, socket) do
      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <.live_component module={SupportComponent} id="support-component" />
      """
    end
  end

  describe "mount/1" do
    test "assigns `:passkeys_supported`", %{socket: socket} do
      assert {:ok, mounted_socket} = SupportComponent.mount(socket)
      assert %{assigns: assigns} = mounted_socket
      assert assigns.passkeys_supported == nil
    end
  end

  describe "render/1" do
    test "returns element with id and phx hook" do
      rendered_component = render_component(SupportComponent, [])
      assert rendered_component =~ "id=\"support-component\""
      assert rendered_component =~ "phx-hook=\"SupportHook\""
    end
  end

  describe "handle_event/3" do
    setup %{conn: conn} do
      {:ok, view, html} = live_isolated(conn, TestLiveView, session: %{})
      %{view: view, html: html}
    end

    test "sets `:passkeys_supported` when valid event is received", %{socket: socket, view: view} do
    end

    test "raises when invalid boolean is received" do
    end

    test "raises when invalid event is received" do
    end
  end
end
