// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/bowl_site_web.ex",
    "../lib/bowl_site_web/**/*.*ex"
  ],
  theme: {
    extend: {}
  },
  plugins: [
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),
  ]
}
