defmodule WebauthnComponents.AuthenticationComponent do
  @moduledoc """
  A LiveComponent for authentication via WebAuthn API.
  """
  use Phoenix.LiveComponent
  import WebauthnComponents.Icons

  def mount(socket) do
    {
      :ok,
      socket
    }
  end

  def render(assigns) do
    ~H"""
    <button
      id="authentication-component"
      phx-hook="AuthenticationHook"
      phx-target={@myself}
      type="button"
      phx-click="authenticate"
      class={@button_class}
      title="Use an existing account"
      disabled={@passkeys_supported == false}
    >
      <span class="w-4 opacity-70"><.icon_key /></span>
      <span>Authenticate</span>
    </button>
    """
  end

  def handle_event("authenticate", _params, socket) do
    %{endpoint: endpoint} = socket
    %{timeout: timeout} = socket.assigns

    challenge =
      Wax.new_registration_challenge(
        origin: endpoint.url,
        rp_id: :auto,
        user_verification: "preferred"
      )

    challenge_data = %{
      challenge: Base.encode64(challenge.bytes, padding: false),
      timeout: timeout,
      rpId: challenge.rp_id,
      allowCredentials: challenge.allow_credentials,
      userVerification: challenge.user_verification
    }

    {
      :noreply,
      socket
      |> assign(:challenge, challenge)
      |> push_event("passkey-authentication", challenge_data)
    }
  end

  def handle_event("authentication-attestation", payload, socket) do
    %{
      "authenticatorData64" => authenticator_data_64,
      "clientDataArray" => client_data_array,
      "rawId64" => raw_id_64,
      "signature64" => signature_64,
      "type" => type,
      "userHandle64" => user_handle_64
    } = payload

    authenticator_data = Base.decode64!(authenticator_data_64, padding: false)
    raw_id = Base.decode64!(raw_id_64, padding: false)
    signature = Base.decode64!(signature_64, padding: false)
    user_handle = Base.decode64!(user_handle_64, padding: false)

    attestation = %{
      authenticator_data: authenticator_data,
      client_data_array: client_data_array,
      raw_id: raw_id,
      signature: signature,
      type: type,
      user_handle: user_handle
    }

    send(socket.root_pid, {:find_credentials, user_handle: user_handle})

    {
      :noreply,
      socket
      |> assign(:attestation, attestation)
    }
  end

  def handle_event("error", payload, socket) do
    send(socket.root_pid, {:error, payload})
    {:noreply, socket}
  end
end
