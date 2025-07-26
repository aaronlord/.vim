return {
    lazy = false,
    "scottmckendry/cyberdream.nvim",
    priority = 1000,
    config = function()
        require("plugins.config.cyberdream")
    end
}
