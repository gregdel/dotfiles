local formatting = require("null-ls").builtins.formatting
local diagnostics = require("null-ls").builtins.diagnostics
local actions = require("null-ls").builtins.code_actions

require("null-ls").setup({
    sources = {
        -- shell
        diagnostics.shellcheck,
        actions.shellcheck,
        -- go
        formatting.goimports,
        formatting.gofmt,
        diagnostics.staticcheck,
    },
    on_attach = function(client)
        if client.resolved_capabilities.document_formatting then
            vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
        end
    end,
})
