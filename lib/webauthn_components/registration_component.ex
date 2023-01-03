defmodule WebAuthnComponents.RegistrationComponent do
  @moduledoc """
  A LiveComponent for registering a new Passkey via the WebAuthn API.
  """
  use Phoenix.LiveComponent
  import WebAuthnComponents.Icons
  alias Wax.Challenge

  @type assigns :: %{
          user: struct() | map() | nil,
          challenge: Challenge.t() | nil
        }

  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:challenge, fn -> nil end)
      |> assign_new(:user, fn -> nil end)
    }
  end

  def render(assigns) do
    ~H"""
    <button
      id="registration-component"
      phx-hook="RegistrationHook"
      phx-target={@myself}
      type="button"
      phx-click="register"
      class={@button_class}
      title="Create a new account"
      disabled={@passkeys_supported == false}
    >
      <span class="w-4 opacity-70"><.icon_key /></span>
      <span>Register</span>
    </button>
    """
  end

  def handle_event("register", _params, socket) do
    %{endpoint: endpoint} = socket
    app_name = socket.assigns[:app]
    attestation = "none"

    user_handle = :crypto.strong_rand_bytes(64)

    user = %{
      id: Base.encode64(user_handle, padding: false),
      name: app_name,
      displayName: app_name
    }

    challenge =
      Wax.new_registration_challenge(
        attestation: attestation,
        origin: endpoint.url,
        rp_id: :auto,
        trusted_attestation_types: [:none, :basic]
      )

    challenge_data = %{
      attestation: attestation,
      challenge: Base.encode64(challenge.bytes, padding: false),
      excludeCredentials: [],
      rp: %{
        id: challenge.rp_id,
        name: app_name
      },
      timeout: 60_000,
      user: user
    }

    {
      :noreply,
      socket
      |> assign(:challenge, challenge)
      |> assign(:user_handle, user_handle)
      |> push_event("passkey-registration", challenge_data)
    }
  end

  def handle_event("registration-attestation", payload, socket) do
    %{challenge: challenge, user_handle: user_handle} = socket.assigns

    %{
      "attestation64" => attestation_64,
      "clientData" => client_data,
      "rawId64" => raw_id_64,
      "type" => "public-key"
    } = payload

    attestation = Base.decode64!(attestation_64, padding: false)
    raw_id = Base.decode64!(raw_id_64, padding: false)
    wax_response = Wax.register(attestation, client_data, challenge)

    case wax_response do
      {:ok, {authenticator_data, _result}} ->
        %{attested_credential_data: %{credential_public_key: public_key}} = authenticator_data

        send(
          socket.root_pid,
          {:registration_successful,
           key_id: raw_id, public_key: public_key, user_handle: user_handle}
        )

      {:error, error} ->
        message = Exception.message(error)
        send(socket.root_pid, {:registration_failure, message: message})
    end

    {:noreply, socket}
  end

  def handle_event("error", payload, socket) do
    send(socket.root_pid, {:error, payload})
    {:noreply, socket}
  end
end
