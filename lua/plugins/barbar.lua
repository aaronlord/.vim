return {
  lazy = false,
  "romgrk/barbar.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons"
  },
  config = function()
    require("plugins.config.barbar")
  end
}
