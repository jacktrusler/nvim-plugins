local config = require("500-words.config")
local buffer = require("500-words.buffer")

local M = {}

M.setup = config.setup
M.open = buffer.open

return M
