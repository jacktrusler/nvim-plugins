local M = {}

---@class Options750
local defaults = {
    -- uncomment any of the options below, or add other vim.bo options you want to apply
    buffer = {
        textwidth = 0,       -- auto-wrapping at a fixed width (inserts \n newlines)
        formatoptions = "q", -- allow auto formatting with gq (inserts \n newlines)
    },
    window = {
        list = false, -- Disable whitespace characters
        relativenumber = false, -- Disable relative numbers
        cursorcolumn = false, -- Disable cursor column
        signcolumn = "no", -- signcolumn
        number = false, -- number column
        wrap = true, -- Enable soft wrapping
        linebreak = true, -- Break lines at word boundaries
        showbreak = "↪ ", -- Indicator for wrapped lines
    },
    split = true, -- If true, will create a buffer as a split, false creates a new buffer window
    words = 500 -- Set the number of words required to get a star ⭐
}

---@type Options750
M.options = nil

function M.setup(options)
    -- "force" overrides defaults with options
    M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return setmetatable(M, {
    --index is a metatable method that gets called when value doesn't exist on table
    __index = function(_, k)
        if k == "options" then
            M.setup()
        end
        return rawget(M, k)
    end,
})
