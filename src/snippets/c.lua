--
-- C snippets - Modern templates for C development
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Helper functions
local function get_filename()
  return vim.fn.expand('%:t') or 'untitled.c'
end

local function get_project_name()
  return vim.fn.expand('%:p:h:t') or 'project'
end

local function get_date()
  return os.date('%m/%d/%y')
end

local function get_year()
  return os.date('%Y')
end

local function get_header_guard()
  local filename = vim.fn.expand('%:t:r') or 'UNTITLED'
  return string.upper(filename) .. '_H'
end

return {
  -- Complete C file skeleton
  s("skeleton", {
    t({"//"}),
    t({"//  "}), f(get_filename, {}),
    t({"//  "}), f(get_project_name, {}),
    t({"//"}),
    t({"//  Created by Illya Starikov on "}), f(get_date, {}), t({"."}),
    t({"//  Copyright "}), f(get_year, {}), t({". Illya Starikov. All rights reserved."}),
    t({"//"}),
    t({""}),
    t({"#include <stdio.h>"}),
    t({"#include <stdlib.h>"}),
    t({"#include <string.h>"}),
    t({"#include <stdbool.h>"}),
    t({""}),
    i(1, "// Function prototypes"),
    t({""}),
    t({"/**"}),
    t({" * Main function - entry point of the program"}),
    t({" *"}),
    t({" * @param argc Number of command line arguments"}),
    t({" * @param argv Array of command line argument strings"}),
    t({" * @return EXIT_SUCCESS on success, EXIT_FAILURE on error"}),
    t({" */"}),
    t({"int main(int argc, char *argv[]) {"}),
    t({"  "}), i(2, "// Program logic here"),
    t({"  printf(\"Hello, World!\\n\");"),
    t({"  "}),
    t({"  return EXIT_SUCCESS;"}),
    t({"}"}),
    t({""}),
    i(0)
  }),

  -- File header snippet
  s("header", {
    t({"//"}),
    t({"//  "}), f(get_filename, {}),
    t({"//  "}), f(get_project_name, {}),
    t({"//"}),
    t({"//  Created by Illya Starikov on "}), f(get_date, {}), t({"."}),
    t({"//  Copyright "}), f(get_year, {}), t({". Illya Starikov. All rights reserved."}),
    t({"//"}),
    t({""}),
    i(0)
  }),

  -- Main function template
  s("main", {
    t({"#include <stdio.h>"}),
    t({"#include <stdlib.h>"}),
    t({""}),
    t({"int main(int argc, char *argv[]) {"}),
    t({"  "}), i(1, "printf(\"Hello, World!\\n\");"),
    t({"  "}),
    t({"  return EXIT_SUCCESS;"}),
    t({"}"}),
    i(0)
  }),

  -- Function with documentation
  s("func", {
    t({"/**"}),
    t({" * "}), i(1, "Brief function description"),
    t({" *"}),
    t({" * @param "}), i(2, "param"), t({" "}), i(3, "Parameter description"),
    t({" * @return "}), i(4, "Return value description"),
    t({" */"}),
    i(5, "int"), t({" "}), i(6, "function_name"), t({"("}), i(7, "int param"), t({") {"}),
    t({"  "}), i(8, "return 0;"),
    t({"}"}),
    t({""}),
    i(0)
  }),

  -- Struct definition
  s("struct", {
    t({"/**"}),
    t({" * "}), i(1, "Structure description"),
    t({" */"}),
    t({"typedef struct "}), i(2, "struct_name"), t({" {"}),
    t({"  "}), i(3, "int field;"), t({"  /**< "}), i(4, "Field description"), t({" */"}),
    t({"} "}), f(function(args) return args[1][1] end, {2}), t({"_t;"}),
    t({""}),
    i(0)
  }),

  -- Header guard
  s("guard", {
    t({"#ifndef "}), f(get_header_guard, {}),
    t({"#define "}), f(get_header_guard, {}),
    t({""}),
    i(1, "/* Header content */"),
    t({""}),
    t({"#endif /* "}), f(get_header_guard, {}), t({" */"}),
    i(0)
  }),

  -- Include guards for header files
  s("hguard", {
    t({"#pragma once"}),
    t({""}),
    t({"#ifdef __cplusplus"}),
    t({"extern \"C\" {"}),
    t({"#endif"}),
    t({""}),
    i(1, "/* Header declarations */"),
    t({""}),
    t({"#ifdef __cplusplus"}),
    t({"}"}),
    t({"#endif"}),
    i(0)
  }),

  -- For loop
  s("for", {
    t({"for ("}), i(1, "size_t i = 0"), t({"; "}), i(2, "i < n"), t({"; "}), i(3, "i++"), t({") {"}),
    t({"  "}), i(4, "/* loop body */"),
    t({"}"}),
    i(0)
  }),

  -- While loop
  s("while", {
    t({"while ("}), i(1, "condition"), t({") {"}),
    t({"  "}), i(2, "/* loop body */"),
    t({"}"}),
    i(0)
  }),

  -- If-else statement
  s("if", {
    t({"if ("}), i(1, "condition"), t({") {"}),
    t({"  "}), i(2, "/* if body */"),
    t({"} else {"}),
    t({"  "}), i(3, "/* else body */"),
    t({"}"}),
    i(0)
  }),

  -- Switch statement
  s("switch", {
    t({"switch ("}), i(1, "expression"), t({") {"}),
    t({"  case "}), i(2, "value1"), t({":"}),
    t({"    "}), i(3, "/* case 1 */"),
    t({"    break;"}),
    t({"  case "}), i(4, "value2"), t({":"}),
    t({"    "}), i(5, "/* case 2 */"),
    t({"    break;"}),
    t({"  default:"}),
    t({"    "}), i(6, "/* default case */"),
    t({"    break;"}),
    t({"}"}),
    i(0)
  }),

  -- Error handling pattern
  s("error", {
    t({"if ("}), i(1, "function_call()"), t({" != 0) {"}),
    t({"    fprintf(stderr, \"Error: "}), i(2, "error message"), t({"\\n\");"}),
    t({"    return "}), i(3, "EXIT_FAILURE"), t({";"}),
    t({"}"}),
    i(0)
  }),

  -- Memory allocation with error checking
  s("malloc", {
    i(1, "int"), t({" *"}), i(2, "ptr"), t({" = malloc("}), i(3, "size"), t({" * sizeof("}), f(function(args) return args[1][1] end, {1}), t({"));"}),
    t({"if ("}), f(function(args) return args[1][1] end, {2}), t({" == NULL) {"}),
    t({"    fprintf(stderr, \"Memory allocation failed\\n\");"}),
    t({"    return EXIT_FAILURE;"}),
    t({"}"}),
    t({""}),
    i(4, "/* Use allocated memory */"),
    t({""}),
    t({"free("}), f(function(args) return args[1][1] end, {2}), t({");"}),
    t({""}), f(function(args) return args[1][1] end, {2}), t({" = NULL;"}),
    i(0)
  }),

  -- File operations
  s("fopen", {
    t({"FILE *"}), i(1, "file"), t({" = fopen(\""}), i(2, "filename.txt"), t({"\", \""}), i(3, "r"), t({"\");"}),
    t({"if ("}), f(function(args) return args[1][1] end, {1}), t({" == NULL) {"}),
    t({"    perror(\"Error opening file\");"}),
    t({"    return EXIT_FAILURE;"}),
    t({"}"}),
    t({""}),
    i(4, "/* File operations */"),
    t({""}),
    t({"if (fclose("}), f(function(args) return args[1][1] end, {1}), t({") != 0) {"}),
    t({"    perror(\"Error closing file\");"}),
    t({"}"}),
    i(0)
  }),

  -- Printf with common format specifiers
  s("printf", {
    t({"printf(\""}), i(1, "%d\\n"), t({"\", "}), i(2, "variable"), t({");"}),
    i(0)
  }),

  -- Standard library includes
  s("includes", {
    t({"#include <stdio.h>"}),
    t({"#include <stdlib.h>"}),
    t({"#include <string.h>"}),
    t({"#include <stdbool.h>"}),
    t({"#include <stdint.h>"}),
    t({"#include <assert.h>"}),
    t({""}),
    i(0)
  }),

  -- Linked list node
  s("listnode", {
    t({"typedef struct "}), i(1, "node"), t({" {"}),
    t({"  "}), i(2, "int data"), t({";"}),
    t({"    struct "}), f(function(args) return args[1][1] end, {1}), t({" *next;"}),
    t({"} "}), f(function(args) return args[1][1] end, {1}), t({"_t;"}),
    i(0)
  }),
}