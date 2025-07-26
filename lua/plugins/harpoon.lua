return {
    lazy = false,
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
        'nvim-lua/plenary.nvim'
    },
    config = function()
        require("plugins.config.harpoon")
    end
}
