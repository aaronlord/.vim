return {
  lazy = false,
  "stevearc/oil.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  config = function()
    require("plugins.config.oil")
  end,
}
