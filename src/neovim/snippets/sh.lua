--
-- Shell snippets - Concise, practical templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

return {
	-- Shebang
	s("shebang", {
		t("#!/bin/"),
		c(1, { t("bash"), t("sh"), t("zsh") }),
		i(0),
	}),

	-- Function
	s("fn", {
		i(1, "function_name"),
		t("() {"),
		t({ "", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- If statement
	s("if", {
		t("if "),
		c(1, { t("[[ "), t("[ ") }),
		i(2, "condition"),
		c(3, { t(" ]]"), t(" ]") }),
		t("; then"),
		t({ "", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "fi" }),
		i(0),
	}),

	-- If-else
	s("ife", {
		t("if [[ "),
		i(1, "condition"),
		t(" ]]; then"),
		t({ "", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "else", "" }),
		t({ "  " }),
		i(3),
		t({ "", "" }),
		t({ "fi" }),
		i(0),
	}),

	-- For loop
	s("for", {
		t("for "),
		i(1, "i"),
		t(" in "),
		i(2, "$@"),
		t("; do"),
		t({ "", "" }),
		t({ "  " }),
		i(3),
		t({ "", "" }),
		t({ "done" }),
		i(0),
	}),

	-- While loop
	s("while", {
		t("while "),
		c(1, { t("[[ "), t("[ ") }),
		i(2, "condition"),
		c(3, { t(" ]]"), t(" ]") }),
		t("; do"),
		t({ "", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "done" }),
		i(0),
	}),

	-- Case statement
	s("case", {
		t("case "),
		i(1, "$1"),
		t(" in"),
		t({ "", "" }),
		t({ "  " }),
		i(2, "pattern"),
		t({ ")" }),
		t({ "", "" }),
		t({ "    " }),
		i(3),
		t({ "", "" }),
		t({ "    ;;", "" }),
		t({ "  *)", "" }),
		t({ "    " }),
		i(4),
		t({ "", "" }),
		t({ "    ;;", "" }),
		t({ "esac" }),
		i(0),
	}),

	-- Variable assignment
	s("var", {
		i(1, "VAR"),
		t("="),
		c(2, {
			{ t('"'), i(1, "value"), t('"') },
			{ t("$("), i(1, "command"), t(")") },
			i(1, "value"),
		}),
		i(0),
	}),

	-- Array
	s("array", {
		i(1, "arr"),
		t("=("),
		i(2, "item1 item2 item3"),
		t(")"),
		i(0),
	}),

	-- Echo
	s("echo", {
		t("echo "),
		c(1, { t("-e "), t("-n "), t("") }),
		t('"'),
		i(2),
		t('"'),
		i(0),
	}),

	-- Exit on error
	s("errexit", {
		t("set -euo pipefail"),
		i(0),
	}),

	-- Check command exists
	s("exists", {
		t("command -v "),
		i(1, "cmd"),
		t(' &> /dev/null || { echo "'),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(' not found"; exit 1; }'),
		i(0),
	}),

	-- Getopts
	s("getopts", {
		t({ 'while getopts "h', "" }),
		i(1, ":"),
		t('" opt; do'),
		t({ "", "" }),
		t({ "  case $opt in", "" }),
		t({ "    h)", "" }),
		t({ '      echo "Usage: $0 [-h]"', "" }),
		t({ "      exit 0", "" }),
		t({ "      ;;", "" }),
		t({ "    \\?)", "" }),
		t({ '      echo "Invalid option: -$OPTARG" >&2', "" }),
		t({ "      exit 1", "" }),
		t({ "      ;;", "" }),
		t({ "  esac", "" }),
		t({ "done" }),
		i(0),
	}),

	-- Read user input
	s("read", {
		t('read -p "'),
		i(1, "Enter value: "),
		t('" '),
		i(2, "variable"),
		i(0),
	}),

	-- Redirect
	s("redirect", {
		c(1, {
			{ t("> "), i(1, "file") },
			{ t(">> "), i(1, "file") },
			{ t("2>&1") },
			{ t("&> "), i(1, "file") },
			{ t("< "), i(1, "file") },
		}),
		i(0),
	}),

	-- Source
	s("source", {
		c(1, { t("source "), t(". ") }),
		i(2, "file.sh"),
		i(0),
	}),

	-- Command substitution
	s("cmd", {
		t("$("),
		i(1, "command"),
		t(")"),
		i(0),
	}),

	-- Here document
	s("here", {
		t("cat << "),
		i(1, "EOF"),
		t({ "", "" }),
		i(2, "content"),
		t({ "", "" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		i(0),
	}),

	-- Trap
	s("trap", {
		t("trap '"),
		i(1, "cleanup"),
		t("' "),
		c(2, { t("EXIT"), t("INT"), t("TERM") }),
		i(0),
	}),

	-- Debug
	s("debug", {
		c(1, {
			t("set -x"),
			t("set +x"),
			t('echo "DEBUG: $1" >&2'),
		}),
		i(0),
	}),

	-- Check if file exists
	s("iff", {
		t("if [[ -"),
		c(1, { t("f"), t("d"), t("e"), t("r"), t("w"), t("x") }),
		t(" "),
		i(2, "file"),
		t(" ]]; then"),
		t({ "", "" }),
		t({ "  " }),
		i(3),
		t({ "", "" }),
		t({ "fi" }),
		i(0),
	}),

	-- Function with return value
	s("fnr", {
		i(1, "function_name"),
		t("() {"),
		t({ "", "" }),
		t({ "  local result", "" }),
		t({ "  " }),
		i(2, 'result="value"'),
		t({ "", "" }),
		t({ '  echo "$result"', "" }),
		t({ "}" }),
		i(0),
	}),
}
