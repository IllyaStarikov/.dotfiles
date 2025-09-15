--
-- Markdown snippets - Concise, practical templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
  -- Headers
  s("h1", {
    t("# "),
    i(1),
    i(0),
  }),

  s("h2", {
    t("## "),
    i(1),
    i(0),
  }),

  s("h3", {
    t("### "),
    i(1),
    i(0),
  }),

  -- Link
  s("link", {
    t("["),
    i(1, "text"),
    t("]("),
    i(2, "url"),
    t(")"),
    i(0),
  }),

  -- Image
  s("img", {
    t("!["),
    i(1, "alt"),
    t("]("),
    i(2, "url"),
    t(")"),
    i(0),
  }),

  -- Code block
  s("code", {
    t("```"),
    i(1, "language"),
    t({ "", "" }),
    i(2, "code"),
    t({ "", "```" }),
    i(0),
  }),

  -- Inline code
  s("ic", {
    t("`"),
    i(1),
    t("`"),
    i(0),
  }),

  -- Bold
  s("bold", {
    t("**"),
    i(1),
    t("**"),
    i(0),
  }),

  -- Italic
  s("italic", {
    t("*"),
    i(1),
    t("*"),
    i(0),
  }),

  -- Task list item
  s("task", {
    t("- [ ] "),
    i(1),
    i(0),
  }),

  -- Table
  s("table", {
    t("| "),
    i(1, "Header 1"),
    t(" | "),
    i(2, "Header 2"),
    t(" |"),
    t({ "", "" }),
    t("|"),
    t(" --- "),
    t("|"),
    t(" --- "),
    t("|"),
    t({ "", "" }),
    t("| "),
    i(3, "Cell 1"),
    t(" | "),
    i(4, "Cell 2"),
    t(" |"),
    i(0),
  }),

  -- Quote
  s("quote", {
    t("> "),
    i(1),
    i(0),
  }),

  -- Horizontal rule
  s("hr", {
    t("---"),
    i(0),
  }),

  -- Details/Summary
  s("details", {
    t({ "<details>", "" }),
    t("<summary>"),
    i(1, "Summary"),
    t({ "</summary>", "", "" }),
    i(2, "Content"),
    t({ "", "</details>" }),
    i(0),
  }),

  -- Badge
  s("badge", {
    t("!["),
    i(1, "Badge Name"),
    t("]("),
    i(2, "badge_url"),
    t(")"),
    i(0),
  }),

  -- Footnote
  s("fn", {
    t("[^"),
    i(1, "1"),
    t("]: "),
    i(2, "Footnote text"),
    i(0),
  }),

  -- README template
  s("readme", {
    t("# "),
    i(1, "Project Name"),
    t({ "", "", "" }),
    i(2, "Brief description"),
    t({ "", "", "" }),
    t({ "## Installation", "", "" }),
    t("```"),
    c(3, { t("bash"), t("sh") }),
    t({ "", "" }),
    i(4, "npm install"),
    t({ "", "```", "", "" }),
    t({ "## Usage", "", "" }),
    i(5, "Usage instructions"),
    t({ "", "", "" }),
    t({ "## License", "", "" }),
    i(6, "MIT"),
    i(0),
  }),

  -- API documentation
  s("api", {
    t("### `"),
    i(1, "functionName"),
    t("("),
    i(2, "params"),
    t(")`"),
    t({ "", "", "" }),
    i(3, "Description"),
    t({ "", "", "" }),
    t({ "**Parameters:**", "" }),
    t("- `"),
    i(4, "param1"),
    t("` ("),
    i(5, "type"),
    t(") - "),
    i(6, "description"),
    t({ "", "", "" }),
    t({ "**Returns:**", "" }),
    t("- `"),
    i(7, "type"),
    t("` - "),
    i(8, "description"),
    t({ "", "", "" }),
    t({ "**Example:**", "" }),
    t("```"),
    i(9, "javascript"),
    t({ "", "" }),
    i(10, "example code"),
    t({ "", "```" }),
    i(0),
  }),

  -- Mermaid diagram
  s("mermaid", {
    t("```mermaid"),
    t({ "", "" }),
    c(1, {
      {
        t("graph TD"),
        t({ "", "    A[" }),
        i(1, "Start"),
        t("] --> B["),
        i(2, "End"),
        t("]"),
      },
      { t("sequenceDiagram"), t({ "", "    A->>B: " }), i(1, "Message") },
      {
        t("flowchart LR"),
        t({ "", "    A[" }),
        i(1, "Start"),
        t("] --> B["),
        i(2, "End"),
        t("]"),
      },
    }),
    t({ "", "```" }),
    i(0),
  }),

  -- Front matter
  s("frontmatter", {
    t({ "---", "" }),
    t("title: "),
    i(1, "Title"),
    t({ "", "" }),
    t("date: "),
    i(2, "2024-01-01"),
    t({ "", "" }),
    t("tags: ["),
    i(3, "tag1, tag2"),
    t({ "]", "" }),
    t({ "---", "" }),
    i(0),
  }),

  -- Unordered list
  s("ul", {
    t("- "),
    i(1),
    t({ "", "- " }),
    i(2),
    t({ "", "- " }),
    i(3),
    i(0),
  }),

  -- Ordered list
  s("ol", {
    t("1. "),
    i(1),
    t({ "", "2. " }),
    i(2),
    t({ "", "3. " }),
    i(3),
    i(0),
  }),

  -- Reference link
  s("ref", {
    t("["),
    i(1, "text"),
    t("]["),
    i(2, "ref"),
    t("]"),
    i(0),
  }),

  -- Definition
  s("def", {
    t("["),
    i(1, "ref"),
    t("]: "),
    i(2, "url"),
    t(' "'),
    i(3, "title"),
    t('"'),
    i(0),
  }),
}
