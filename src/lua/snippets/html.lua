--
-- HTML snippets - Concise, practical templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
  -- HTML5 document
  s("html5", {
    t({"<!DOCTYPE html>", ""}),
    t({"<html lang=\""}), i(1, "en"), t({"\">", ""}),
    t({"<head>", ""}),
    t({"  <meta charset=\"UTF-8\">", ""}),
    t({"  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">", ""}),
    t({"  <title>"}), i(2, "Document"), t({"</title>", ""}),
    t({"</head>", ""}),
    t({"<body>", ""}),
    t({"  "}), i(3), t({"", ""}),
    t({"</body>", ""}),
    t({"</html>"}),
    i(0)
  }),

  -- Link
  s("link", {
    t("<link rel=\""), c(1, {t("stylesheet"), t("icon")}), t("\" href=\""), i(2), t("\">"),
    i(0)
  }),

  -- Script
  s("script", {
    t("<script"), c(1, {
      {t(" src=\""), i(1), t("\"></script>")},
      {t(">"), t({"", "  "}), i(1), t({"", "</script>"})}
    }),
    i(0)
  }),

  -- Meta tag
  s("meta", {
    t("<meta "), c(1, {
      {t("name=\""), i(1, "description"), t("\" content=\""), i(2), t("\">")},
      {t("property=\""), i(1, "og:title"), t("\" content=\""), i(2), t("\">")},
      {t("charset=\""), i(1, "UTF-8"), t("\">")}
    }),
    i(0)
  }),

  -- Div
  s("div", {
    t("<div"), c(1, {{t(" class=\""), i(1), t("\"")}, t("")}), t(">"), t({"", "  "}), 
    i(2), t({"", "</div>"}),
    i(0)
  }),

  -- Section
  s("section", {
    t("<section>"), t({"", "  "}),
    i(1), t({"", "</section>"}),
    i(0)
  }),

  -- Article
  s("article", {
    t("<article>"), t({"", "  "}),
    i(1), t({"", "</article>"}),
    i(0)
  }),

  -- Header
  s("header", {
    t("<header>"), t({"", "  "}),
    i(1), t({"", "</header>"}),
    i(0)
  }),

  -- Footer
  s("footer", {
    t("<footer>"), t({"", "  "}),
    i(1), t({"", "</footer>"}),
    i(0)
  }),

  -- Nav
  s("nav", {
    t("<nav>"), t({"", "  <ul>", ""}),
    t({"    <li><a href=\""}), i(1, "#"), t({"\">"}), i(2, "Link"), t({"</a></li>", ""}),
    t({"  </ul>", "</nav>"}),
    i(0)
  }),

  -- Form
  s("form", {
    t("<form"), c(1, {
      {t(" action=\""), i(1), t("\" method=\""), c(2, {t("POST"), t("GET")}), t("\"")},
      t("")
    }), t(">"), t({"", "  "}),
    i(3), t({"", "</form>"}),
    i(0)
  }),

  -- Input
  s("input", {
    t("<input type=\""), c(1, {
      t("text"),
      t("email"),
      t("password"),
      t("number"),
      t("date"),
      t("checkbox"),
      t("radio"),
      t("submit")
    }), t("\" name=\""), i(2), t("\""), 
    c(3, {{t(" placeholder=\""), i(1), t("\"")}, t("")}), t(">"),
    i(0)
  }),

  -- Button
  s("button", {
    t("<button type=\""), c(1, {t("button"), t("submit"), t("reset")}), t("\">"), 
    i(2, "Click me"), t("</button>"),
    i(0)
  }),

  -- Image
  s("img", {
    t("<img src=\""), i(1), t("\" alt=\""), i(2), t("\""), 
    c(3, {{t(" width=\""), i(1), t("\" height=\""), i(2), t("\"")}, t("")}), t(">"),
    i(0)
  }),

  -- Anchor
  s("a", {
    t("<a href=\""), i(1, "#"), t("\""), 
    c(2, {{t(" target=\"_blank\" rel=\"noopener\"")}, t("")}), t(">"), 
    i(3, "Link text"), t("</a>"),
    i(0)
  }),

  -- Unordered list
  s("ul", {
    t({"<ul>", ""}),
    t({"  <li>"}), i(1), t({"</li>", ""}),
    t({"  <li>"}), i(2), t({"</li>", ""}),
    t({"</ul>"}),
    i(0)
  }),

  -- Ordered list
  s("ol", {
    t({"<ol>", ""}),
    t({"  <li>"}), i(1), t({"</li>", ""}),
    t({"  <li>"}), i(2), t({"</li>", ""}),
    t({"</ol>"}),
    i(0)
  }),

  -- Table
  s("table", {
    t({"<table>", ""}),
    t({"  <thead>", ""}),
    t({"    <tr>", ""}),
    t({"      <th>"}), i(1, "Header"), t({"</th>", ""}),
    t({"    </tr>", ""}),
    t({"  </thead>", ""}),
    t({"  <tbody>", ""}),
    t({"    <tr>", ""}),
    t({"      <td>"}), i(2, "Data"), t({"</td>", ""}),
    t({"    </tr>", ""}),
    t({"  </tbody>", ""}),
    t({"</table>"}),
    i(0)
  }),

  -- Paragraph
  s("p", {
    t("<p>"), i(1), t("</p>"),
    i(0)
  }),

  -- Heading
  s("h", {
    t("<h"), c(1, {t("1"), t("2"), t("3"), t("4"), t("5"), t("6")}), t(">"), 
    i(2), 
    t("</h"), f(function(args) return args[1][1] end, {1}), t(">"),
    i(0)
  }),

  -- Strong
  s("strong", {
    t("<strong>"), i(1), t("</strong>"),
    i(0)
  }),

  -- Em
  s("em", {
    t("<em>"), i(1), t("</em>"),
    i(0)
  }),

  -- Comment
  s("comment", {
    t("<!-- "), i(1), t(" -->"),
    i(0)
  }),
}