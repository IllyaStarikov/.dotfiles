--
-- Python snippets - Modern, concise templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

-- Helper functions
local function get_class_name()
	local filename = vim.fn.expand("%:t:r") or "Class"
	return filename
		:gsub("^%l", string.upper)
		:gsub("_(%l)", function(match)
			return match:upper()
		end)
		:gsub("_", "")
end

return {
	-- Main entry point
	s("main", {
		t({ "def main():", "" }),
		t({ "    " }),
		i(1),
		t({ "", "" }),
		t({ "", "" }),
		t({ "if __name__ == '__main__':", "" }),
		t({ "    main()" }),
		i(0),
	}),

	-- Function
	s("def", {
		t({ "def " }),
		i(1, "function_name"),
		t({ "(" }),
		i(2),
		t({ ")" }),
		c(3, {
			t(""),
			t(" -> None"),
			t(" -> int"),
			t(" -> str"),
			t(" -> bool"),
			t(" -> list"),
			t(" -> dict"),
		}),
		t({ ":", "" }),
		t({ '    """' }),
		i(4, "Brief description"),
		t({ '."""', "" }),
		t({ "    " }),
		i(5, "pass"),
		i(0),
	}),

	-- Async function
	s("async", {
		t({ "async def " }),
		i(1, "function_name"),
		t({ "(" }),
		i(2),
		t({ "):", "" }),
		t({ "    " }),
		i(3, "pass"),
		i(0),
	}),

	-- Class
	s("class", {
		t({ "class " }),
		i(1, f(get_class_name, {})),
		t({ ":", "" }),
		t({ '    """' }),
		i(2, "Brief description"),
		t({ '."""', "" }),
		t({ "    ", "" }),
		t({ "    def __init__(self" }),
		i(3),
		t({ "):", "" }),
		t({ "        " }),
		i(4, "pass"),
		i(0),
	}),

	-- Dataclass
	s("dataclass", {
		t({ "from dataclasses import dataclass", "", "" }),
		t({ "@dataclass", "" }),
		t({ "class " }),
		i(1, "Name"),
		t({ ":", "" }),
		t({ "    " }),
		i(2, "field: int"),
		t({ "", "" }),
		t({ "    " }),
		i(3, "field2: str = 'default'"),
		i(0),
	}),

	-- Method
	s("method", {
		t({ "def " }),
		i(1, "method_name"),
		t({ "(self" }),
		i(2),
		t({ "):", "" }),
		t({ "    " }),
		i(3, "pass"),
		i(0),
	}),

	-- Property
	s("property", {
		t({ "@property", "" }),
		t({ "def " }),
		i(1, "name"),
		t({ "(self):", "" }),
		t({ "    return self._" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		i(0),
	}),

	-- Context manager
	s("with", {
		t({ "with " }),
		i(1, "open('file.txt')"),
		t({ " as " }),
		i(2, "f"),
		t({ ":", "" }),
		t({ "    " }),
		i(3),
		i(0),
	}),

	-- Try-except
	s("try", {
		t({ "try:", "" }),
		t({ "    " }),
		i(1),
		t({ "", "" }),
		t({ "except " }),
		i(2, "Exception"),
		t({ " as e:", "" }),
		t({ "    " }),
		i(3, "pass"),
		i(0),
	}),

	-- List comprehension
	s("lc", {
		t({ "[" }),
		i(1, "x"),
		t({ " for " }),
		i(2, "x"),
		t({ " in " }),
		i(3, "items"),
		t({ "]" }),
		i(0),
	}),

	-- Dict comprehension
	s("dc", {
		t({ "{" }),
		i(1, "k"),
		t({ ": " }),
		i(2, "v"),
		t({ " for " }),
		i(3, "k, v"),
		t({ " in " }),
		i(4, "items.items()"),
		t({ "}" }),
		i(0),
	}),

	-- Generator expression
	s("ge", {
		t({ "(" }),
		i(1, "x"),
		t({ " for " }),
		i(2, "x"),
		t({ " in " }),
		i(3, "items"),
		t({ ")" }),
		i(0),
	}),

	-- Lambda
	s("lambda", {
		t({ "lambda " }),
		i(1, "x"),
		t({ ": " }),
		i(2, "x"),
		i(0),
	}),

	-- Import
	s("imp", {
		t({ "import " }),
		i(1, "module"),
		i(0),
	}),

	-- From import
	s("from", {
		t({ "from " }),
		i(1, "module"),
		t({ " import " }),
		i(2, "name"),
		i(0),
	}),

	-- If name main
	s("ifmain", {
		t({ "if __name__ == '__main__':", "" }),
		t({ "    " }),
		i(1, "main()"),
		i(0),
	}),

	-- Pytest test
	s("test", {
		t({ "def test_" }),
		i(1, "name"),
		t({ "():", "" }),
		t({ "    " }),
		i(2, "assert True"),
		i(0),
	}),

	-- Fixture
	s("fixture", {
		t({ "@pytest.fixture", "" }),
		t({ "def " }),
		i(1, "name"),
		t({ "():", "" }),
		t({ "    " }),
		i(2, "return None"),
		i(0),
	}),

	-- Parametrize
	s("param", {
		t({ "@pytest.mark.parametrize('" }),
		i(1, "arg"),
		t({ "', [", "" }),
		t({ "    " }),
		i(2, "value1"),
		t({ ",", "" }),
		t({ "    " }),
		i(3, "value2"),
		t({ ",", "" }),
		t({ "])", "" }),
		t({ "def test_" }),
		i(4, "name"),
		t({ "(" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t({ "):", "" }),
		t({ "    " }),
		i(5, "pass"),
		i(0),
	}),

	-- Logging
	s("log", {
		t({ "logger." }),
		c(1, { t("info"), t("debug"), t("warning"), t("error"), t("critical") }),
		t({ "(" }),
		i(2, "'message'"),
		t({ ")" }),
		i(0),
	}),

	-- F-string
	s("f", {
		t({ "f'" }),
		i(1),
		t({ "{" }),
		i(2, "var"),
		t({ "}" }),
		i(3),
		t({ "'" }),
		i(0),
	}),

	-- Type hint
	s("type", {
		i(1, "var"),
		t({ ": " }),
		c(2, {
			t("int"),
			t("str"),
			t("bool"),
			t("float"),
			t("list"),
			t("dict"),
			t("tuple"),
			t("set"),
			t("Optional[str]"),
			t("List[str]"),
			t("Dict[str, Any]"),
		}),
		i(0),
	}),

	-- Decorator
	s("deco", {
		t({ "def " }),
		i(1, "decorator"),
		t({ "(func):", "" }),
		t({ "    def wrapper(*args, **kwargs):", "" }),
		t({ "        " }),
		i(2, "# Before"),
		t({ "", "" }),
		t({ "        result = func(*args, **kwargs)", "" }),
		t({ "        " }),
		i(3, "# After"),
		t({ "", "" }),
		t({ "        return result", "" }),
		t({ "    return wrapper" }),
		i(0),
	}),

	-- Enumerate
	s("enum", {
		t({ "for " }),
		i(1, "i"),
		t({ ", " }),
		i(2, "item"),
		t({ " in enumerate(" }),
		i(3, "items"),
		t({ "):", "" }),
		t({ "    " }),
		i(4, "pass"),
		i(0),
	}),

	-- Zip
	s("zip", {
		t({ "for " }),
		i(1, "a"),
		t({ ", " }),
		i(2, "b"),
		t({ " in zip(" }),
		i(3, "list1"),
		t({ ", " }),
		i(4, "list2"),
		t({ "):", "" }),
		t({ "    " }),
		i(5, "pass"),
		i(0),
	}),

	-- Assert
	s("assert", {
		t({ "assert " }),
		i(1, "condition"),
		t({ ", " }),
		i(2, "'error message'"),
		i(0),
	}),

	-- Raise
	s("raise", {
		t({ "raise " }),
		c(1, {
			t("ValueError"),
			t("TypeError"),
			t("KeyError"),
			t("IndexError"),
			t("RuntimeError"),
			t("NotImplementedError"),
		}),
		t({ "(" }),
		i(2, "'message'"),
		t({ ")" }),
		i(0),
	}),

	-- Super
	s("super", {
		t({ "super().__init__(" }),
		i(1),
		t({ ")" }),
		i(0),
	}),

	-- Argparse
	s("argparse", {
		t({ "import argparse", "", "" }),
		t({ "parser = argparse.ArgumentParser(description='" }),
		i(1, "Description"),
		t({ "')", "" }),
		t({ "parser.add_argument('" }),
		i(2, "arg"),
		t({ "', help='" }),
		i(3, "help text"),
		t({ "')", "" }),
		t({ "args = parser.parse_args()" }),
		i(0),
	}),

	-- Dict get
	s("get", {
		i(1, "dict"),
		t({ ".get('" }),
		i(2, "key"),
		t({ "', " }),
		i(3, "default"),
		t({ ")" }),
		i(0),
	}),

	-- String join
	s("join", {
		i(1, "', '"),
		t({ ".join(" }),
		i(2, "items"),
		t({ ")" }),
		i(0),
	}),

	-- Path
	s("path", {
		t({ "from pathlib import Path", "", "" }),
		t({ "path = Path(" }),
		i(1, "'.'"),
		t({ ")" }),
		i(0),
	}),

	-- Datetime
	s("now", {
		t({ "from datetime import datetime", "", "" }),
		t({ "now = datetime.now()" }),
		i(0),
	}),

	-- JSON
	s("json", {
		t({ "import json", "", "" }),
		c(1, {
			t({ "data = json.loads(json_string)" }),
			t({ "json_string = json.dumps(data, indent=2)" }),
		}),
		i(0),
	}),

	-- CSV
	s("csv", {
		t({ "import csv", "", "" }),
		t({ "with open('" }),
		i(1, "file.csv"),
		t({ "', '" }),
		c(2, { t("r"), t("w") }),
		t({ "') as f:", "" }),
		t({ "    " }),
		c(3, {
			t({ "reader = csv.DictReader(f)", "" }),
			t({ "writer = csv.DictWriter(f, fieldnames=['field1', 'field2'])", "" }),
		}),
		t({ "    " }),
		i(4, "pass"),
		i(0),
	}),
}
