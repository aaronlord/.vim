return {
  lazy = false,
  "tpope/vim-fugitive",
  dependencies = {
    "tpope/vim-rhubarb", -- GitHub
  },
  config = function()
    require("plugins.config.fugitive")
  end
}
