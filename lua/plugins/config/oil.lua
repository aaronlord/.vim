require("oil").setup({
  columns = { "icon" },
  win_options = {
    signcolumn = "yes",
  },
  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, _)
      local folder_skip = {
        ".git",
      }
      return vim.tbl_contains(folder_skip, name)
    end,
  },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
