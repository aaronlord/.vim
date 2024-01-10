return {
    extra = function (module_path)
        local last_dot_index = module_path:find("%.[^%.]*$")

        local path = module_path:sub(1, last_dot_index - 1) .. ".extra" .. module_path:sub(last_dot_index)

        local success, module = pcall(require, path)

        if success then
            return module
        end

        return nil
    end
}
