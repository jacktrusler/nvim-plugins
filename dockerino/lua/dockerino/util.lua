local M = {}
function M.error(msg)
    M.log(msg, "ErrorMsg")
end

function M.get_hl(name)
    local hl, ok = vim.api.nvim_get_hl(0, { name = name })
    if not ok then
        return
    end
    for _, key in pairs({ "foreground", "background", "special" }) do
        if hl[key] then
            hl[key] = string.format("#%06x", hl[key])
        end
    end
    return hl
end

function M.log(msg, hl)
    vim.api.nvim_echo({ { "Dockerino:", hl }, { msg } }, true, {})
end

return M
