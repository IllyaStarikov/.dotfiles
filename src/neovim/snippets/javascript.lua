--
-- JavaScript/TypeScript snippets - Modern, concise templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

-- Helper function
local function get_component_name()
	local filename = vim.fn.expand("%:t:r") or "Component"
	return filename:gsub("^%l", string.upper)
end

return {
	-- Function
	s("fn", {
		c(1, { t("function"), t("const"), t("let") }),
		t(" "),
		i(2, "name"),
		t(" = "),
		c(3, { t("("), t("async (") }),
		i(4),
		t(") => {"),
		t({ "", "" }),
		t({ "  " }),
		i(5),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Arrow function
	s("af", {
		t("const "),
		i(1, "name"),
		t(" = ("),
		i(2),
		t(") => "),
		c(3, {
			t("{}"),
			{ t("{"), t({ "", "  " }), i(1), t({ "", "}" }) },
		}),
		i(0),
	}),

	-- Async function
	s("async", {
		t("async "),
		c(1, { t("function"), t("() =>") }),
		t(" {"),
		t({ "", "" }),
		t({ "  " }),
		i(2),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- React functional component
	s("rfc", {
		t("const "),
		i(1, f(get_component_name, {})),
		t(" = ("),
		i(2),
		t(") => {"),
		t({ "", "" }),
		t({ "  return (", "" }),
		t({ "    <div>", "" }),
		t({ "      " }),
		i(3),
		t({ "", "" }),
		t({ "    </div>", "" }),
		t({ "  )", "" }),
		t({ "}" }),
		i(0),
	}),

	-- React component with export
	s("rfce", {
		t("const "),
		i(1, f(get_component_name, {})),
		t(" = ("),
		i(2),
		t(") => {"),
		t({ "", "" }),
		t({ "  return (", "" }),
		t({ "    <div>", "" }),
		t({ "      " }),
		i(3),
		t({ "", "" }),
		t({ "    </div>", "" }),
		t({ "  )", "" }),
		t({ "}", "", "" }),
		t("export default "),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		i(0),
	}),

	-- useState hook
	s("useState", {
		t("const ["),
		i(1, "state"),
		t(", set"),
		f(function(args)
			return args[1][1]:gsub("^%l", string.upper)
		end, { 1 }),
		t("] = useState("),
		i(2),
		t(")"),
	}),

	-- useEffect hook
	s("useEffect", {
		t({ "useEffect(() => {", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t("}, ["),
		i(2),
		t("])"),
	}),

	-- Import
	s("imp", {
		t("import "),
		i(1, "name"),
		t(" from '"),
		i(2, "module"),
		t("'"),
	}),

	-- Import destructured
	s("imd", {
		t("import { "),
		i(1),
		t(" } from '"),
		i(2, "module"),
		t("'"),
	}),

	-- Export
	s("exp", {
		t("export "),
		c(1, { t("default"), t("const"), t("") }),
		t(" "),
		i(2),
	}),

	-- Console log
	s("cl", {
		t("console.log("),
		i(1),
		t(")"),
	}),

	-- Console error
	s("ce", {
		t("console.error("),
		i(1),
		t(")"),
	}),

	-- Try catch
	s("try", {
		t({ "try {", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t("} catch ("),
		i(2, "error"),
		t({ ") {", "" }),
		t({ "  " }),
		i(3, "console.error(error)"),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Promise
	s("prom", {
		t("new Promise((resolve, reject) => {"),
		t({ "", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t({ "})" }),
	}),

	-- Async/await
	s("await", {
		t("const "),
		i(1, "result"),
		t(" = await "),
		i(2, "promise"),
	}),

	-- Fetch
	s("fetch", {
		t("const "),
		i(1, "response"),
		t(" = await fetch('"),
		i(2, "url"),
		t("'"),
		c(3, {
			t(""),
			{ t(", {"), t({ "", "  method: '" }), i(1, "GET"), t("'"), t({ "", "}" }) },
		}),
		t(")"),
		t({ "", "" }),
		t("const "),
		i(4, "data"),
		t(" = await "),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(".json()"),
	}),

	-- Map
	s("map", {
		i(1, "array"),
		t(".map(("),
		i(2, "item"),
		t(") => "),
		c(3, {
			t("{}"),
			{ t("{"), t({ "", "  return " }), i(1), t({ "", "}" }) },
		}),
		t(")"),
	}),

	-- Filter
	s("filter", {
		i(1, "array"),
		t(".filter(("),
		i(2, "item"),
		t(") => "),
		i(3, "condition"),
		t(")"),
	}),

	-- Reduce
	s("reduce", {
		i(1, "array"),
		t(".reduce(("),
		i(2, "acc"),
		t(", "),
		i(3, "item"),
		t(") => {"),
		t({ "", "" }),
		t({ "  " }),
		i(4, "return acc"),
		t({ "", "" }),
		t("}, "),
		i(5, "initial"),
		t(")"),
	}),

	-- Class
	s("class", {
		t("class "),
		i(1, "ClassName"),
		t(" {"),
		t({ "", "" }),
		t({ "  constructor(" }),
		i(2),
		t({ ") {", "" }),
		t({ "    " }),
		i(3),
		t({ "", "" }),
		t({ "  }", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Method
	s("method", {
		i(1, "name"),
		t("("),
		i(2),
		t(") {"),
		t({ "", "" }),
		t({ "  " }),
		i(3),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- For loop
	s("for", {
		t("for ("),
		c(1, {
			{
				t("let "),
				i(1, "i"),
				t(" = 0; "),
				f(function(args)
					return args[1][1]
				end, { 1 }),
				t(" < "),
				i(2, "length"),
				t("; "),
				f(function(args)
					return args[1][1]
				end, { 1 }),
				t("++"),
			},
			{ t("const "), i(1, "item"), t(" of "), i(2, "array") },
			{ t("const "), i(1, "key"), t(" in "), i(2, "object") },
		}),
		t(") {"),
		t({ "", "" }),
		t({ "  " }),
		i(3),
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

	-- Ternary
	s("ter", {
		i(1, "condition"),
		t(" ? "),
		i(2, "true"),
		t(" : "),
		i(3, "false"),
	}),

	-- Switch
	s("switch", {
		t("switch ("),
		i(1, "expression"),
		t({ ") {", "" }),
		t({ "  case " }),
		i(2, "value"),
		t({ ":", "" }),
		t({ "    " }),
		i(3),
		t({ "", "" }),
		t({ "    break", "" }),
		t({ "  default:", "" }),
		t({ "    " }),
		i(4),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- Object destructuring
	s("des", {
		t("const { "),
		i(1),
		t(" } = "),
		i(2, "object"),
	}),

	-- Array destructuring
	s("desa", {
		t("const [ "),
		i(1),
		t(" ] = "),
		i(2, "array"),
	}),

	-- Module exports
	s("module", {
		t("module.exports = "),
		i(1, "{}"),
	}),

	-- Require
	s("req", {
		t("const "),
		i(1, "name"),
		t(" = require('"),
		i(2, "module"),
		t("')"),
	}),

	-- Timeout
	s("timeout", {
		t("setTimeout(() => {"),
		t({ "", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t("}, "),
		i(2, "1000"),
		t(")"),
	}),

	-- Interval
	s("interval", {
		t("setInterval(() => {"),
		t({ "", "" }),
		t({ "  " }),
		i(1),
		t({ "", "" }),
		t("}, "),
		i(2, "1000"),
		t(")"),
	}),

	-- JSON parse
	s("jp", {
		t("JSON.parse("),
		i(1),
		t(")"),
	}),

	-- JSON stringify
	s("js", {
		t("JSON.stringify("),
		i(1),
		t(", null, 2)"),
	}),

	-- Template literal
	s("tl", {
		t("`"),
		i(1),
		t("${"),
		i(2),
		t("}"),
		i(3),
		t("`"),
	}),

	-- TypeScript interface
	s("int", {
		t("interface "),
		i(1, "Name"),
		t(" {"),
		t({ "", "" }),
		t({ "  " }),
		i(2, "property: type"),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),

	-- TypeScript type
	s("type", {
		t("type "),
		i(1, "Name"),
		t(" = "),
		i(2, "string"),
	}),

	-- Custom hook
	s("hook", {
		t("const use"),
		i(1, "Name"),
		t(" = ("),
		i(2),
		t(") => {"),
		t({ "", "" }),
		t({ "  " }),
		i(3),
		t({ "", "" }),
		t({ "  return " }),
		i(4, "{}"),
		t({ "", "" }),
		t({ "}" }),
		i(0),
	}),
}
