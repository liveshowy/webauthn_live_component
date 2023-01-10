import { handleError } from "./utils";

const TokenHook = {
  abortController: new AbortController(),

  mounted() {
    console.info(`TokenHook mounted`);

    this.pushUserToken(this);
    this.attachEventListeners(this);
  },

  destroyed() {
    this.detachEventListeners();
  },

  attachEventListeners(context) {
    listenerOptions = { signal: context.abortController.signal };

    window.addEventListener(
      "phx:store-token",
      (event) => context.storeToken(event, context),
      listenerOptions
    );

    window.addEventListener(
      "phx:clear-token",
      (_event) => context.clearToken(null, context),
      listenerOptions
    );
  },

  detachEventListeners() {
    window.removeEventListener("phx:store-token", this.storeToken);

    window.removeEventListener("phx:clear-token", this.clearToken);
  },

  pushUserToken(context) {
    const token = window.sessionStorage.getItem("userToken");
    if (token) {
      context.pushEventTo(context.el, "token-exists", { token });
    }
  },

  storeToken({ detail }, context) {
    try {
      const { token } = detail;
      window.sessionStorage.setItem("userToken", token);
      console.log(token, sessionStorage);
      console.info(`Stored user token`);
      context.pushEventTo(context.el, "token-stored", { token });
    } catch (error) {
      console.error(error);
      handleError(error, context);
    }
  },

  clearToken(_data, context) {
    try {
      window.sessionStorage.removeItem("userToken");
      console.log(sessionStorage);
      console.info(`Cleared user token`);
      context.pushEventTo(context.el, "token-cleared", { token: null });
    } catch (error) {
      console.error(error);
      handleError(error, context);
    }
  },
};

module.exports = { TokenHook };
