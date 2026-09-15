local SERVERS = { gopls = "gopls", terraformls = "terraform-ls", pylsp = "pylsp", ruff = "ruff", lua_ls = "lua-language-server" }

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
})

vim.lsp.config("terraformls", {
  cmd = { "terraform-ls", "serve" },
  filetypes = { "terraform", "terraform-vars" },
  root_markers = { ".terraform", ".git" },
})

vim.lsp.config("pylsp", {
  cmd = { "pylsp" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  settings = { pylsp = { plugins = { pycodestyle = { enabled = false }, pyflakes = { enabled = false }, mccabe = { enabled = false } } } },
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".git" },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git" },
  settings = { Lua = {
    runtime = { version = "LuaJIT" },
    diagnostics = { globals = { "vim" } },
    workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
  } },
})

for server, bin in pairs(SERVERS) do
  if vim.fn.executable(bin) == 1 then vim.lsp.enable(server) end
end

vim.diagnostic.config({ virtual_text = { current_line = true }, severity_sort = true })
vim.o.completeopt = "menu,menuone,noinsert,popup"

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(a)
    local client = vim.lsp.get_client_by_id(a.data.client_id)
    local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = a.buf, desc = desc }) end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format buffer")
    if client and client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, a.buf, { autotrigger = true })
      -- also open the menu from the 2nd character of a word (autotrigger alone only reacts to '.', ':' etc)
      vim.api.nvim_create_autocmd("InsertCharPre", {
        buffer = a.buf,
        callback = function()
          if vim.fn.pumvisible() == 1 or not vim.v.char:match("[%w_]") then return end
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local before = vim.api.nvim_get_current_line():sub(col, col)
          if before:match("[%w_]") then vim.schedule(vim.lsp.completion.get) end
        end,
      })
    end
  end,
})
