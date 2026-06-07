#!/usr/bin/env sh

rm -rf docs
mkdir -p docs
cp recipes/*.jpg recipes/*.png recipes/*.webp docs/ 2>/dev/null
cp favicon.svg manifest.json sw.js docs/

# Build {recipe}.html
for recipe in recipes/*.cook; do
    name=$(basename "${recipe%.cook}")
    cook report --template recipe.html.jinja "$recipe" --datastore . > "docs/$name.html" 2>/dev/null
    echo "$name.html"
done

# Build index.html
cat > docs/index.html <<'HEADER'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#222222">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <link rel="icon" href="favicon.svg">
  <link rel="apple-touch-icon" href="favicon.svg">
  <link rel="manifest" href="manifest.json">
  <title>Recipes</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font: 400 17px/1.7 Charter, "Bitstream Charter", "Sitka Text", Cambria, serif;
      color: #222;
      background: #fff;
    }
    main { max-width: 640px; margin: 0 auto; padding: 56px 24px 96px; }
    h1 { font-size: 36px; font-weight: 700; line-height: 1.1; letter-spacing: -0.75px; margin-bottom: 32px; }
    .grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 24px; }
    .card { text-decoration: none; color: #222; }
    .card img { display: block; width: 100%; aspect-ratio: 4/3; object-fit: cover; border-radius: 10px; }
    .card span { display: block; margin-top: 8px; font-weight: 600; }
    @media (max-width: 480px) {
      main { padding: 32px 16px 64px; }
      h1 { font-size: 28px; }
      .grid { gap: 16px; }
    }
  </style>
</head>
<body>
  <main>
    <h1>Recipes</h1>
    <div class="grid">
HEADER

for recipe in recipes/*.cook; do
    name=$(basename "${recipe%.cook}")
    title=$(sed -n 's/^title: *//p' "$recipe")
    image=$(sed -n 's/^image: *//p' "$recipe")
    cat >> docs/index.html <<CARD
      <a class="card" href="${name}.html">
        <img src="${image}" alt="${title}">
        <span>${title}</span>
      </a>
CARD
done

cat >> docs/index.html <<'FOOTER'
    </div>
  </main>
  <script>if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js');</script>
</body>
</html>
FOOTER
echo "index.html"
