--
-- C++ snippets - Modern, concise templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

-- Add dynamic node support
local d = ls.dynamic_node
local sn = ls.snippet_node

-- Helper functions
local function get_filename()
	return vim.fn.expand("%:t:r") or "untitled"
end

local function get_class_name()
	local filename = vim.fn.expand("%:t:r") or "Untitled"
	return filename:gsub("^%l", string.upper):gsub("_(%l)", function(match)
		return match:upper()
	end)
end

return {
	-- Main function
	s("main", {
		t({ "#include <iostream>", "", "" }),
		t({ "int main(int argc, char* argv[]) {", "" }),
		t({ "  " }),
		i(1, 'std::cout << "Hello, World!" << std::endl;'),
		t({ "", "" }),
		t({ "  return 0;", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Class
	s("class", {
		t({ "class " }),
		i(1, "ClassName"),
		t({ " {", "" }),
		t({ " public:", "" }),
		t({ "  " }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t({ "() = default;", "" }),
		t({ "  ~" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t({ "() = default;", "" }),
		t({ "", " private:", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "};" }),
		i(0),
	}),

	-- Function
	s("fn", {
		i(1, "void"),
		t({ " " }),
		i(2, "functionName"),
		t({ "(" }),
		i(3),
		t({ ") {", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Lambda
	s("lambda", {
		t({ "auto " }),
		i(1, "lambda"),
		t({ " = [" }),
		i(2, "&"),
		t({ "](" }),
		i(3),
		t({ ") {", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "};" }),
		i(0),
	}),

	-- For loop
	s("for", {
		t({ "for (" }),
		i(1, "int i = 0"),
		t({ "; " }),
		i(2, "i < n"),
		t({ "; " }),
		i(3, "++i"),
		t({ ") {", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Range-based for
	s("forr", {
		t({ "for (" }),
		c(1, { t("const auto&"), t("auto&"), t("auto") }),
		t({ " " }),
		i(2, "item"),
		t({ " : " }),
		i(3, "container"),
		t({ ") {", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Unique pointer
	s("uptr", {
		t({ "auto " }),
		i(1, "ptr"),
		t({ " = std::make_unique<" }),
		i(2, "Type"),
		t({ ">(" }),
		i(3),
		t({ ");" }),
		i(0),
	}),

	-- Shared pointer
	s("sptr", {
		t({ "auto " }),
		i(1, "ptr"),
		t({ " = std::make_shared<" }),
		i(2, "Type"),
		t({ ">(" }),
		i(3),
		t({ ");" }),
		i(0),
	}),

	-- Vector
	s("vec", {
		t({ "std::vector<" }),
		i(1, "int"),
		t({ "> " }),
		i(2, "vec"),
		t({ ";" }),
		i(0),
	}),

	-- Map
	s("map", {
		t({ "std::map<" }),
		i(1, "int"),
		t({ ", " }),
		i(2, "int"),
		t({ "> " }),
		i(3, "map"),
		t({ ";" }),
		i(0),
	}),

	-- Include guard
	s("guard", {
		t({ "#pragma once", "", "" }),
		i(0),
	}),

	-- Namespace
	s("ns", {
		t({ "namespace " }),
		i(1, "name"),
		t({ " {", "", "" }),
		i(2),
		t({ "", "", "} // namespace " }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
	}),

	-- Try-catch
	s("try", {
		t({ "try {", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t({ "} catch (" }),
		i(2, "const std::exception& e"),
		t({ ") {", "" }),
		t({ "  " }),
		i(3, "std::cerr << e.what() << std::endl;"),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Template function
	s("templatefn", {
		t({ "template <typename " }),
		i(1, "T"),
		t({ ">", "" }),
		i(2, "void"),
		t({ " " }),
		i(3, "functionName"),
		t({ "(" }),
		i(4, "T value"),
		t({ ") {", "" }),
		t({ "  " }),
		i(5),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Enum class
	s("enum", {
		t({ "enum class " }),
		i(1, "Name"),
		t({ " {", "" }),
		t({ "  " }),
		i(2, "Value1"),
		t({ ",", "" }),
		t({ "  " }),
		i(3, "Value2"),
		t({ "", "" }),
		t({ "};" }),
		i(0),
	}),

	-- Struct
	s("struct", {
		t({ "struct " }),
		i(1, "Name"),
		t({ " {", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "};" }),
		i(0),
	}),

	-- If statement
	s("if", {
		t({ "if (" }),
		i(1, "condition"),
		t({ ") {", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Switch
	s("switch", {
		t({ "switch (" }),
		i(1, "value"),
		t({ ") {", "" }),
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
		t({ "  break;", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Constructor initializer list
	s("ctor", {
		i(1, "ClassName"),
		t({ "(" }),
		i(2),
		t({ ")" }),
		t({ " : " }),
		i(3, "member_(value)"),
		t({ " {", "" }),
		t({ "  " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Header file template
	s("hfile", {
		t({ "#pragma once", "", "" }),
		i(1),
		i(0),
	}),

	-- Source file template
	s("cppfile", {
		t({ '#include "' }),
		i(1, f(get_filename, {})),
		t({ '.h"', "", "" }),
		i(2),
		i(0),
	}),

	-- cout
	s("cout", {
		t({ "std::cout << " }),
		i(1),
		t({ " << std::endl;" }),
		i(0),
	}),

	-- cerr
	s("cerr", {
		t({ "std::cerr << " }),
		i(1),
		t({ " << std::endl;" }),
		i(0),
	}),

	-- cin
	s("cin", {
		t({ "std::cin >> " }),
		i(1),
		t({ ";" }),
		i(0),
	}),

	-- Assert
	s("assert", {
		t({ "assert(" }),
		i(1, "condition"),
		t({ ");" }),
		i(0),
	}),

	-- While loop
	s("while", {
		t({ "while (" }),
		i(1, "condition"),
		t({ ") {", "" }),
		t({ "  " }),
		i(2),
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
		t({ "} while (" }),
		i(2, "condition"),
		t({ ");" }),
		i(0),
	}),

	-- Const reference parameter
	s("cref", {
		t({ "const " }),
		i(1, "Type"),
		t({ "& " }),
		i(2, "param"),
	}),

	-- Move semantic
	s("move", {
		t({ "std::move(" }),
		i(1),
		t({ ")" }),
	}),

	-- Forward
	s("fwd", {
		t({ "std::forward<" }),
		i(1, "T"),
		t({ ">(" }),
		i(2),
		t({ ")" }),
	}),

	-- Optional
	s("opt", {
		t({ "std::optional<" }),
		i(1, "Type"),
		t({ "> " }),
		i(2, "opt"),
		t({ ";" }),
		i(0),
	}),

	-- Pair
	s("pair", {
		t({ "std::pair<" }),
		i(1, "int"),
		t({ ", " }),
		i(2, "int"),
		t({ "> " }),
		i(3, "p"),
		t({ ";" }),
		i(0),
	}),

	-- Tuple
	s("tuple", {
		t({ "std::tuple<" }),
		i(1, "int, float, std::string"),
		t({ "> " }),
		i(2, "t"),
		t({ ";" }),
		i(0),
	}),

	-- Array with synchronized placeholders
	s("array", {
		t({ "std::array<" }),
		i(1, "Type"),
		t({ ", " }),
		i(2, "Size"),
		t({ "> " }),
		i(3, "name"),
		t({ ";" }),
		i(0),
	}),

	-- Array with multiple independent targets
	s("arr", {
		t({ "array<" }),
		i(1, "target"),
		t({ ", " }),
		i(2, "target"),
		t({ "> " }),
		i(3, "target"),
		t({ ";" }),
		i(0),
	}),

	-- Generic template instantiation
	s("tmpl", {
		i(1, "Template"),
		t({ "<" }),
		i(2, "T1"),
		t({ ", " }),
		i(3, "T2"),
		t({ "> " }),
		i(4, "instance"),
		t({ ";" }),
		i(0),
	}),

	-- Function template call
	s("fcall", {
		i(1, "function"),
		t({ "<" }),
		i(2, "Type"),
		t({ ">(" }),
		i(3, "args"),
		t({ ");" }),
		i(0),
	}),

	-- Template with variable parameters
	s("template", {
		t({ "template<" }),
		c(1, {
			i(1, "typename T"),
			{ i(1, "typename T1"), t(", "), i(2, "typename T2") },
			{
				i(1, "typename T1"),
				t(", "),
				i(2, "typename T2"),
				t(", "),
				i(3, "typename T3"),
			},
		}),
		t({ ">" }),
		i(0),
	}),

	-- Container with multiple template parameters
	s("container", {
		i(1, "std::vector"),
		t("<"),
		c(2, {
			i(1, "int"),
			{ i(1, "std::pair"), t("<"), i(2, "int"), t(", "), i(3, "int"), t(">") },
			{
				i(1, "std::tuple"),
				t("<"),
				i(2, "int"),
				t(", "),
				i(3, "float"),
				t(", "),
				i(4, "string"),
				t(">"),
			},
		}),
		t("> "),
		i(3, "container"),
		t(";"),
		i(0),
	}),

	-- Simple template with choices
	s("tpl", {
		i(1, "Container"),
		t("<"),
		c(2, {
			t("int"),
			t("float"),
			t("std::string"),
			{ t("std::pair<"), i(1, "int"), t(", "), i(2, "int"), t(">") },
		}),
		t("> "),
		i(3, "name"),
		t(";"),
	}),

	-- Smart array with multiple dimensions
	s("mdarray", {
		t("std::array<"),
		c(1, {
			{ t("std::array<"), i(1, "int"), t(", "), i(2, "3"), t(">") },
			i(1, "int"),
		}),
		t(", "),
		i(2, "5"),
		t("> "),
		i(3, "matrix"),
		t(";"),
		i(0),
	}),
}
