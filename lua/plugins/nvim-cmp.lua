return {
  lazy = false,
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    -- snippets
    "saadparwaiz1/cmp_luasnip",
    {
      "L3MON4D3/LuaSnip",
      build = "make install_jsregexp",
    },
    -- completion list icons
    "onsails/lspkind.nvim",
  },
  config = function()
    require("plugins.config.nvim-cmp")
  end,
}
