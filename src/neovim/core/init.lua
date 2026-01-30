-- Core configuration modules

-- Load utils for error handling
local utils = require("utils")

-- Load all core modules with error protection
local core_modules = {
  "core.options",
  "core.indentation",
  "core.performance",
  "core.backup",
  "core.search",
  "core.folding",
}

utils.batch_require(core_modules)
