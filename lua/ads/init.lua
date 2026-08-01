local M = {}

local function fit_window(img, win)
    if not vim.api.nvim_win_is_valid(win) then return true end
    local g = img.rendered_geometry
    if not g or not g.width or not g.height then return false end
    vim.api.nvim_win_set_config(win, {
        relative = "editor",
        width = g.width,
        height = g.height,
        row = 1,
        col = vim.o.columns - g.width,
    })
    return true
end

local function fit_window_until_rendered(img, win, attempts)
    if fit_window(img, win) then return end
    if attempts <= 0 then
        pcall(vim.api.nvim_win_close, win, true)
        return
    end
    vim.defer_fn(function() fit_window_until_rendered(img, win, attempts - 1) end, 50)
end

local function show_ad(opts)
    local images = require("ads.ads")
    local img_url = images[math.random(#images)]
    local width = opts.width or 50

    require("image").from_url(img_url, { width = width }, function(img)
        if not img then return end

        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, false, {
            relative = "editor", width = width, height = 1, border = "none",
            col = vim.o.columns - width, row = 1, style = "minimal",
        })
        vim.api.nvim_set_option_value("winhl", "NormalFloat:Normal", { win = win })
        vim.api.nvim_create_autocmd("WinEnter", {
            buffer = buf, once = true,
            callback = function() pcall(vim.api.nvim_win_close, win, true) end,
        })

        img.ignore_global_max_size = true
        img.window = win
        img.buffer = buf
        img:render()

        fit_window_until_rendered(img, win, 40)
    end)
end

M.setup = function(opts)
    opts = opts or {}
    show_ad(opts)

    local interval = opts.interval or (5 * 60 * 1000)
    local timer = vim.uv.new_timer()
    timer:start(interval, interval, vim.schedule_wrap(function() show_ad(opts) end))
end

return M
