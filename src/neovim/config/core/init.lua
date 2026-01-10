-- Core configuration modules

-- Load utils for error handling
local utils = require("config.utils")

-- Load all core modules with error protection
local core_modules = {
  "config.core.options",
  "config.core.indentation",
  "config.core.performance",
  "config.core.backup",
  "config.core.search",
  "config.core.folding",
}

utils.batch_require(core_modules)
