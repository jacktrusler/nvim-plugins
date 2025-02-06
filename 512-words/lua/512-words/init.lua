local config = require("512-words.config")
local buffer = require("512-words.buffer")

local M = {}

M.setup = config.setup
M.open = buffer.open

return M
