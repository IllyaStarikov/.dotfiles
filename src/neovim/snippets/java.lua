--
-- Java snippets - Modern, concise templates
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

-- Helper function
local function get_classname()
  local filename = vim.fn.expand("%:t:r") or "Main"
  return filename:gsub("^%l", string.upper)
end

return {
  -- Main method
  s("main", {
    t({ "public static void main(String[] args) {", "" }),
    t({ "    " }),
    i(1, 'System.out.println("Hello, World!");'),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Class
  s("class", {
    t("public class "),
    i(1, f(get_classname, {})),
    t(" {"),
    t({ "", "" }),
    t({ "    " }),
    i(2),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Interface
  s("interface", {
    t("public interface "),
    i(1, "Name"),
    t(" {"),
    t({ "", "" }),
    t({ "    " }),
    i(2),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Method
  s("method", {
    c(1, { t("public"), t("private"), t("protected") }),
    t(" "),
    i(2, "void"),
    t(" "),
    i(3, "methodName"),
    t("("),
    i(4),
    t(") {"),
    t({ "", "" }),
    t({ "    " }),
    i(5),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Constructor
  s("ctor", {
    t("public "),
    f(get_classname, {}),
    t("("),
    i(1),
    t(") {"),
    t({ "", "" }),
    t({ "    " }),
    i(2),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- For loop
  s("for", {
    t("for ("),
    c(1, {
      {
        t("int "),
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
      { i(1, "Type"), t(" "), i(2, "item"), t(" : "), i(3, "collection") },
    }),
    t(") {"),
    t({ "", "" }),
    t({ "    " }),
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
    t({ "    " }),
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
    t({ "    " }),
    i(2),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Try-catch
  s("try", {
    t({ "try {", "" }),
    t({ "    " }),
    i(1),
    t({ "", "" }),
    t("} catch ("),
    i(2, "Exception"),
    t(" e) {"),
    t({ "", "" }),
    t({ "    " }),
    i(3, "e.printStackTrace();"),
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
    t({ "    case " }),
    i(2, "value"),
    t({ ":", "" }),
    t({ "        " }),
    i(3),
    t({ "", "" }),
    t({ "        break;", "" }),
    t({ "    default:", "" }),
    t({ "        " }),
    i(4),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Enum
  s("enum", {
    t("public enum "),
    i(1, "Name"),
    t(" {"),
    t({ "", "" }),
    t({ "    " }),
    i(2, "VALUE1"),
    t(","),
    t({ "", "" }),
    t({ "    " }),
    i(3, "VALUE2"),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- ArrayList
  s("list", {
    t("List<"),
    i(1, "String"),
    t("> "),
    i(2, "list"),
    t(" = new ArrayList<>();"),
  }),

  -- HashMap
  s("map", {
    t("Map<"),
    i(1, "String"),
    t(", "),
    i(2, "String"),
    t("> "),
    i(3, "map"),
    t(" = new HashMap<>();"),
  }),

  -- Print
  s("sout", {
    t("System.out.println("),
    i(1),
    t(");"),
  }),

  -- Print formatted
  s("souf", {
    t('System.out.printf("'),
    i(1, "%s"),
    t('", '),
    i(2),
    t(");"),
  }),

  -- Import
  s("imp", {
    t("import "),
    i(1, "java.util.*"),
    t(";"),
  }),

  -- Package
  s("package", {
    t("package "),
    i(1, "com.example"),
    t(";"),
  }),

  -- Getter
  s("get", {
    t("public "),
    i(1, "String"),
    t(" get"),
    i(2, "Name"),
    t("() {"),
    t({ "", "" }),
    t({ "    return this." }),
    i(3, "name"),
    t({ ";", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Setter
  s("set", {
    t("public void set"),
    i(1, "Name"),
    t("("),
    i(2, "String"),
    t(" "),
    i(3, "name"),
    t(") {"),
    t({ "", "" }),
    t({ "    this." }),
    f(function(args)
      return args[1][1]
    end, { 3 }),
    t(" = "),
    f(function(args)
      return args[1][1]
    end, { 3 }),
    t({ ";", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Test method (JUnit)
  s("test", {
    t({ "@Test", "" }),
    t("public void test"),
    i(1, "MethodName"),
    t("() {"),
    t({ "", "" }),
    t({ "    " }),
    i(2),
    t({ "", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Equals and hashCode
  s("equals", {
    t({ "@Override", "" }),
    t({ "public boolean equals(Object obj) {", "" }),
    t({ "    if (this == obj) return true;", "" }),
    t({
      "    if (obj == null || getClass() != obj.getClass()) return false;",
      "",
    }),
    t({ "    " }),
    f(get_classname, {}),
    t(" other = ("),
    f(get_classname, {}),
    t({ ") obj;", "" }),
    t({ "    return " }),
    i(1, "Objects.equals(this.field, other.field)"),
    t({ ";", "" }),
    t({ "}" }),
    i(0),
  }),

  -- toString
  s("tostring", {
    t({ "@Override", "" }),
    t({ "public String toString() {", "" }),
    t({ '    return "' }),
    f(get_classname, {}),
    t('{" +'),
    t({ "", "" }),
    t({ "            " }),
    i(1, '"field=" + field'),
    t(" +"),
    t({ "", "" }),
    t({ "            '}';", "" }),
    t({ "}" }),
    i(0),
  }),

  -- Lambda
  s("lambda", {
    t("("),
    i(1),
    t(") -> "),
    c(2, {
      i(1, "expression"),
      { t("{"), t({ "", "    " }), i(1), t({ "", "}" }) },
    }),
  }),

  -- Stream
  s("stream", {
    i(1, "list"),
    t(".stream()"),
    t({ "", "" }),
    t({ "        ." }),
    c(2, {
      t("filter"),
      t("map"),
      t("sorted"),
      t("distinct"),
    }),
    t("("),
    i(3),
    t(")"),
    t({ "", "" }),
    t({ "        .collect(Collectors." }),
    c(4, { t("toList()"), t("toSet()"), t("joining()") }),
    t(");"),
  }),

  -- Optional
  s("opt", {
    t("Optional<"),
    i(1, "String"),
    t("> "),
    i(2, "optional"),
    t(" = Optional."),
    c(3, {
      t("empty()"),
      { t("of("), i(1, "value"), t(")") },
      { t("ofNullable("), i(1, "value"), t(")") },
    }),
    t(";"),
  }),

  -- Final variable
  s("final", {
    t("final "),
    i(1, "String"),
    t(" "),
    i(2, "CONSTANT"),
    t(" = "),
    i(3, '"value"'),
    t(";"),
  }),

  -- Private field
  s("pf", {
    t("private "),
    i(1, "String"),
    t(" "),
    i(2, "fieldName"),
    t(";"),
  }),

  -- Javadoc
  s("doc", {
    t({ "/**", "" }),
    t({ " * " }),
    i(1, "Description"),
    t({ "", "" }),
    t({ " * @param " }),
    i(2, "param"),
    t(" "),
    i(3, "description"),
    t({ "", "" }),
    t({ " * @return " }),
    i(4, "description"),
    t({ "", "" }),
    t({ " */" }),
    i(0),
  }),
}
