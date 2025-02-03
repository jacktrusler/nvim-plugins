local config = require("words750.config")
local M = {}

M.buf = nil
M.floating_buf = nil

local function split_above(buf)
    vim.api.nvim_command("split")
    vim.api.nvim_command("wincmd K")
    vim.api.nvim_set_current_buf(buf)
end

local function get_stars_arr()
    -- Ignore the first 2 lines and count the rest
    local dir = vim.fn.expand("~/.local/share/nvim/words750")

    -- Get the current date components
    local current_date = os.date("*t")
    local year, month = current_date.year, current_date.month
    local firstDayOfMonth = os.date("*t", os.time { year = year, month = month + 1, day = 1 })

    -- Check the last day of the month by getting day 0 of the next month
    local lastDayOfMonth = os.date("*t", os.time { year = year, month = month + 1, day = 0 })
    local files = vim.fn.readdir(dir)
    lastDayOfMonth.day = 31
    local starArr = {}
    local offset = firstDayOfMonth.wday - 1
    for _ = 1, offset do
        table.insert(starArr, "⬜ ")
    end
    for _ = 1, lastDayOfMonth.day do
        table.insert(starArr, "🟧 ")
    end
    for _, file in ipairs(files) do
        local filepath = vim.fn.expand("~/.local/share/nvim/words750/2025-02-02.txt")
        local lines = vim.fn.readfile(filepath)
        local text = table.concat(lines, " ")
        local word_count = #vim.fn.split(text, "\\W\\+")
        local _, _, _, m, d = string.find(file, "(%d+)-(%d+)-(%d+)")
        local monthNum = tonumber(m)
        local dayNum = tonumber(d)
        if (lastDayOfMonth.month == monthNum) and word_count >= config.options.words then
            table.insert(starArr, dayNum + offset, "⭐ ")
        end
    end
    return starArr, offset
end

local function update_floating_window()
    if not M.floating_buf then
        return
    end
    -- Ignore the first 2 lines and count the rest
    local lines = vim.api.nvim_buf_get_lines(0, 2, -1, false)
    local text = table.concat(lines, " ")
    local current_date = os.date("*t")
    local word_count = #vim.fn.split(text, "\\W\\+")

    -- Check if user has passed words threshold
    local arr, offset = get_stars_arr()
    arr[current_date.day + offset] = (word_count >= config.options.words) and "⭐ " or "🟧 "

    vim.api.nvim_buf_set_lines(M.floating_buf, 0, -1, false, {
        "S  M  T  W  Th F Sat",
        table.concat(arr, ""),
        "Word Count: " .. word_count,
    })
end

local function create_floating_window()
    local buf = vim.api.nvim_create_buf(false, true) -- Create a scratch buffer

    local opts = {
        relative = "editor",
        width = 21,
        height = 8,
        row = vim.o.lines - 7,    -- Bottom corner (adjust as needed)
        col = vim.o.columns - 10, -- Right corner
        style = "minimal",
        border = "rounded",
        noautocmd = true,
        focusable = false,
    }

    M.floating_buf = buf

    local win = vim.api.nvim_open_win(buf, false, opts)
    vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat")

    return buf
end

local function set_local_opts(opts)
    for k, v in pairs(opts.buffer or {}) do
        vim.api.nvim_set_option_value(k, v, { buf = M.buf })
    end
    for k, v in pairs(opts.window or {}) do
        vim.api.nvim_set_option_value(k, v, { win = 0 })
    end
end

local function reopen(filepath, opts)
    if opts.split then
        vim.api.nvim_command("split")
        vim.api.nvim_command("wincmd K")
    end
    vim.api.nvim_command("edit " .. filepath)
    M.buf = vim.api.nvim_get_current_buf()

    set_local_opts(opts)
    create_floating_window()
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = M.buf,
        callback = update_floating_window
    })
    update_floating_window()
end

local function create(filename, opts)
    local lines = { os.date("%A %B %d, %Y"), "", "" }

    local buf = vim.api.nvim_create_buf(true, false)
    if not buf or buf == 0 then
        print("Error: Failed to create buffer")
        return
    end
    M.buf = buf

    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(M.buf, filename)

    if opts.split then
        split_above(M.buf)
    else
        vim.api.nvim_set_current_buf(M.buf)
    end

    set_local_opts(opts)
    create_floating_window()
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = M.buf,
        callback = update_floating_window
    })
    update_floating_window()

    vim.api.nvim_win_set_cursor(0, { 3, 0 })
end

function M.open()
    local dir = vim.fn.expand("~/.local/share/nvim/words750")
    local today = os.date("%Y-%m-%d")

    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end

    local filepath = dir .. "/" .. today .. ".txt"
    if vim.fn.filereadable(filepath) == 1 then
        reopen(filepath, config.options)
    else
        create(filepath, config.options)
    end
end

return M
