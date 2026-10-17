-- TODO: this thing needs a bit of a cleanup, it's a bit ugly to look at.. it got claude'd when i dropped mason

local SERVERS = {
  gopls = "gopls",
  terraformls = "terraform-ls",
  pylsp = "pylsp",
  ruff = "ruff",
  lua_ls =
  "lua-language-server"
}

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
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
    }
  },
})

for server, bin in pairs(SERVERS) do
  if vim.fn.executable(bin) == 1 then vim.lsp.enable(server) end
end

vim.diagnostic.config({ virtual_text = { current_line = true }, severity_sort = true })
vim.o.completeopt = "menu,menuone,noinsert,popup"

local FORMAT_ON_SAVE = { go = true, python = true, terraform = true, ["terraform-vars"] = true, lua = true }
-- python has both pylsp and ruff attached; let ruff own formatting
local NO_FORMAT = { pylsp = true }
local function format(buf, async)
  vim.lsp.buf.format({ bufnr = buf, async = async, timeout_ms = 2000, filter = function(c) return not NO_FORMAT[c.name] end })
end

-- client id -> set of completion trigger chars, taken off the server so autotrigger doesn't fire on them
local TRIGGERS = {}

local function in_comment(buf, row, col)
  for _, cap in ipairs(vim.treesitter.get_captures_at_pos(buf, row, col)) do
    if cap.capture:match("^comment") then return true end
  end
  return false
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(a)
    local client = vim.lsp.get_client_by_id(a.data.client_id)
    local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = a.buf, desc = desc }) end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    -- this is pretty ugly and messy
    if client and client.name == "ruff" then
      map("<leader>rf", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.fixAll" }, diagnostics = {} },
          apply = true,
        })
      end, "Ruff: fix all")
    end
    map("<leader>lf", function() format(a.buf, true) end, "Format buffer")
    if FORMAT_ON_SAVE[vim.bo[a.buf].filetype] and client and client:supports_method("textDocument/formatting") and not NO_FORMAT[client.name] then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("lsp_format_" .. a.buf, { clear = true }),
        buffer = a.buf,
        callback = function() format(a.buf, false) end,
      })
    end
    if client and client:supports_method("textDocument/completion") then
      -- the built-in autotrigger can't skip comments, so steal the server's trigger chars and fire them below.
      -- autotrigger stays on just to re-query while the menu is open (gopls marks results incomplete)
      if not TRIGGERS[client.id] then
        local provider = (client.server_capabilities or {}).completionProvider or {}
        TRIGGERS[client.id] = {}
        for _, c in ipairs(provider.triggerCharacters or {}) do TRIGGERS[client.id][c] = true end
        provider.triggerCharacters = nil
      end
      vim.lsp.completion.enable(true, client.id, a.buf, { autotrigger = true })
      -- open the menu on trigger chars, or from the 2nd character of a word, unless we're in a comment
      vim.api.nvim_create_autocmd("InsertCharPre", {
        buffer = a.buf,
        callback = function()
          if vim.fn.pumvisible() == 1 then return end
          local char = vim.v.char
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          if col == 0 or in_comment(a.buf, row - 1, col - 1) then return end
          local before = vim.api.nvim_get_current_line():sub(col, col)
          if TRIGGERS[client.id][char] then
            vim.schedule(function() vim.lsp.completion.get({ ctx = { triggerKind = 2, triggerCharacter = char } }) end)
          elseif char:match("[%w_]") and before:match("[%w_]") then
            vim.schedule(vim.lsp.completion.get)
          end
        end,
      })
    end
  end,
})
