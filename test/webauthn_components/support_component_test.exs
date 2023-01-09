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

  setup %{conn: conn} do
    {:ok, view, html} = live_isolated(conn, TestLiveView, session: %{})
    %{view: view, html: html}
  end

  describe "render/1" do
    test "returns element with id and phx hook", %{html: html} do
      assert html =~ "id=\"support-component\""
      assert html =~ "phx-hook=\"SupportHook\""
    end
  end

  describe "handle_event/3" do
    test "sets `:passkeys_supported` when valid event is received", %{view: view} do
      assert view
             |> element("#support-component")
             |> render_hook("passkeys-supported", %{"supported" => true})
    end

    test "raises when invalid boolean is received" do
    end

    test "raises when invalid event is received" do
    end
  end
end
