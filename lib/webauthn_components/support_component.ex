defmodule WebauthnComponents.SupportComponent do
  @moduledoc """
  A LiveComponent for detecting WebAuthn support.

  This component should be used in combination with `RegistrationComponent` and `AuthenticationComponent` to disable their buttons when WebAuthn is not supported or enabled.

  An application may also use `SupportComponent` to steer users away from traditional authentication to the more secure Passkey authentication method. For example, an application that supports both traditional authentication and Passkeys may redirect users to a Passkey LiveView or render a message encouraging the new authentication method.

  See [USAGE.md](./USAGE.md) for example code.

  ## Assigns

  - `@passkeys_supported`: (Internal) A boolean indicating the client does or does not support the WebAuthn API.

  ## Events

  - `"passkeys-supported"`: Sent by the client when Passkey support has been checked.

  ## Messages

  - `{:passkeys_supported, boolean}`
    - `boolean` will be `true` when WebAuthn is supported and enabled, and `false` when it is not supported or enabled.
  """
  use Phoenix.LiveComponent

  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:passkeys_supported, nil)
    }
  end

  def render(assigns) do
    ~H"""
    <span id="support-component" phx-hook="SupportHook"></span>
    """
  end

  def handle_event("passkeys-supported", boolean, socket) when is_boolean(boolean) do
    send(socket.root_pid, {:passkeys_supported, boolean})

    {
      :noreply,
      socket
      |> assign(:passkeys_supported, !!boolean)
    }
  end
end
