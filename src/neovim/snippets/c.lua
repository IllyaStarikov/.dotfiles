--
-- C snippets - Concise, practical templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
	-- Main function
	s("main", {
		t({ "#include <stdio.h>", "", "" }),
		t({ "int main(int argc, char *argv[]) {", "" }),
		t({ "  " }),
		i(1, 'printf("Hello, World!\\n");'),
		t({ "", "" }),
		t({ "  return 0;", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Function
	s("fn", {
		i(1, "void"),
		t(" "),
		i(2, "function_name"),
		t("("),
		i(3),
		t(") {"),
		t({ "", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Header guard
	s("guard", {
		t("#ifndef "),
		i(1, "HEADER_H"),
		t({ "", "" }),
		t("#define "),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t({ "", "", "" }),
		i(2),
		t({ "", "", "#endif /* " }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(" */"),
		i(0),
	}),

	-- Include
	s("inc", {
		t("#include "),
		c(1, {
			{ t("<"), i(1, "stdio.h"), t(">") },
			{ t('"'), i(1, "header.h"), t('"') },
		}),
		i(0),
	}),

	-- Struct
	s("struct", {
		t("typedef struct "),
		i(1, "name"),
		t(" {"),
		t({ "", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t("} "),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t("_t;"),
		i(0),
	}),

	-- Enum
	s("enum", {
		t("typedef enum {"),
		t({ "", "" }),
		t({ "  " }),
		i(1, "VALUE1"),
		t(","),
		t({ "", "" }),
		t({ "  " }),
		i(2, "VALUE2"),
		t({ "", "" }),
		t("} "),
		i(3, "name"),
		t("_t;"),
		i(0),
	}),

	-- For loop
	s("for", {
		t("for ("),
		i(1, "int i = 0"),
		t("; "),
		i(2, "i < n"),
		t("; "),
		i(3, "i++"),
		t(") {"),
		t({ "", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- While loop
	s("while", {
		t("while ("),
		i(1, "condition"),
		t(") {"),
		t({ "", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- If statement
	s("if", {
		t("if ("),
		i(1, "condition"),
		t(") {"),
		t({ "", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Switch
	s("switch", {
		t("switch ("),
		i(1, "variable"),
		t(") {"),
		t({ "", "" }),
		t({ "case " }),
		i(2, "1"),
		t({ ":", "" }),
		t({ "  " }),
		i(3),
		t({ "", "" }),
		t({ "  break;", "" }),
		t({ "default:", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Printf
	s("pr", {
		t('printf("'),
		i(1, "%d\\n"),
		t('", '),
		i(2),
		t(");"),
		i(0),
	}),

	-- Scanf
	s("sc", {
		t('scanf("'),
		i(1, "%d"),
		t('", '),
		i(2, "&variable"),
		t(");"),
		i(0),
	}),

	-- Malloc
	s("malloc", {
		i(1, "int"),
		t(" *"),
		i(2, "ptr"),
		t(" = ("),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(" *)malloc("),
		i(3, "size"),
		t(" * sizeof("),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t("));"),
		t({ "", "" }),
		t("if ("),
		f(function(args)
			return args[1][1]
		end, { 2 }),
		t(" == NULL) {"),
		t({ "", "" }),
		t({ '  perror("malloc");', "" }),
		t({ "  exit(1);", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Free
	s("free", {
		t("free("),
		i(1, "ptr"),
		t(");"),
		t({ "", "" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(" = NULL;"),
		i(0),
	}),

	-- File operations
	s("fopen", {
		t("FILE *"),
		i(1, "fp"),
		t(' = fopen("'),
		i(2, "filename"),
		t('", "'),
		c(3, { t("r"), t("w"), t("a") }),
		t('");'),
		t({ "", "" }),
		t("if ("),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(" == NULL) {"),
		t({ "", "" }),
		t({ '  perror("fopen");', "" }),
		t({ "  return 1;", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Error check
	s("err", {
		t("if ("),
		i(1, "condition"),
		t(") {"),
		t({ "", "" }),
		t({ '  fprintf(stderr, "Error: ' }),
		i(2, "message"),
		t({ '\\n");', "" }),
		t({ "  return " }),
		i(3, "1"),
		t({ ";", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Define
	s("def", {
		t("#define "),
		i(1, "NAME"),
		t(" "),
		i(2, "value"),
		i(0),
	}),

	-- Typedef
	s("td", {
		t("typedef "),
		i(1, "int"),
		t(" "),
		i(2, "name"),
		t(";"),
		i(0),
	}),

	-- Static function
	s("sfn", {
		t("static "),
		i(1, "void"),
		t(" "),
		i(2, "function_name"),
		t("("),
		i(3),
		t(") {"),
		t({ "", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Do-while
	s("do", {
		t({ "do {", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t("} while ("),
		i(2, "condition"),
		t(");"),
		i(0),
	}),

	-- Assert
	s("assert", {
		t("#include <assert.h>"),
		t({ "", "" }),
		t("assert("),
		i(1, "condition"),
		t(");"),
		i(0),
	}),

	-- Linked list node
	s("node", {
		t("typedef struct "),
		i(1, "node"),
		t(" {"),
		t({ "", "" }),
		t({ "  " }),
		i(2, "int data"),
		t({ ";", "" }),
		t({ "  struct " }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t({ " *next;", "" }),
		t("} "),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t("_t;"),
		i(0),
	}),
}
