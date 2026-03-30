require("mason").setup({
    ui = {
        border = "rounded",
        width = 0.8,
        height = 0.8,
        backdrop = 100,
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
});

require("mason-lspconfig").setup({
    -- ts_ls conflicts with vtsls — vtsls is preferred
    -- vue_ls is started manually after vtsls attaches (split server ordering)
    automatic_enable = {
        exclude = { "ts_ls", "vue_ls" },
    },
})
