import { base64ToArray, arrayBufferToBase64, handleError } from "./utils";

const AuthenticationHook = {
  abortController: new AbortController(),

  mounted() {
    console.info(`AuthenticationHook mounted`);

    listenerOptions = { signal: context.abortController.signal };

    window.addEventListener("phx:passkey-authentication", (event) =>
      this.handlePasskeyAuthentication(event, context)
    );
  },

  destroyed() {
    window.removeEventListener(
      "phx:passkey-authentication",
      this.handlePasskeyAuthentication
    );
  },

  async handlePasskeyAuthentication(event, context) {
    try {
      const { challenge, timeout, rpId, allowCredentials, userVerification } =
        event.detail;

      const challengeArray = base64ToArray(challenge);

      const publicKey = {
        allowCredentials,
        challenge: challengeArray.buffer,
        rpId,
        timeout,
        userVerification,
      };
      const credential = await navigator.credentials.get({
        publicKey,
      });
      const { rawId, response, type } = credential;
      const { clientDataJSON, authenticatorData, signature, userHandle } =
        response;
      const rawId64 = arrayBufferToBase64(rawId);
      const clientDataArray = Array.from(new Uint8Array(clientDataJSON));
      const authenticatorData64 = arrayBufferToBase64(authenticatorData);
      const signature64 = arrayBufferToBase64(signature);
      const userHandle64 = arrayBufferToBase64(userHandle);

      context.pushEventTo(context.el, "authentication-attestation", {
        rawId64,
        type,
        clientDataArray,
        authenticatorData64,
        signature64,
        userHandle64,
      });
    } catch (error) {
      console.error(error);
      handleError(error, context);
    }
  },
};

module.exports = { AuthenticationHook };