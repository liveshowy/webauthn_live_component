defmodule WebauthnComponents.SupportComponent do
  @moduledoc """
  A LiveComponent for detecting WebAuthn support.
  """
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <span id="support-component" phx-hook="SupportHook"></span>
    """
  end

  def handle_event("passkeys-supported", boolean, socket) do
    send(socket.root_pid, {:passkeys_supported, boolean})

    {
      :noreply,
      socket
      |> assign(:passkeys_supported, !!boolean)
    }
  end
end
