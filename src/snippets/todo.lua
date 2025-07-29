--
-- TODO and Issue Tracking snippets
-- For managing tasks, bugs, and project tracking
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

-- Helper functions
local function get_date()
  return os.date("%Y-%m-%d")
end

local function get_author()
  return vim.fn.system("git config user.name"):gsub("\n", "") or "Author"
end

return {
  -- TODO with metadata
  s("todo", {
    c(1, {
      t("TODO"),
      t("FIXME"),
      t("HACK"),
      t("NOTE"),
      t("WARNING"),
      t("OPTIMIZE"),
      t("REFACTOR"),
    }),
    t("("), f(get_author, {}), t(" - "), f(get_date, {}), t("): "),
    i(2, "description"),
    t(" ["),
    c(3, {
      t("priority:high"),
      t("priority:medium"),
      t("priority:low"),
    }),
    t("] ["),
    c(4, {
      t("status:open"),
      t("status:in-progress"),
      t("status:blocked"),
      t("status:done"),
    }),
    t("]"),
    i(0)
  }),

  -- GitHub Issue Reference
  s("issue", {
    t("// Fixes #"), i(1, "issue_number"), t(": "), i(2, "issue_title"),
    t({"", "// See: https://github.com/"}), i(3, "owner/repo"), t("/issues/"), f(function(args) return args[1][1] end, {1}),
    i(0)
  }),

  -- Bug Report Template
  s("bug", {
    t({"/**"}),
    t({" * BUG: "}), i(1, "Brief bug description"),
    t({" * "}),
    t({" * Steps to Reproduce:"}),
    t({" * 1. "}), i(2, "First step"),
    t({" * 2. "}), i(3, "Second step"),
    t({" * 3. "}), i(4, "Third step"),
    t({" * "}),
    t({" * Expected: "}), i(5, "What should happen"),
    t({" * Actual: "}), i(6, "What actually happens"),
    t({" * "}),
    t({" * Environment:"}),
    t({" * - OS: "}), i(7, "macOS 14.0"),
    t({" * - Version: "}), i(8, "1.0.0"),
    t({" * - Browser/Runtime: "}), i(9, "Chrome 120"),
    t({" * "}),
    t({" * Priority: "}), c(10, {t("High"), t("Medium"), t("Low")}),
    t({" * Assigned: "}), i(11, "@username"),
    t({" * "}),
    t({" * Related: #"}), i(12, "related_issue"),
    t({" */"}),
    i(0)
  }),

  -- Feature Request
  s("feature", {
    t({"/**"}),
    t({" * FEATURE REQUEST: "}), i(1, "Feature title"),
    t({" * "}),
    t({" * Description:"}),
    t({" * "}), i(2, "What problem does this solve?"),
    t({" * "}),
    t({" * Proposed Solution:"}),
    t({" * "}), i(3, "How should it work?"),
    t({" * "}),
    t({" * Alternatives Considered:"}),
    t({" * - "}), i(4, "Alternative 1"),
    t({" * - "}), i(5, "Alternative 2"),
    t({" * "}),
    t({" * User Story:"}),
    t({" * As a "}), i(6, "user type"),
    t({" * I want to "}), i(7, "action"),
    t({" * So that "}), i(8, "benefit"),
    t({" * "}),
    t({" * Acceptance Criteria:"}),
    t({" * - [ ] "}), i(9, "Criterion 1"),
    t({" * - [ ] "}), i(10, "Criterion 2"),
    t({" * - [ ] "}), i(11, "Criterion 3"),
    t({" * "}),
    t({" * Priority: "}), c(12, {t("High"), t("Medium"), t("Low"), t("Nice-to-have")}),
    t({" * Effort: "}), c(13, {t("Small"), t("Medium"), t("Large"), t("X-Large")}),
    t({" */"}),
    i(0)
  }),

  -- Technical Debt
  s("debt", {
    t({"/**"}),
    t({" * TECH DEBT: "}), i(1, "What needs refactoring"),
    t({" * "}),
    t({" * Current State:"}),
    t({" * "}), i(2, "Why is this problematic?"),
    t({" * "}),
    t({" * Proposed Improvement:"}),
    t({" * "}), i(3, "How should it be refactored?"),
    t({" * "}),
    t({" * Impact:"}),
    t({" * - Performance: "}), c(4, {t("High"), t("Medium"), t("Low"), t("None")}),
    t({" * - Maintainability: "}), c(5, {t("High"), t("Medium"), t("Low")}),
    t({" * - Security: "}), c(6, {t("High"), t("Medium"), t("Low"), t("None")}),
    t({" * "}),
    t({" * Estimated Effort: "}), i(7, "2-3 days"),
    t({" * "}),
    t({" * Created: "}), f(get_date, {}), t(" by "), f(get_author, {}),
    t({" */"}),
    i(0)
  }),

  -- Performance Issue
  s("perf", {
    t({"/**"}),
    t({" * PERFORMANCE: "}), i(1, "Performance issue"),
    t({" * "}),
    t({" * Metrics:"}),
    t({" * - Current: "}), i(2, "500ms load time"),
    t({" * - Target: "}), i(3, "200ms load time"),
    t({" * "}),
    t({" * Bottleneck:"}),
    t({" * "}), i(4, "What's causing the slowdown?"),
    t({" * "}),
    t({" * Optimization Strategy:"}),
    t({" * 1. "}), i(5, "First optimization"),
    t({" * 2. "}), i(6, "Second optimization"),
    t({" * "}),
    t({" * Benchmark: "}), i(7, "benchmark_name"),
    t({" * Profile: "}), i(8, "profile_link"),
    t({" */"}),
    i(0)
  }),

  -- Security Issue
  s("security", {
    t({"/**"}),
    t({" * SECURITY: "}), i(1, "Security concern"),
    t({" * "}),
    t({" * Severity: "}), c(2, {t("Critical"), t("High"), t("Medium"), t("Low")}),
    t({" * "}),
    t({" * Vulnerability:"}),
    t({" * "}), i(3, "Description of the security issue"),
    t({" * "}),
    t({" * Attack Vector:"}),
    t({" * "}), i(4, "How could this be exploited?"),
    t({" * "}),
    t({" * Mitigation:"}),
    t({" * "}), i(5, "How to fix this issue"),
    t({" * "}),
    t({" * CVE: "}), i(6, "CVE-YYYY-XXXXX"),
    t({" * OWASP: "}), i(7, "A1-Injection"),
    t({" * "}),
    t({" * Status: "}), c(8, {t("Unpatched"), t("In Progress"), t("Patched"), t("Verified")}),
    t({" */"}),
    i(0)
  }),

  -- Code Review Note
  s("review", {
    t("// REVIEW("), f(get_author, {}), t(" - "), f(get_date, {}), t("): "),
    i(1, "This needs review because..."),
    t({" ", "// Concerns: "}), 
    c(2, {
      t("Logic correctness"),
      t("Performance impact"),
      t("Security implications"),
      t("Code style"),
      t("Test coverage"),
      t("Documentation"),
    }),
    i(0)
  }),

  -- Deprecation Notice
  s("deprecated", {
    t({"/**"}),
    t({" * @deprecated Since version "}), i(1, "2.0.0"), t({". Will be removed in "}), i(2, "3.0.0"), t({"."}),
    t({" * @see "}), i(3, "newFunction"), t({" Use this instead."}),
    t({" * "}),
    t({" * Migration Guide:"}),
    t({" * "}), i(4, "How to migrate to the new API"),
    t({" */"}),
    i(0)
  }),

  -- Simple inline TODOs
  s("td", {
    t("// TODO: "), i(1, "task"), i(0)
  }),

  s("fx", {
    t("// FIXME: "), i(1, "issue"), i(0)
  }),

  s("hk", {
    t("// HACK: "), i(1, "temporary solution"), i(0)
  }),

  s("nt", {
    t("// NOTE: "), i(1, "important note"), i(0)
  }),

  -- Task tracking
  s("task", {
    t("// TASK-"), i(1, "JIRA-123"), t(": "), i(2, "Implement feature X"),
    t(" ("), c(3, {t("Not Started"), t("In Progress"), t("Blocked"), t("Done")}), t(")"),
    i(0)
  }),
}