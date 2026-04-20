# Backpex Integration How-To

Backpex is a Phoenix LiveView admin panel library that auto-generates list, search,
create, edit, and delete views from `LiveResource` modules.

## What's already in the code

The following changes are committed and ready:

| File | What changed |
|---|---|
| `mix.exs` | Added `{:backpex, "~> 0.18"}` |
| `router.ex` | `import Backpex.Router`, `live_session` with `Backpex.InitAssigns`, `live_resources` for products and pages |
| `assets/tailwind.config.js` | Backpex deps path added to `content:` |
| `lib/bowl_site_web/live/admin/product_resource.ex` | Backpex LiveResource — products list with search/filter/delete |
| `lib/bowl_site_web/live/admin/static_page_resource.ex` | Backpex LiveResource — full CRUD for static pages |

## Architecture decisions

### Products
Backpex handles the **list view** (search, filter, bulk delete, availability toggle).
The existing custom `ProductFormLive` handles **create and edit**, because multi-image
upload + reordering is too bespoke for Backpex's upload field.

The router places the custom routes before `live_resources`, so Phoenix routes
`/admin/products/new` and `/admin/products/:id/edit` to `ProductFormLive`.
Backpex handles `/admin/products` (list) and `/admin/products/:id` (show).

The `ProductResource` disables Backpex's built-in new/edit via `can?/3` and adds
a custom "Bearbeiten" item action that redirects to the custom form.

### Static Pages
Full Backpex — no image uploads, so `StaticPageResource` handles everything.
Delete is disabled (use `published: false` to hide a page instead).

## Manual steps required

### 1. Fetch the Backpex Hex package

```bash
mix deps.get
```

Requires network access to hex.pm.

### 2. Install npm dependencies (Alpine.js + daisyUI)

Backpex requires **Alpine.js** (for dropdowns/modals) and **daisyUI** (Tailwind component
library for its UI).

Create `assets/package.json`:

```json
{
  "private": true,
  "dependencies": {
    "alpinejs": "^3.14.0",
    "daisyui": "^5.0.0"
  }
}
```

Then install:

```bash
cd assets && npm install && cd ..
```

### 3. Enable daisyUI in Tailwind config

Uncomment the daisyUI line in `assets/tailwind.config.js`:

```js
// Before:
// require("daisyui"),

// After:
require("daisyui"),
```

### 4. Update app.js to include Alpine.js and Backpex hooks

Replace `assets/js/app.js` with:

```js
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Alpine from "alpinejs"
import { Hooks as BackpexHooks } from "backpex"

window.Alpine = Alpine

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: { ...BackpexHooks },
  dom: {
    // Required for Alpine.js + LiveView to work together
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) Alpine.clone(from, to)
    }
  }
})

topbar.config({barColors: {0: "#78716c"}, shadowColor: "rgba(0, 0, 0, .15)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

Alpine.start()
liveSocket.connect()
window.liveSocket = liveSocket
```

Note: `Alpine.start()` must be called **after** the LiveSocket is created.

### 5. Update the esbuild config to resolve npm packages

In `config/config.exs`, update the esbuild watcher to also look in `assets/node_modules`:

```elixir
config :esbuild,
  version: "0.17.11",
  bowl_site: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../assets/node_modules", __DIR__)}
  ]
```

### 6. Build assets and verify

```bash
mix assets.build
mix phx.server
```

Visit `http://localhost:4000/admin` (log in), then:
- `/admin/products` — Backpex product list with search and delete
- `/admin/products/new` — custom form with image upload (unchanged)
- `/admin/products/:id/edit` — custom form with image upload (unchanged)
- `/admin/pages` — Backpex page list and editor

## Verifying the Backpex API version

If anything fails to compile after `mix deps.get`, check the installed version's docs:

```bash
mix hex.docs open backpex
```

The `LiveResource` API (field modules, `adapter_config`, `can?/3`) is consistent
across 0.9–0.18 but may have changed. The key callbacks to verify:

- `use Backpex.LiveResource, adapter_config: [schema: ..., repo: ...]` — configure the schema
- `def fields` — list of `{field_name, %{module: Backpex.Fields.Text, label: "..."}}`
- `def can?(_assigns, action, _item)` — return `false` to disable an action
- `def item_actions(default_actions)` — add custom row actions

Full field types: `Text`, `Number`, `Boolean`, `Select`, `Textarea`, `Upload`,
`Date`, `DateTime`, `Currency`, `URL`, `HasMany`, `MultiSelect`.

## Removing Backpex later

If you decide the custom LiveViews are sufficient:
1. Remove `{:backpex, "~> 0.18"}` from `mix.exs`
2. Remove `import Backpex.Router` and `live_resources` from `router.ex`
3. Delete `product_resource.ex` and `static_page_resource.ex`
4. Restore `router.ex` to use `live "/products", Admin.ProductListLive, :index` etc.
5. The custom ProductFormLive, PageFormLive, ProductListLive, PageListLive are
   still in the codebase and work independently.
