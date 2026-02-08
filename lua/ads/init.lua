local M = {}

local function show_ad()
    local images = require("ads.ads")
    local img_url = images[math.random(#images)]
    local width, height = 50, 20
    local buf = vim.api.nvim_create_buf(false, true)

    local win = vim.api.nvim_open_win(buf, false, {
        relative = "editor", width = width, height = height, border = "none",
        col = vim.o.columns - width, row = 1, style = "minimal",
    })
    vim.api.nvim_set_option_value("winhl", "NormalFloat:Normal", { win = win })

    vim.api.nvim_create_autocmd("WinEnter", {
        buffer = buf, once = true,
        callback = function() pcall(vim.api.nvim_win_close, win, true) end,
    })

    require("image").from_url(img_url, {
        window = win, buffer = buf, with_virtual_padding = true,
    }, function(img) if img then img:render() end end)
end

M.setup = function(opts)
    opts = opts or {}
    show_ad()

    local interval = opts.interval or (5 * 60 * 1000)
    local timer = vim.uv.new_timer()
    timer:start(interval, interval, vim.schedule_wrap(show_ad))
end

return M
