--
-- TODO snippets - Concise task tracking
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
  -- Simple TODO
  s("todo", {
    t("// TODO: "), i(1), i(0)
  }),

  -- FIXME
  s("fixme", {
    t("// FIXME: "), i(1), i(0)
  }),

  -- NOTE
  s("note", {
    t("// NOTE: "), i(1), i(0)
  }),

  -- WARNING
  s("warn", {
    t("// WARNING: "), i(1), i(0)
  }),

  -- HACK
  s("hack", {
    t("// HACK: "), i(1), i(0)
  }),

  -- TODO with author
  s("todoa", {
    t("// TODO("), i(1, "$USER"), t("): "), i(2), i(0)
  }),

  -- Bug
  s("bug", {
    t("// BUG: "), i(1), i(0)
  }),

  -- Issue reference
  s("issue", {
    t("// Issue #"), i(1), t(": "), i(2), i(0)
  }),

  -- Deprecated
  s("deprecated", {
    t("// @deprecated "), i(1, "Use X instead"), i(0)
  }),

  -- TODO with priority
  s("todop", {
    c(1, {t("TODO"), t("FIXME"), t("NOTE")}), t(": ["),
    c(2, {t("HIGH"), t("MED"), t("LOW")}), t("] "), i(3), i(0)
  }),

  -- Review needed
  s("review", {
    t("// REVIEW: "), i(1), i(0)
  }),

  -- Question
  s("question", {
    t("// QUESTION: "), i(1), i(0)
  }),

  -- Optimization needed
  s("optimize", {
    t("// OPTIMIZE: "), i(1), i(0)
  }),

  -- Refactor
  s("refactor", {
    t("// REFACTOR: "), i(1), i(0)
  }),

  -- Test needed
  s("test", {
    t("// TEST: "), i(1), i(0)
  }),
}