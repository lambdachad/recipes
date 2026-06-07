# AGENTS.md

## Project Overview

Personal recipe collection website. "Oppskrifter" is Norwegian for "recipes." Recipes are authored in **Cooklang** (`.cook` files), converted to a static HTML site via a shell script, and deployed to **GitHub Pages** from the `docs/` directory.

All recipe content is written in **Norwegian**. Ingredient pricing references Carrefour Egypt (EGP currency).

## Architecture

```
oppskrifter/
├── recipes/              # Source: Cooklang recipe files + images
│   ├── *.cook            # Recipe source files
│   └── *.jpg             # Recipe photos
├── build.sh              # Static site generator (POSIX sh)
├── recipe.html.jinja     # Jinja2 template for individual recipe pages
├── ingredients.yml       # Ingredient database (pricing, URLs, units)
├── manifest.json         # PWA web app manifest
├── sw.js                 # Service worker (cache-first offline support)
├── favicon.svg           # SVG favicon
└── docs/                 # BUILD OUTPUT: generated site (do not edit by hand)
```

## Key Files

| File | Purpose |
|---|---|
| `recipes/*.cook` | Recipe source files in Cooklang format |
| `build.sh` | Builds the entire site: runs `cook report` per recipe, generates `index.html` |
| `recipe.html.jinja` | Jinja2 template consumed by `cook report --template` |
| `ingredients.yml` | YAML datastore mapping ingredient names to item info, price, quantity, unit, and store URL |
| `docs/` | Generated output directory. Rebuilt from scratch on every build. Never edit directly. |

## Cooklang Recipe Format

Each `.cook` file has a YAML front matter block followed by recipe steps:

```cooklang
---
title: Eggsandwich
image: eggsandwich.jpg
---

Varm opp en #panne{} over middels-høy varme med litt @smør{35%g}.
Visp @egg{4} i en bolle med @salt{}.
Stek i ~{1-2%minutter}.
```

### Metadata (front matter)

- `title` (required) -- display name in Norwegian
- `image` (required) -- filename of the associated image in `recipes/`

### Cooklang Syntax Used

| Element | Syntax | Example |
|---|---|---|
| Ingredient with quantity+unit | `@name{qty%unit}` | `@smør{35%g}` |
| Ingredient with quantity only | `@name{qty}` | `@egg{4}` |
| Ingredient without quantity | `@name{}` | `@salt{}` |
| Multi-word ingredient | `@word word{qty%unit}` | `@hel kylling{1}` |
| Equipment | `#name{}` | `#panne{}`, `#ovn{}` |
| Timer | `~{qty%unit}` | `~{5%minutter}` |
| Timer range | `~{min-max%unit}` | `~{1-2%minutter}` |

### Naming Conventions

- `.cook` filenames are English slugs: `roasted-chicken.cook`, `scrambled-eggs.cook`
- `title` metadata is Norwegian: `Ovnsstekt Kylling`, `Eggerøre`
- Image filenames are Norwegian: `ovnsstekt-kylling.jpg`, `eggerøre.jpg`
- The `image` field in front matter explicitly maps the recipe to its image file

### Ingredient Names

Ingredient names in `@ingredient{...}` must be lowercase Norwegian and should match keys in `ingredients.yml` for cost tracking to work. Ingredients without a matching entry will render without price data (which is acceptable for spices and seasonings).

## Ingredient Database (`ingredients.yml`)

Each entry:

```yaml
smør:
    item: Smør              # Display name
    url: https://...        # Product page (Carrefour Egypt)
    price: 158.99           # Price in EGP
    quantity: 1000          # Reference quantity for this price
    unit: g                 # Unit of the reference quantity
```

The template calculates per-recipe cost as: `(recipe_qty * price) / reference_qty`.

## Build Process

Run `./build.sh` from the project root. Requirements:

- POSIX-compatible shell (`sh`)
- [`cook` CLI](https://cooklang.org/cli/) (Cooklang CLI) installed and on PATH

The script:

1. Cleans and recreates `docs/`
2. Copies images and PWA assets into `docs/`
3. Runs `cook report --template recipe.html.jinja --datastore .` for each `.cook` file, outputting HTML to `docs/`
4. Generates `docs/index.html` with a card grid linking to all recipes

## Adding a New Recipe

1. Create `recipes/<english-slug>.cook` with `title` and `image` front matter
2. Add a photo as `recipes/<norwegian-name>.jpg`
3. Add any new ingredients to `ingredients.yml` (optional, for cost tracking)
4. Run `./build.sh`

## Design Conventions

- No external CSS/JS frameworks -- pure HTML/CSS/JS
- Typography: Charter serif font stack
- Responsive: max-width 640px, mobile breakpoint at 480px
- PWA-enabled with service worker and manifest
- All UI text is in Norwegian
- Temperatures in Celsius, weights in grams, volumes in ml
