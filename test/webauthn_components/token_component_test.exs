defmodule WebauthnComponents.TokenComponentTest do
  use ComponentCase, async: true
  alias WebauthnComponents.TokenComponent

  @endpoint TestEndpoint

  defmodule TokenLiveView do
    use Phoenix.LiveView

    def mount(_session, _params, socket) do
      send_update(TokenComponent, id: "token-component", token: "123456")
      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <.live_component module={TokenComponent} id="token-component" />
      """
    end

    def handle_info(_message, socket) do
      {:noreply, socket}
    end
  end

  setup %{conn: conn} do
    {:ok, view, html} = live_isolated(conn, TokenLiveView, session: %{})
    %{view: view, html: html}
  end

  describe "render/1" do
    test "returns element with id and phx hook", %{html: html} do
      assert html =~ "id=\"token-component\""
      assert html =~ "phx-hook=\"TokenHook\""
    end
  end

  describe "handle_event/3 - token-exists" do
    test "accepts valid payload", %{view: view} do
      assert view
             |> element("#token-component")
             |> render_hook("token-exists", %{"token" => "1234"})
    end
  end

  describe "handle_event/3 - token-stored" do
    test "accepts valid payload", %{view: view} do
      Process.monitor(view.pid)

      receive do
        msg -> IO.inspect(msg)
      end

      assert view
             |> element("#token-component")
             |> render_hook("token-stored", %{"token" => "123456"})
    end
  end

  describe "handle_event/3 - token-cleared" do
    test "accepts valid payload", %{view: view} do
      assert view
             |> element("#token-component")
             |> render_hook("token-cleared", %{"token" => nil})
    end
  end

  describe "handle_event/3 - error" do
    test "accepts valid payload", %{view: view} do
      error = %{
        "message" => "test message",
        "name" => "test name",
        "stack" => %{}
      }

      assert view
             |> element("#token-component")
             |> render_hook("error", error)
    end
  end
end
