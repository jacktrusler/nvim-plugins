-- local Job = require('plenary.job')
local M = {}

M.config = {
}

M.Todo = function() print("other text") end
vim.api.nvim_create_user_command("Todo", M.Todo, {})

local win_id = nil
local buffer_id = nil
print(buffer_id)

-- Function to close the floating window
local function close_window()
  if win_id and vim.api.nvim_win_is_valid(win_id) then
    vim.api.nvim_win_close(win_id, true)
    win_id = nil
  end
end

-- Use Plenary to run a command line command
-- local function docker(args, options)
--   local job_options = vim.tbl_deep_extend('force', options or {}, {
--     command = 'docker',
--     args = args
--   })
--   return Job:new(job_options)
-- end

local function stop_container(params)
  print(params)
end

-- Function to open the floating window
M.Open_window = function()
  if buffer_id then
    vim.api.nvim_set_current_buf(buffer_id)
    return
  end

  -- Create a new buffer if it doesn't exist
  if not buffer_id or not vim.api.nvim_buf_is_valid(buffer_id) then
    buffer_id = vim.api.nvim_create_buf(false, true)            -- Create a new buffer, no file, scratch buffer
    vim.api.nvim_buf_set_option(buffer_id, 'bufhidden', 'wipe') -- buffer will be deleted when hidden
  end

  local docker_output = vim.fn.system("docker ps")
  local lines = vim.split(docker_output, "\n")

  win_id = vim.api.nvim_open_win(buffer_id, true, {
    win = 0,
    split = "above",
  })
  for line_num, line in ipairs(lines) do
    local container_id = line:match("^%S+") -- Match the first word (non-space characters)
    if container_id then
      -- Apply a highlight to the container ID (column 0 to the length of the ID)
      vim.api.nvim_buf_add_highlight(buffer_id, -1, "Search", line_num - 1, 0, #container_id)
    end
  end

  vim.api.nvim_buf_set_lines(buffer_id, 0, -1, false, lines)

  -- Bind the <esc> and q key to close the window
  vim.keymap.set("n", "<esc>", close_window, { buffer = buffer_id })
  vim.keymap.set("n", "q", close_window, { buffer = buffer_id })
  vim.keymap.set("n", "d", stop_container, { buffer = buffer_id })


  -- set options on the window
  vim.bo[buffer_id].modifiable = true
  vim.wo[win_id].foldenable = false
  vim.wo[win_id].wrap = false
  vim.wo[win_id].cursorline = true
end

-- Set a keymap to toggle the floating window (for example, <leader>f)
vim.api.nvim_set_keymap('n', '<leader>f', ':lua toggle_floating_window()<CR>', { buf = buffer_id })

vim.api.nvim_create_user_command("Open", M.Open_window, {})


return M
