local M = {
    config = require("easyswitch.config")
}

M._get_plugins = function()
    local plugins = require("lazy").plugins()
    local plugins_table = {}
    for _, plugin in ipairs(plugins) do
        table.insert(plugins_table, plugin['name'])
    end

    return plugins_table
end

M.refresh_buf = function()
    local popup = M.config.popup

    local plugins_table = { "*Disabled Plugins*:" }
    for _, plugin in ipairs(M.get()) do
        table.insert(plugins_table, plugin)
    end

    table.insert(plugins_table, "")

    table.insert(plugins_table, "*Enabled Plugins*:")
    for _, plugin in ipairs(M._get_plugins()) do
        table.insert(plugins_table, plugin)
    end

    -- set content
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, #plugins_table, false, plugins_table)
    local opts = {}

    vim.api.nvim_buf_set_keymap(popup.bufnr, "n", "d", ":lua require('easyswitch').remove()<CR>", opts)
    vim.api.nvim_buf_set_keymap(popup.bufnr, "n", "a", ":lua require('easyswitch').add()<CR>", opts)
    vim.api.nvim_buf_set_keymap(popup.bufnr, "n", "<Esc>", ":lua require('easyswitch').toggle()<CR>", opts)
end

M.get = function()
    local file = M.config.data_file_path

    local file_data = io.open(file, "r")

    if file_data == nil then
        return {}
    end

    return vim.json.decode(file_data:read())
end

M.set = function(disabled_plugins)
    local file = M.config.data_file_path

    local data_file = io.open(file, "w+")

    if data_file == nil then
        error("Could not create or read " .. file)
        return
    end

    data_file:write(
        vim.json.encode(disabled_plugins)
    )

    data_file:close()
end

M.add = function()
    local name = vim.api.nvim_get_current_line()
    local skip = { "", "*Disabled Plugins*:", "*Enabled Plugins*:" }

    local available_plugins = M._get_plugins()
    if not vim.tbl_contains(available_plugins, name) then
        return
    end

    local disabled_plugins = M.get()

    if M.is_disabled(name) then
        return
    end

    table.insert(disabled_plugins, name)

    M.set(disabled_plugins)
    M.refresh_buf()

    vim.notify("Restart to reload plugins...")
end

M.remove = function()
    local name = vim.api.nvim_get_current_line()
    local current = M.get()
    local index = M.is_disabled(name)

    if index then
        table.remove(current, index)
    end

    M.set(current)
    M.refresh_buf()

    vim.notify("Restart to reload plugins...")
end

M.is_disabled = function(name)
    local current = M.get()

    for i, plugin in ipairs(current) do
        if plugin == name then
            return i
        end
    end

    return false
end

M.is_active = function(name)
    return not M.is_disabled(name)
end

M.toggle = function()
    if M.config.popup ~= nil then
        M.config.popup:unmount()
        M.config.popup = nil
        return
    end

    local Popup = require("nui.popup")
    local event = require("nui.utils.autocmd").event

    local popup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = "rounded",
        },
        buf_options = {
            modifiable = true,
            readonly = true,
        },
        position = "50%",
        size = {
            width = "80%",
            height = "60%",
        },
    })

    M.config.popup = popup

    M.refresh_buf()

    -- mount/open the component
    popup:mount()

    -- unmount component when cursor leaves buffer
    popup:on(event.BufLeave, function()
        popup:unmount()
    end)
end

M.new = function(plugins)
    print(vim.inspect(plugins))

    return plugins
end

return M
