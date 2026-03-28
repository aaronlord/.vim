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
