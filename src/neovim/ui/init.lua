-- UI configuration modules

-- Load utils for error handling
local utils = require("utils")

-- Load all UI modules with error protection
utils.safe_require("ui.appearance")
utils.safe_require("ui.ligatures")

-- Theme is loaded after plugins in init.lua
