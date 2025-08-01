-- UI configuration modules

-- Load utils for error handling
local utils = require("config.utils")

-- Load all UI modules with error protection
utils.safe_require("config.ui.appearance")
-- Theme is loaded after plugins in init.lua