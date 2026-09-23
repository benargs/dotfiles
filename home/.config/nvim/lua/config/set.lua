vim.opt.scrolloff = 999
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus"

-- overwrites for indentation/whitespace stuff
local INDENT = {
  lua = 2,
  terraform = 2,
  ["terraform-vars"] = 2,
  hcl = 2,
  json = 2,
  jsonc = 2,
  yaml = 2,
  toml = 2,
  markdown = 2,
  sh = 2,
  bash = 2,
  zsh = 2,
  python = 4,
  go = 4,
  gomod = 4,
  gowork = 4,
  make = 8,
}
local TABS = { go = true, gomod = true, gowork = true, make = true }

vim.api.nvim_create_autocmd("FileType", {
  callback = function(a)
    local width = INDENT[vim.bo[a.buf].filetype]
    if not width then return end
    local tabs = TABS[vim.bo[a.buf].filetype]
    vim.bo[a.buf].shiftwidth = width
    vim.bo[a.buf].softtabstop = tabs and 0 or width
    vim.bo[a.buf].tabstop = width
    vim.bo[a.buf].expandtab = not tabs
  end,
})
