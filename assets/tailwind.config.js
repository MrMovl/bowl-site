// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")

module.exports = {
  content: [
    "./js/**/*.js",
    "./vendor/**/*.js",
    "../lib/bowl_site_web.ex",
    "../lib/bowl_site_web/**/*.*ex",
    // Backpex templates — needed so Tailwind includes Backpex's utility classes
    "../deps/backpex/**/*.*ex"
  ],
  theme: {
    extend: {}
  },
  plugins: [
    // Required by Backpex — install via: npm install daisyui@latest (in assets/)
    // See backpex-howto.md for full setup instructions
    // require("daisyui"),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),
  ]
}
