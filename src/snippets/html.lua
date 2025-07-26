--
-- HTML snippets - Modern templates for web development
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
  -- HTML5 document template
  s("html5", {
    t({"<!DOCTYPE html>"}),
    t({"<html lang=\""}), i(1, "en"), t({"\">"}),
    t({"<head>"}),
    t({"    <meta charset=\"UTF-8\">"}),
    t({"    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"}),
    t({"    <meta name=\"description\" content=\""}), i(2, "Page description"), t({"\">"}),
    t({"    <meta name=\"author\" content=\"Illya Starikov\">"}),
    t({"    <title>"}), i(3, "Page Title"), t({"</title>"}),
    t({"    "}), i(4, "<!-- Additional head elements -->"),
    t({"</head>"}),
    t({"<body>"}),
    t({"    "}), i(5, "<!-- Page content -->"),
    t({"</body>"}),
    t({"</html>"}),
    i(0)
  }),

  -- Basic HTML structure
  s("html", {
    t({"<!DOCTYPE html>"}),
    t({"<html>"}),
    t({"<head>"}),
    t({"    <meta charset=\"UTF-8\">"}),
    t({"    <title>"}), i(1, "Document Title"), t({"</title>"}),
    t({"</head>"}),
    t({"<body>"}),
    t({"    "}), i(2, "<!-- Content -->"),
    t({"</body>"}),
    t({"</html>"}),
    i(0)
  }),

  -- Semantic HTML5 structure
  s("semantic", {
    t({"<header>"}),
    t({"    <nav>"}),
    t({"        "}), i(1, "<!-- Navigation -->"),
    t({"    </nav>"}),
    t({"</header>"}),
    t({""}),
    t({"<main>"}),
    t({"    <article>"}),
    t({"        <h1>"}), i(2, "Article Title"), t({"</h1>"}),
    t({"        "}), i(3, "<!-- Article content -->"),
    t({"    </article>"}),
    t({"    "}),
    t({"    <aside>"}),
    t({"        "}), i(4, "<!-- Sidebar content -->"),
    t({"    </aside>"}),
    t({"</main>"}),
    t({""}),
    t({"<footer>"}),
    t({"    "}), i(5, "<!-- Footer content -->"),
    t({"</footer>"}),
    i(0)
  }),

  -- CSS link
  s("css", {
    t({"<link rel=\"stylesheet\" href=\""}), i(1, "styles.css"), t({"\">"}),
    i(0)
  }),

  -- JavaScript script tag
  s("js", {
    t({"<script src=\""}), i(1, "script.js"), t({"\"></script>"}),
    i(0)
  }),

  -- Inline script
  s("script", {
    t({"<script>"}),
    t({"    "}), i(1, "// JavaScript code"),
    t({"</script>"}),
    i(0)
  }),

  -- Form with modern attributes
  s("form", {
    t({"<form action=\""}), i(1, "/submit"), t({"\" method=\""}), i(2, "POST"), t({"\" novalidate>"}),
    t({"    <fieldset>"}),
    t({"        <legend>"}), i(3, "Form Title"), t({"</legend>"}),
    t({"        "}),
    t({"        <div class=\"form-group\">"}),
    t({"            <label for=\""}), i(4, "input-id"), t({"\">"}), i(5, "Label Text"), t({"</label>"}),
    t({"            <input type=\""}), i(6, "text"), t({"\" id=\""}), f(function(args) return args[1][1] end, {4}), t({"\" name=\""}), f(function(args) return args[1][1] end, {4}), t({"\" required>"}),
    t({"        </div>"}),
    t({"        "}),
    t({"        <button type=\"submit\">"}), i(7, "Submit"), t({"</button>"}),
    t({"    </fieldset>"}),
    t({"</form>"}),
    i(0)
  }),

  -- Input field with label
  s("input", {
    t({"<div class=\"form-group\">"}),
    t({"    <label for=\""}), i(1, "input-id"), t({"\">"}), i(2, "Label Text"), t({"</label>"}),
    t({"    <input type=\""}), i(3, "text"), t({"\" id=\""}), f(function(args) return args[1][1] end, {1}), t({"\" name=\""}), f(function(args) return args[1][1] end, {1}), t({"\" "}), i(4, "required"), t({">"}),
    t({"</div>"}),
    i(0)
  }),

  -- Table structure
  s("table", {
    t({"<table>"}),
    t({"    <caption>"}), i(1, "Table Caption"), t({"</caption>"}),
    t({"    <thead>"}),
    t({"        <tr>"}),
    t({"            <th scope=\"col\">"}), i(2, "Header 1"), t({"</th>"}),
    t({"            <th scope=\"col\">"}), i(3, "Header 2"), t({"</th>"}),
    t({"        </tr>"}),
    t({"    </thead>"}),
    t({"    <tbody>"}),
    t({"        <tr>"}),
    t({"            <td>"}), i(4, "Data 1"), t({"</td>"}),
    t({"            <td>"}), i(5, "Data 2"), t({"</td>"}),
    t({"        </tr>"}),
    t({"    </tbody>"}),
    t({"</table>"}),
    i(0)
  }),

  -- Navigation menu
  s("nav", {
    t({"<nav aria-label=\""}), i(1, "Main navigation"), t({"\">"}),
    t({"    <ul>"}),
    t({"        <li><a href=\""}), i(2, "#home"), t({"\" aria-current=\"page\">"}), i(3, "Home"), t({"</a></li>"}),
    t({"        <li><a href=\""}), i(4, "#about"), t({"\">"}), i(5, "About"), t({"</a></li>"}),
    t({"        <li><a href=\""}), i(6, "#contact"), t({"\">"}), i(7, "Contact"), t({"</a></li>"}),
    t({"    </ul>"}),
    t({"</nav>"}),
    i(0)
  }),

  -- Article structure
  s("article", {
    t({"<article>"}),
    t({"    <header>"}),
    t({"        <h1>"}), i(1, "Article Title"), t({"</h1>"}),
    t({"        <p class=\"meta\">"}),
    t({"            <time datetime=\""}), i(2, "2024-01-01"), t({"\">"}), i(3, "January 1, 2024"), t({"</time>"}),
    t({"            by <address class=\"author\">"}), i(4, "Illya Starikov"), t({"</address>"}),
    t({"        </p>"}),
    t({"    </header>"}),
    t({"    "}),
    t({"    <section>"}),
    t({"        "}), i(5, "<!-- Article content -->"),
    t({"    </section>"}),
    t({"</article>"}),
    i(0)
  }),

  -- Figure with caption
  s("figure", {
    t({"<figure>"}),
    t({"    <img src=\""}), i(1, "image.jpg"), t({"\" alt=\""}), i(2, "Image description"), t({"\" loading=\"lazy\">"}),
    t({"    <figcaption>"}), i(3, "Image caption"), t({"</figcaption>"}),
    t({"</figure>"}),
    i(0)
  }),

  -- Video element
  s("video", {
    t({"<video controls"}), i(1, " poster=\"poster.jpg\""), t({">"}),
    t({"    <source src=\""}), i(2, "video.mp4"), t({"\" type=\"video/mp4\">"}),
    t({"    <source src=\""}), i(3, "video.webm"), t({"\" type=\"video/webm\">"}),
    t({"    <p>Your browser doesn't support video. <a href=\""}), f(function(args) return args[1][1] end, {2}), t({"\">Download the video</a>.</p>"}),
    t({"</video>"}),
    i(0)
  }),

  -- Audio element
  s("audio", {
    t({"<audio controls>"}),
    t({"    <source src=\""}), i(1, "audio.mp3"), t({"\" type=\"audio/mpeg\">"}),
    t({"    <source src=\""}), i(2, "audio.ogg"), t({"\" type=\"audio/ogg\">"}),
    t({"    <p>Your browser doesn't support audio. <a href=\""}), f(function(args) return args[1][1] end, {1}), t({"\">Download the audio</a>.</p>"}),
    t({"</audio>"}),
    i(0)
  }),

  -- Details/Summary (collapsible content)
  s("details", {
    t({"<details"}), i(1, " open"), t({">"}),
    t({"    <summary>"}), i(2, "Click to toggle"), t({"</summary>"}),
    t({"    "}), i(3, "<!-- Hidden content -->"),
    t({"</details>"}),
    i(0)
  }),

  -- Progress bar
  s("progress", {
    t({"<progress value=\""}), i(1, "70"), t({"\" max=\""}), i(2, "100"), t({"\">"}), i(3, "70%"), t({"</progress>"}),
    i(0)
  }),

  -- Meter element
  s("meter", {
    t({"<meter value=\""}), i(1, "0.7"), t({"\" min=\""}), i(2, "0"), t({"\" max=\""}), i(3, "1"), t({"\">"}), i(4, "70%"), t({"</meter>"}),
    i(0)
  }),

  -- Meta tags for SEO
  s("meta", {
    t({"<meta name=\"description\" content=\""}), i(1, "Page description"), t({"\">"}),
    t({"<meta name=\"keywords\" content=\""}), i(2, "keyword1, keyword2"), t({"\">"}),
    t({"<meta name=\"author\" content=\"Illya Starikov\">"}),
    t({"<meta property=\"og:title\" content=\""}), i(3, "Page Title"), t({"\">"}),
    t({"<meta property=\"og:description\" content=\""}), f(function(args) return args[1][1] end, {1}), t({"\">"}),
    t({"<meta property=\"og:image\" content=\""}), i(4, "image.jpg"), t({"\">"}),
    t({"<meta name=\"twitter:card\" content=\"summary_large_image\">"}),
    i(0)
  }),

  -- Responsive image
  s("picture", {
    t({"<picture>"}),
    t({"    <source media=\"(min-width: 768px)\" srcset=\""}), i(1, "large.jpg"), t({"\">"}),
    t({"    <source media=\"(min-width: 480px)\" srcset=\""}), i(2, "medium.jpg"), t({"\">"}),
    t({"    <img src=\""}), i(3, "small.jpg"), t({"\" alt=\""}), i(4, "Image description"), t({"\" loading=\"lazy\">"}),
    t({"</picture>"}),
    i(0)
  }),

  -- Link with attributes
  s("link", {
    t({"<a href=\""}), i(1, "#"), t({"\" "}), i(2, "target=\"_blank\" rel=\"noopener\""), t({">"}), i(3, "Link text"), t({"</a>"}),
    i(0)
  }),

  -- Div with class
  s("div", {
    t({"<div class=\""}), i(1, "container"), t({"\">"}),
    t({"    "}), i(2, "<!-- Content -->"),
    t({"</div>"}),
    i(0)
  }),

  -- Span with class
  s("span", {
    t({"<span class=\""}), i(1, "highlight"), t({"\">"}), i(2, "Text"), t({"</span>"}),
    i(0)
  }),

  -- Accessibility-focused button
  s("button", {
    t({"<button type=\""}), i(1, "button"), t({"\" aria-label=\""}), i(2, "Button description"), t({"\" "}), i(3, "onclick=\"handleClick()\""), t({">"}),
    t({"    "}), i(4, "Button Text"),
    t({"</button>"}),
    i(0)
  }),
}