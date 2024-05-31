--[[
local colorscheme = "monokai"
local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

vim.o.background = "dark"

if not ok then
    vim.notify("colorscheme " .. colorscheme .. " not found!")
    return
end
]]--

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.blade.php"},
    command = "set ft=html",
})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.controller", "*.model", "*.element", "*.layout", "*.view"},
    command = "set ft=php",
})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = {"*.conf.template"},
    command = "set ft=nginx",
})

