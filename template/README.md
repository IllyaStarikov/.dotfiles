# /template - GitHub Pages Website Templates

## What's in this directory

This directory contains the templates and assets for generating the dotfiles documentation website hosted at `dotfiles.starikov.io`. It includes HTML templates, CSS styles, JavaScript, and build scripts for creating a static documentation site from the repository content.

### Directory Structure:

```
template/
├── .vscode/           # VSCode workspace settings
├── public/            # Static assets (images, fonts)
├── *.html            # HTML templates for each config file
├── _config.yml       # Jekyll/GitHub Pages configuration
├── generate.sh       # Site generation script (37KB)
├── mirror.sh         # Content mirroring script (38KB)
├── build.sh.old      # Legacy build script
├── prism.js          # Syntax highlighting library
├── prism-tomorrow.css # Code theme
├── CNAME            # Custom domain configuration
├── sitemap.xml      # SEO sitemap
└── robots.txt       # Search engine directives
```

### How to use:

```bash
# Generate the documentation site
./template/generate.sh

# Mirror repository content
./template/mirror.sh

# Test locally with Jekyll
cd template
jekyll serve --watch

# Access at http://localhost:4000
```

## Why this directory exists

The template system transforms the dotfiles repository into a browsable, searchable documentation website. This provides a user-friendly way to explore configurations without cloning the repository, improving discoverability and accessibility.

### Benefits:

- **Web accessibility** - View configs in browser
- **Syntax highlighting** - Prism.js for readability
- **Search indexing** - Google can index configs
- **Version history** - Links to GitHub commits
- **Mobile friendly** - Responsive design
- **Fast loading** - Static site, CDN cached

## Template System

### HTML Templates

Each configuration file type has a corresponding HTML template:

```html
<!-- Example: nvim.html -->
<!DOCTYPE html>
<html>
  <head>
    <title>Neovim Configuration</title>
    <link rel="stylesheet" href="prism-tomorrow.css" />
  </head>
  <body>
    <pre><code class="language-lua">
        <!-- Content injected here -->
    </code></pre>
    <script src="prism.js"></script>
  </body>
</html>
```

### Generation Process (`generate.sh`)

```bash
# 1. Clone/update repository
git pull origin main

# 2. Process each config file
for file in src/**/*; do
    # Select appropriate template
    template=$(get_template_for "$file")

    # Generate HTML page
    inject_content "$file" "$template" > "public/$file.html"
done

# 3. Generate index and navigation
create_index_page > public/index.html
create_sitemap > public/sitemap.xml

# 4. Deploy to GitHub Pages
git add public/
git commit -m "Update documentation"
git push origin gh-pages
```

### Mirror Script (`mirror.sh`)

Maintains synchronized copy of configurations:

```bash
# Mirror structure
src/ → public/src/
test/ → public/test/
doc/ → public/doc/

# Process files
- Convert .md to HTML
- Add syntax highlighting
- Generate navigation
- Create breadcrumbs
```

## Lessons Learned

### What NOT to Do

#### ❌ Don't use client-side rendering

**Problem**: Poor SEO, slow initial load
**Solution**: Static generation at build time

```javascript
// BAD: Client-side fetch
fetch('/api/config/nvim').then(render)

// GOOD: Pre-generated HTML
<pre><code>{{ content }}</code></pre>
```

#### ❌ Don't include sensitive files

**Problem**: Private keys exposed in documentation
**Solution**: Explicit exclude list

```bash
# Files to never publish
.env
*.key
*.pem
.dotfiles.private/
```

#### ❌ Don't use heavy frameworks

**Problem**: 500KB of JavaScript for simple docs
**Solution**: Vanilla JS + Prism.js only (19KB)

#### ❌ Don't forget mobile users

**Problem**: Code blocks unreadable on phones
**Solution**: Responsive design with horizontal scroll

```css
pre {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}
```

### Failed Approaches

1. **Jekyll themes** - Too opinionated, hard to customize
2. **React SPA** - Overkill for static content
3. **Wiki format** - Lost syntax highlighting
4. **PDF generation** - Not searchable, huge files

### Performance Optimizations

```yaml
# _config.yml optimizations
plugins:
  - jekyll-minifier
  - jekyll-gzip

compress_html:
  clippings: all
  comments: all

# CDN for assets
cdn_url: https://cdn.jsdelivr.net/gh/user/dotfiles@main/
```

### SEO Improvements

```html
<!-- Meta tags for better indexing -->
<meta name="description" content="Professional dotfiles configuration" />
<meta property="og:image" content="dotfiles.png" />
<link rel="canonical" href="https://dotfiles.starikov.io" />

<!-- Structured data -->
<script type="application/ld+json">
  {
    "@type": "SoftwareSourceCode",
    "name": "Dotfiles Configuration",
    "codeRepository": "https://github.com/user/dotfiles"
  }
</script>
```

## Site Features

### Syntax Highlighting

```javascript
// Prism.js configuration
Prism.languages.lua = { ... }
Prism.languages.vim = { ... }
Prism.plugins.lineNumbers.activate()
```

### Navigation System

```html
<!-- Breadcrumbs -->
<nav>
  <a href="/">Home</a> / <a href="/src">Source</a> /
  <a href="/src/neovim">Neovim</a>
</nav>

<!-- File tree -->
<aside class="file-tree">
  <!-- Generated from repository structure -->
</aside>
```

### Search Functionality

```javascript
// Simple client-side search
const searchIndex = {
  'nvim.lua': ['neovim', 'config', 'lua'],
  'tmux.conf': ['tmux', 'terminal', 'multiplexer'],
};
```

## Deployment

### GitHub Pages Setup

```yaml
# .github/workflows/pages.yml
on:
  push:
    branches: [main]

jobs:
  deploy:
    steps:
      - uses: actions/checkout@v4
      - run: ./template/generate.sh
      - uses: actions/deploy-pages@v2
```

### Custom Domain

```
# CNAME file
dotfiles.starikov.io
```

### Analytics

```javascript
// Simple, privacy-respecting analytics
if (location.hostname === 'dotfiles.starikov.io') {
  // Track page views only, no personal data
}
```

## Adding New Templates

To add support for a new file type:

1. **Create HTML template**

   ```html
   <!-- template/newtype.html -->
   <pre><code class="language-newlang">
   <!-- CONTENT -->
   </code></pre>
   ```

2. **Update generator**

   ```bash
   # In generate.sh
   *.newext) template="newtype.html" ;;
   ```

3. **Add Prism support**

   ```javascript
   Prism.languages.newlang = { ... }
   ```

4. **Test locally**
   ```bash
   ./generate.sh --file src/file.newext
   ```

## Maintenance

### Regular Updates

```bash
# Weekly automation via GitHub Actions
- Update dependencies
- Regenerate site
- Check broken links
- Update sitemap
```

### Performance Monitoring

```bash
# PageSpeed Insights
lighthouse https://dotfiles.starikov.io

# Check bundle size
du -sh public/
```

## Related Documentation

- [GitHub Pages Workflow](../.github/workflows/pages.yml)
- [Site Configuration](_config.yml)
- [Generation Script](generate.sh)
- [Public Site](https://dotfiles.starikov.io)
