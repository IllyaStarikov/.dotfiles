--
-- C++ snippets - Google C++ Style Guide compliant templates
-- Following https://google.github.io/styleguide/cppguide.html
--

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Helper functions following Google naming conventions
local function get_filename()
  return vim.fn.expand('%:t') or 'untitled.cpp'
end

local function get_class_name()
  local filename = vim.fn.expand('%:t:r') or 'Untitled'
  -- Convert to PascalCase (Google style for classes)
  return filename:gsub("^%l", string.upper):gsub("_(%l)", string.upper):gsub("_", "")
end

local function get_namespace_name()
  local project = vim.fn.expand('%:p:h:t') or 'project'
  return project:lower():gsub('-', '_')
end

local function get_header_guard()
  local path = vim.fn.expand('%:p:h:t') or 'PROJECT'
  local filename = vim.fn.expand('%:t:r') or 'UNTITLED'
  return string.upper(path) .. '_' .. string.upper(filename) .. '_H_'
end

local function get_date()
  return os.date('%Y-%m-%d')
end

local function get_year()
  return os.date('%Y')
end

return {
  -- Google-style file header with copyright
  s("header", {
    t({"// Copyright "}), f(get_year, {}), t({" Illya Starikov"}),
    t({"//"}),
    t({"// Licensed under the Apache License, Version 2.0 (the \"License\");"}),
    t({"// you may not use this file except in compliance with the License."}),
    t({"// You may obtain a copy of the License at"}),
    t({"//"}),
    t({"//     http://www.apache.org/licenses/LICENSE-2.0"}),
    t({"//"}),
    t({"// Unless required by applicable law or agreed to in writing, software"}),
    t({"// distributed under the License is distributed on an \"AS IS\" BASIS,"}),
    t({"// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."}),
    t({"// See the License for the specific language governing permissions and"}),
    t({"// limitations under the License."}),
    t({""}),
    t({"// "}), i(1, "Brief description of the file's purpose"),
    t({"//"}),
    t({"// Author: Illya Starikov ("}), i(2, "email@example.com"), t({")"}),
    t({"// Created: "}), f(get_date, {}),
    t({""}),
    i(0)
  }),

  -- Google-style main function with modern C++
  s("main", {
    t({"#include <iostream>"}),
    t({"#include <memory>"}),
    t({"#include <string>"}),
    t({"#include <vector>"}),
    t({""}),
    t({"#include \"absl/flags/flag.h\""}),
    t({"#include \"absl/flags/parse.h\""}),
    t({"#include \"absl/flags/usage.h\""}),
    t({"#include \"absl/log/initialize.h\""}),
    t({"#include \"absl/log/log.h\""}),
    t({""}),
    t({"ABSL_FLAG(std::string, "}), i(1, "input"), t({", \"\", \""}), i(2, "Input file path"), t({"\");"}),
    t({"ABSL_FLAG(bool, verbose, false, \"Enable verbose output\");"}),
    t({""}),
    t({"namespace "}), f(get_namespace_name, {}), t({" {"}),
    t({""}),
    t({"// Main application logic"}),
    t({"int RunApplication() {"}),
    t({"  if (absl::GetFlag(FLAGS_verbose)) {"}),
    t({"    LOG(INFO) << \"Starting application with verbose mode\";"}),
    t({"  }"}),
    t({"  "}),
    t({"  "}), i(3, "// Application implementation"},
    t({"  "}), i(4, "std::cout << \"Hello, World!\" << std::endl;"},
    t({"  "}),
    t({"  return 0;"}),
    t({"}"}),
    t({""}),
    t({"} // namespace "}), f(get_namespace_name, {}),
    t({""}),
    t({"int main(int argc, char* argv[]) {"}),
    t({"  absl::SetProgramUsageMessage(\""}), i(5, "Program description"), t({"\");"}),
    t({"  absl::ParseCommandLine(argc, argv);"}),
    t({"  absl::InitializeLog();"}),
    t({"  "}),
    t({"  return "}), f(get_namespace_name, {}), t({"::RunApplication();"}),
    t({"}"}),
    i(0)
  }),

  -- Google-style class definition with comprehensive documentation
  s("class", {
    t({"// "}), i(1, "Brief description of the class purpose"),
    t({"//"}),
    t({"// "}), i(2, "Detailed description of what this class does, its responsibilities,"},
    t({"// "}), i(3, "and how it fits into the overall system architecture."},
    t({"//"}),
    t({"// Example usage:"}),
    t({"//   "}), f(get_class_name, {}), t({" "}), i(4, "instance"), t({";"}),
    t({"//   "}), f(function(args) return args[1][1] end, {4}), t({"."}), i(5, "DoSomething"), t({"();"}),
    t({"//"}),
    t({"// Thread safety: "}), i(6, "This class is not thread-safe"},
    t({"class "}), f(get_class_name, {}), t({" {"}),
    t({" public:"}),
    t({"  // Default constructor"}),
    t({"  "}), f(get_class_name, {}), t({"() = default;"}),
    t({""}),
    t({"  // Explicit constructor"}),
    t({"  explicit "}), f(get_class_name, {}), t({"("}), i(7, "std::string_view name"), t({")"}),
    t({"      : "}), i(8, "name_"), t({"("}), f(function(args) return args[1][1]:gsub("std::string_view ", "") end, {7}), t({") {}"}),
    t({""}),
    t({"  // Destructor"}),
    t({"  ~"}), f(get_class_name, {}), t({"() = default;"}),
    t({""}),
    t({"  // Copy operations"}),
    t({"  "}), f(get_class_name, {}), t({"(const "}), f(get_class_name, {}), t({"& other) = default;"}),
    t({"  "}), f(get_class_name, {}), t({"& operator=(const "}), f(get_class_name, {}), t({"& other) = default;"}),
    t({""}),
    t({"  // Move operations"}),
    t({"  "}), f(get_class_name, {}), t({"("}), f(get_class_name, {}), t({"&& other) noexcept = default;"}),
    t({"  "}), f(get_class_name, {}), t({"& operator=("}), f(get_class_name, {}), t({"&& other) noexcept = default;"}),
    t({""}),
    t({"  // Public interface"}),
    t({"  void "}), i(9, "DoSomething"), t({"();"}),
    t({"  "}),
    t({"  // Accessors"}),
    t({"  const std::string& "}), i(10, "name"), t({"() const { return "}), f(function(args) return args[1][1] .. "_" end, {10}), t({"; }"}),
    t({"  void set_"}), f(function(args) return args[1][1] end, {10}), t({"(std::string_view "}), f(function(args) return args[1][1] end, {10}), t({") { "}), f(function(args) return args[1][1] .. "_" end, {10}), t({" = "}), f(function(args) return args[1][1] end, {10}), t({"; }"}),
    t({""}),
    t({" private:"}),
    t({"  std::string "}), f(function(args) return args[1][1] .. "_" end, {10}), t({";"}),
    t({"  "}), i(11, "// Additional private members"},
    t({"};"}),
    i(0)
  }),

  -- Google-style function with comprehensive documentation
  s("func", {
    t({"// "}), i(1, "Brief description of what the function does"),
    t({"//"}),
    t({"// "}), i(2, "Detailed description of the function's behavior, algorithm,"},
    t({"// "}), i(3, "or any important implementation details."},
    t({"//"}),
    t({"// Args:"}),
    t({"//   "}), i(4, "param"), t({": "}), i(5, "Description of the parameter, including"},
    t({"//          "}), i(6, "constraints, expected format, or valid ranges."},
    t({"//"}),
    t({"// Returns:"}),
    t({"//   "}), i(7, "Description of the return value and any"},
    t({"//   "}), i(8, "special conditions or error states."},
    t({"//"}),
    t({"// Complexity: "}), i(9, "O(n) time, O(1) space"},
    t({"// Thread safety: "}), i(10, "This function is thread-safe"},
    t({"template <typename T>"}),
    t({"constexpr auto "}), i(11, "FunctionName"), t({"("}), i(12, "const T& param"), t({") -> "}), i(13, "decltype(auto)"), t({" {"}),
    t({"  // Input validation"}),
    t({"  if constexpr (std::is_pointer_v<T>) {"}),
    t({"    CHECK("}), f(function(args) return args[1][1]:gsub("const ", ""):gsub("&", "") end, {12}), t({" != nullptr) << \"Parameter cannot be null\";"}),
    t({"  }"}),
    t({"  "}),
    t({"  "}), i(14, "// Function implementation"},
    t({"  "}), i(15, "return std::forward<T>(param);"},
    t({"}"}),
    i(0)
  }),

  -- Modern C++ lambda with Google style
  s("lambda", {
    t({"// "}), i(1, "Lambda description"),
    t({"const auto "}), i(2, "lambda_name"), t({" = ["}), i(3, "capture"), t({"]("}), i(4, "const auto& param"), t({") -> "}), i(5, "auto"), t({" {"}),
    t({"  "}), i(6, "// Lambda implementation"},
    t({"  return "}), i(7, "param;"},
    t({"};"}),
    i(0)
  }),

  -- Template class with concepts (C++20)
  s("template_class", {
    t({"#include <concepts>"}),
    t({"#include <type_traits>"}),
    t({""}),
    t({"// Concept definition"}),
    t({"template <typename T>"}),
    t({"concept "}), i(1, "Addable"), t({" = requires(T a, T b) {"}),
    t({"  { a + b } -> std::convertible_to<T>;"}),
    t({"};"}),
    t({""}),
    t({"// Template class with concept constraints"}),
    t({"template <"}), f(function(args) return args[1][1] end, {1}), t({" T>"}),
    t({"class "}), i(2, "Container"), t({" {"}),
    t({" public:"}),
    t({"  explicit "}), f(function(args) return args[1][1] end, {2}), t({"(std::size_t size) : data_(size) {}"}),
    t({""}),
    t({"  void Add(const T& value) {"}),
    t({"    data_.push_back(value);"}),
    t({"  }"}),
    t({""}),
    t({"  T Sum() const requires "}), f(function(args) return args[1][1] end, {1}), t({"<T> {"}),
    t({"    T result{};"}),
    t({"    for (const auto& item : data_) {"}),
    t({"      result = result + item;"}),
    t({"    }"}),
    t({"    return result;"}),
    t({"  }"}),
    t({""}),
    t({" private:"}),
    t({"  std::vector<T> data_;"}),
    t({"};"}),
    i(0)
  }),

  -- RAII resource manager following Google practices
  s("raii", {
    t({"#include <memory>"}),
    t({"#include <utility>"}),
    t({""}),
    t({"#include \"absl/log/check.h\""}),
    t({"#include \"absl/log/log.h\""}),
    t({""}),
    t({"// RAII wrapper for "}), i(1, "resource management"),
    t({"//"}),
    t({"// This class provides automatic resource management using RAII"}),
    t({"// principles, ensuring proper cleanup even in exception scenarios."}),
    t({"//"}),
    t({"// Example:"}),
    t({"//   {"}),
    t({"//     "}), i(2, "ResourceManager"), t({" manager("}), i(3, "resource_path"), t({");"}),
    t({"//     // Resource is automatically cleaned up when manager goes out of scope"}),
    t({"//   }"}),
    t({"class "}), f(function(args) return args[1][1] end, {2}), t({" {"}),
    t({" public:"}),
    t({"  // Constructor acquires the resource"}),
    t({"  explicit "}), f(function(args) return args[1][1] end, {2}), t({"("}), i(4, "std::string_view resource_path"), t({")"}),
    t({"      : "}), i(5, "resource_path_"), t({"("}), f(function(args) return args[1][1]:gsub("std::string_view ", "") end, {4}), t({") {"}),
    t({"    LOG(INFO) << \"Acquiring resource: \" << "}), f(function(args) return args[1][1] end, {5}), t({";"}),
    t({"    "}), i(6, "resource_ = AcquireResource(resource_path_);"},
    t({"    CHECK("}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({" != nullptr) << \"Failed to acquire resource\";"}),
    t({"  }"}),
    t({""}),
    t({"  // Destructor releases the resource"}),
    t({"  ~"}), f(function(args) return args[1][1] end, {2}), t({"() {"}),
    t({"    if ("}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({" != nullptr) {"}),
    t({"      LOG(INFO) << \"Releasing resource: \" << "}), f(function(args) return args[1][1] end, {5}), t({";"}),
    t({"      "}), i(7, "ReleaseResource(resource_);"},
    t({"    }"}),
    t({"  }"}),
    t({""}),
    t({"  // Non-copyable"}),
    t({"  "}), f(function(args) return args[1][1] end, {2}), t({"(const "}), f(function(args) return args[1][1] end, {2}), t({"&) = delete;"}),
    t({"  "}), f(function(args) return args[1][1] end, {2}), t({"& operator=(const "}), f(function(args) return args[1][1] end, {2}), t({"&) = delete;"}),
    t({""}),
    t({"  // Movable"}),
    t({"  "}), f(function(args) return args[1][1] end, {2}), t({"("}), f(function(args) return args[1][1] end, {2}), t({"&& other) noexcept"}),
    t({"      : "}), f(function(args) return args[1][1] end, {5}), t({"(std::move(other."}), f(function(args) return args[1][1] end, {5}), t({"}),
    t({"        "}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({"(std::exchange(other."}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({", nullptr)) {}"}),
    t({""}),
    t({"  "}), f(function(args) return args[1][1] end, {2}), t({"& operator=("}), f(function(args) return args[1][1] end, {2}), t({"&& other) noexcept {"}),
    t({"    if (this != &other) {"}),
    t({"      std::swap("}), f(function(args) return args[1][1] end, {5}), t({", other."}), f(function(args) return args[1][1] end, {5}), t({");"}),
    t({"      std::swap("}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({", other."}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({");"}),
    t({"    }"}),
    t({"    return *this;"}),
    t({"  }"}),
    t({""}),
    t({"  // Access the managed resource"}),
    t({"  "}), i(8, "ResourceType"), t({"* get() const { return "}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({"; }"}),
    t({"  "}), f(function(args) return args[1][1] end, {8}), t({"& operator*() const { return *"}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({"; }"}),
    t({"  "}), f(function(args) return args[1][1] end, {8}), t({"* operator->() const { return "}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({"; }"}),
    t({""}),
    t({" private:"}),
    t({"  std::string "}), f(function(args) return args[1][1] end, {5}), t({";"}),
    t({"  "}), f(function(args) return args[1][1] end, {8}), t({"* "}), f(function(args) return args[1][1]:gsub("_$", "") end, {6}), t({" = nullptr;"}),
    t({"};"}),
    i(0)
  }),

  -- Smart pointer usage patterns
  s("unique_ptr", {
    t({"// Create unique_ptr with make_unique (preferred)"}),
    t({"auto "}), i(1, "ptr"), t({" = std::make_unique<"}), i(2, "Type"), t({">("}), i(3, "constructor_args"), t({");"}),
    t({""}),
    t({"// Use the pointer"}),
    t({"if ("}), f(function(args) return args[1][1] end, {1}), t({") {"}),
    t({"  "}), f(function(args) return args[1][1] end, {1}), t({"->"}), i(4, "DoSomething"), t({"();"}),
    t({"}"}),
    i(0)
  }),

  s("shared_ptr", {
    t({"// Create shared_ptr with make_shared (preferred)"}),
    t({"auto "}), i(1, "ptr"), t({" = std::make_shared<"}), i(2, "Type"), t({">("}), i(3, "constructor_args"), t({");"}),
    t({""}),
    t({"// Share ownership"}),
    t({"auto "}), i(4, "another_ptr"), t({" = "}), f(function(args) return args[1][1] end, {1}), t({";"}),
    t({""}),
    t({"// Check reference count"}),
    t({"LOG(INFO) << \"Reference count: \" << "}), f(function(args) return args[1][1] end, {1}), t({".use_count();"}),
    i(0)
  }),

  -- Modern for loops and algorithms
  s("range_for", {
    t({"// Range-based for loop with structured binding"}),
    t({"for (const auto& ["}), i(1, "key, value"), t({"] : "}), i(2, "container"), t({") {"}),
    t({"  "}), i(3, "// Process key and value"},
    t({"  LOG(INFO) << \"Key: \" << key << \", Value: \" << value;"}),
    t({"}"}),
    i(0)
  }),

  s("algorithm", {
    t({"#include <algorithm>"}),
    t({"#include <execution>"}),
    t({""}),
    t({"// Modern algorithm usage with execution policy"}),
    t({"std::"}), i(1, "for_each"), t({"(std::execution::")}, i(2, "par_unseq"), t({","}),
    t({"             "}), i(3, "container"), t({".begin(), "}), f(function(args) return args[1][1] end, {3}), t({".end(),"}),
    t({"             [](const auto& item) {"}),
    t({"               "}), i(4, "// Process item in parallel"},
    t({"               "}), i(5, "ProcessItem(item);"},
    t({"             });"}),
    i(0)
  }),

  -- Exception handling with Google practices
  s("exception", {
    t({"#include <stdexcept>"}),
    t({"#include <system_error>"}),
    t({""}),
    t({"#include \"absl/status/status.h\""}),
    t({"#include \"absl/status/statusor.h\""}),
    t({""}),
    t({"// Function returning StatusOr (Google's preferred error handling)"}),
    t({"absl::StatusOr<"}), i(1, "int"), t({"> "}), i(2, "ProcessData"), t({"("}), i(3, "const std::string& input"), t({") {"}),
    t({"  if ("}), f(function(args) return args[1][1]:gsub("const std::string& ", ""):gsub("const ", "") end, {3}), t({".empty()) {"}),
    t({"    return absl::InvalidArgumentError(\"Input cannot be empty\");"}),
    t({"  }"}),
    t({"  "}),
    t({"  try {"}),
    t({"    "}), i(4, "// Processing logic that might throw"},
    t({"    "}), i(5, "int result = std::stoi(input);"},
    t({"    return result;"}),
    t({"  } catch (const std::invalid_argument& e) {"}),
    t({"    return absl::InvalidArgumentError("}),
    t({"        absl::StrCat(\"Invalid input format: \", e.what()));"}),
    t({"  } catch (const std::out_of_range& e) {"}),
    t({"    return absl::OutOfRangeError("}),
    t({"        absl::StrCat(\"Input out of range: \", e.what()));"}),
    t({"  }"}),
    t({"}"}),
    t({""}),
    t({"// Usage example"}),
    t({"auto result = "}), f(function(args) return args[1][1] end, {2}), t({"("}), i(6, "\"123\""), t({");"}),
    t({"if (!result.ok()) {"}),
    t({"  LOG(ERROR) << \"Error: \" << result.status();"}),
    t({"  return -1;"}),
    t({"}"}),
    t({"LOG(INFO) << \"Result: \" << result.value();"}),
    i(0)
  }),

  -- Namespace usage
  s("namespace", {
    t({"namespace "}), i(1, "namespace_name"), t({" {"}),
    t({""}),
    t({"// "}), i(2, "Brief description of what this namespace contains"),
    t({"//"}),
    t({"// "}), i(3, "Detailed explanation of the namespace purpose and contents."},
    t({""}),
    i(4, "// Namespace content"),
    t({""}),
    t({"} // namespace "}), f(function(args) return args[1][1] end, {1}),
    i(0)
  }),

  -- Header guard (prefer #pragma once but provide traditional guard option)
  s("header_guard", {
    t({"#pragma once"}),
    t({""}),
    t({"// Alternative traditional header guard:"}),
    t({"// #ifndef "}), f(get_header_guard, {}),
    t({"// #define "}), f(get_header_guard, {}),
    t({"// ... header content ..."}),
    t({"// #endif // "}), f(get_header_guard, {}),
    t({""}),
    i(1, "// Header content"),
    i(0)
  }),

  -- Standard includes with Google ordering
  s("includes", {
    t({"// C++ standard library headers (alphabetical order)"}),
    t({"#include <algorithm>"}),
    t({"#include <iostream>"}),
    t({"#include <memory>"}),
    t({"#include <string>"}),
    t({"#include <vector>"}),
    t({""}),
    t({"// Abseil headers"}),
    t({"#include \"absl/strings/string_view.h\""}),
    t({"#include \"absl/strings/str_cat.h\""}),
    t({""}),
    t({"// Project headers"}),
    t({"#include \""}), i(1, "project/header.h"), t({"\""}),
    t({""}),
    i(0)
  }),

  -- Enum class with Google style
  s("enum", {
    t({"// "}), i(1, "Enumeration description"),
    t({"enum class "}), i(2, "Status"), t({" : "}), i(3, "int"), t({" {"}),
    t({"  "}), i(4, "kPending"), t({" = 0,"}),
    t({"  "}), i(5, "kProcessing"), t({" = 1,"}),
    t({"  "}), i(6, "kCompleted"), t({" = 2,"}),
    t({"  "}), i(7, "kFailed"), t({" = 3,"}),
    t({"};"}),
    t({""}),
    t({"// String conversion function"}),
    t({"std::string_view ToString("}), f(function(args) return args[1][1] end, {2}), t({" status) {"}),
    t({"  switch (status) {"}),
    t({"    case "}), f(function(args) return args[1][1] end, {2}), t({"::"}), f(function(args) return args[1][1] end, {4}), t({": return \""}), f(function(args) return args[1][1]:gsub("^k", ""):upper() end, {4}), t({"\";"}),
    t({"    case "}), f(function(args) return args[1][1] end, {2}), t({"::"}), f(function(args) return args[1][1] end, {5}), t({": return \""}), f(function(args) return args[1][1]:gsub("^k", ""):upper() end, {5}), t({"\";"}),
    t({"    case "}), f(function(args) return args[1][1] end, {2}), t({"::"}), f(function(args) return args[1][1] end, {6}), t({": return \""}), f(function(args) return args[1][1]:gsub("^k", ""):upper() end, {6}), t({"\";"}),
    t({"    case "}), f(function(args) return args[1][1] end, {2}), t({"::"}), f(function(args) return args[1][1] end, {7}), t({": return \""}), f(function(args) return args[1][1]:gsub("^k", ""):upper() end, {7}), t({"\";"}),
    t({"  }"}),
    t({"  return \"UNKNOWN\";"}),
    t({"}"}),
    i(0)
  }),

  -- Test class with Google Test
  s("test", {
    t({"#include \"gtest/gtest.h\""}),
    t({"#include \"gmock/gmock.h\""}),
    t({""}),
    t({"#include \""}), i(1, "header_under_test.h"), t({"\""}),
    t({""}),
    t({"namespace {"}),
    t({""}),
    t({"class "}), i(2, "ComponentName"), t({"Test : public ::testing::Test {"}),
    t({" protected:"}),
    t({"  void SetUp() override {"}),
    t({"    "}), i(3, "// Test setup code"},
    t({"  }"}),
    t({""}),
    t({"  void TearDown() override {"}),
    t({"    "}), i(4, "// Test cleanup code"},
    t({"  }"}),
    t({""}),
    t({"  "}), i(5, "// Test fixture members"},
    t({"};"}),
    t({""}),
    t({"TEST_F("}), f(function(args) return args[1][1] end, {2}), t({"Test, "}), i(6, "BasicFunctionality"), t({") {"}),
    t({"  // Arrange"}),
    t({"  "}), i(7, "const std::string input = \"test_data\";"},
    t({"  "}), i(8, "const std::string expected = \"expected_result\";"},
    t({"  "}),
    t({"  // Act"}),
    t({"  "}), i(9, "const std::string result = ProcessInput(input);"},
    t({"  "}),
    t({"  // Assert"}),
    t({"  EXPECT_EQ(result, expected);"}),
    t({"}"}),
    t({""}),
    t({"TEST_F("}), f(function(args) return args[1][1] end, {2}), t({"Test, "}), i(10, "ErrorHandling"), t({") {"}),
    t({"  // Test error conditions"}),
    t({"  EXPECT_THROW("}), i(11, "ProcessInput(\"\")"), t({", std::invalid_argument);"}),
    t({"}"}),
    t({""}),
    t({"// Parameterized test"}),
    t({"class "}), f(function(args) return args[1][1] end, {2}), t({"ParameterizedTest"}),
    t({"    : public "}), f(function(args) return args[1][1] end, {2}), t({"Test,"}),
    t({"      public ::testing::WithParamInterface<std::pair<std::string, std::string>> {};"}),
    t({""}),
    t({"TEST_P("}), f(function(args) return args[1][1] end, {2}), t({"ParameterizedTest, "}), i(12, "MultipleInputs"), t({") {"}),
    t({"  const auto [input, expected] = GetParam();"}),
    t({"  const std::string result = ProcessInput(input);"}),
    t({"  EXPECT_EQ(result, expected);"}),
    t({"}"}),
    t({""}),
    t({"INSTANTIATE_TEST_SUITE_P("}),
    t({"    "}), f(function(args) return args[1][1] end, {2}), t({"Tests, "}), f(function(args) return args[1][1] end, {2}), t({"ParameterizedTest,"}),
    t({"    ::testing::Values("}),
    t({"        std::make_pair(\"input1\", \"expected1\"),"}),
    t({"        std::make_pair(\"input2\", \"expected2\")"}),
    t({"    )"}),
    t({");"}),
    t({""}),
    t({"} // namespace"}),
    i(0)
  }),

  -- Simple utility snippets
  s("cout", {
    t({"std::cout << "}), i(1, "\"Hello, World!\""), t({" << std::endl;"}),
    i(0)
  }),

  s("cerr", {
    t({"std::cerr << \"Error: \" << "}), i(1, "error_message"), t({" << std::endl;"}),
    i(0)
  }),

  s("log", {
    t({"LOG("}), i(1, "INFO"), t({") << "}), i(2, "\"Log message\""), t({";"}),
    i(0)
  }),

  s("check", {
    t({"CHECK("}), i(1, "condition"), t({") << "}), i(2, "\"Error message\""), t({";"}),
    i(0)
  }),
}