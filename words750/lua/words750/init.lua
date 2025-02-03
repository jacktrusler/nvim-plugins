local config = require("words750.config")
local buffer = require("words750.buffer")

local M = {}

M.setup = config.setup
M.open = buffer.open

return M
