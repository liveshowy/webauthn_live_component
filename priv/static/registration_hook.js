import { base64ToArray, arrayBufferToBase64, handleError } from "./utils";

const RegistrationHook = {
  abortController: new AbortController(),

  mounted() {
    console.info(`RegistrationHook mounted`);

    listenerOptions = { signal: context.abortController.signal };

    window.addEventListener("phx:passkey-registration", (event) =>
      this.handleRegistration(event, context)
    );
  },

  destroyed() {
    window.removeEventListener(
      "phx:passkey-registration",
      this.handleRegistration
    );
  },

  async handleRegistration(event, context) {
    try {
      const {
        attestation,
        challenge,
        excludeCredentials,
        requireResidentKey,
        rp,
        timeout,
        user,
      } = event.detail;
      const challengeArray = base64ToArray(challenge);

      user.id = base64ToArray(user.id).buffer;

      const publicKey = {
        attestation,
        authenticatorSelection: {
          authenticatorAttachment: "platform",
          requireResidentKey: requireResidentKey,
        },
        challenge: challengeArray.buffer,
        excludeCredentials,
        pubKeyCredParams: [
          { alg: -7, type: "public-key" },
          { alg: -257, type: "public-key" },
        ],
        rp,
        timeout,
        user,
      };

      const credential = await navigator.credentials.create({
        publicKey,
      });

      const { rawId, response, type } = credential;
      const { attestationObject, clientDataJSON } = response;
      const attestation64 = arrayBufferToBase64(attestationObject);
      const clientData = Array.from(new Uint8Array(clientDataJSON));
      const rawId64 = arrayBufferToBase64(rawId);

      context.pushEventTo(context.el, "registration-attestation", {
        attestation64,
        clientData,
        rawId64,
        type,
      });
    } catch (error) {
      console.error(error);
      handleError(error, context);
    }
  },
};

module.exports = { RegistrationHook };