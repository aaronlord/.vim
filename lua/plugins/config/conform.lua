-- This will provide type hinting with LuaLS
---@module "conform"
---@type conform.setupOpts

require("conform").setup({
  -- Define your formatters
  formatters_by_ft = {
    php = { "pint" },
    vue = { "prettier" },
  },
  -- Set default options
  default_format_opts = {
    lsp_format = "fallback",
  },
  -- Set up format-on-save
  format_on_save = { timeout_ms = 1000 },
  -- Customize formatters
  formatters = {
    shfmt = {
      prepend_args = { "-i", "2" },
    },
  },
})
