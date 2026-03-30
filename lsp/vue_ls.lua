-- vue_ls handles only <template> and <style> blocks.
-- TypeScript in <script> is delegated to vtsls via @vue/typescript-plugin (hybridMode).
return {
    init_options = {
        vue = {
            hybridMode = true,
        },
    },
}
