defmodule WebauthnComponents.SupportComponentTest do
  use ComponentCase, async: true
  alias WebauthnComponents.SupportComponent

  @endpoint TestEndpoint

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
    test "sets `:passkeys_supported` when valid event is received" do
      assert {:ok, view, _html} = live_isolated_component(SupportComponent)

      view
      |> assert_handle_event("passkeys-supported", true)
      |> assert_handle_event_return(true)
    end

    test "raises when invalid boolean is received" do
    end

    test "raises when invalid event is received" do
    end
  end
end
