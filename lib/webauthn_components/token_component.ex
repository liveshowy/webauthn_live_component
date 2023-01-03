defmodule WebauthnComponents.TokenComponent do
  @moduledoc """
  A LiveComponent for handling session tokens.
  """
  use Phoenix.LiveComponent

  def mount(socket) do
    {
      :ok,
      socket
      |> assign_new(:token, fn -> nil end)
    }
  end

  @doc """
  Stores or clears a session token.

  When a `:token` assign is received, this function will either clear or store the user's token.

  - Assign `token: :clear` to remove a user's token.
  - Assign a binary token (typically a base64-encoded crypto hash) to persist a user's token to the browser's `sessionStorage`.
  - Invalid token assigns will be logged and the socket will be returned unchanged.
  """
  def update(%{token: token} = _assigns, socket) do
    cond do
      token == :clear ->
        {
          :ok,
          socket
          |> push_event("clear-token", %{token: token})
        }

      is_binary(token) ->
        {
          :ok,
          socket
          |> push_event("store-token", %{token: token})
        }

      true ->
        {:ok, socket}
    end
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def render(assigns) do
    ~H"""
    <span id="token-component" phx-hook="TokenHook"></span>
    """
  end

  def handle_event("token-exists", payload, socket) do
    %{"token" => token} = payload
    send(socket.root_pid, {:token_exists, token: token})
    {:noreply, socket}
  end

  def handle_event("token-stored", payload, socket) do
    %{"token" => token} = payload
    send(socket.root_pid, {:token_stored, token: token})
    {:noreply, socket}
  end

  def handle_event("token-cleared", _payload, socket) do
    send(socket.root_pid, {:token_cleared})
    {:noreply, socket}
  end
end