return {
  lazy = false,
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  dependencies = {
    {
      "OXY2DEV/markview.nvim",
      lazy = false,
      priority = 49,
      config = function()
        require("plugins.config.markview")
      end,
    },
  },
  build = ":TSUpdate",
  config = function()
    require("plugins.config.treesitter")
  end,
}
