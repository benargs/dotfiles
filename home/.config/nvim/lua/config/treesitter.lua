local PARSERS = { "lua", "c", "markdown", "query", "vim", "vimdoc" }
local f = io.open(vim.fn.stdpath("config") .. "/treesitter.json")
if f then
  for name in pairs(vim.json.decode(f:read("a"))) do table.insert(PARSERS, name) end
  f:close()
end

---@param parser string
local function can_highlight(parser)
    local ok = pcall(vim.treesitter.language.inspect, parser)
    if not ok then return false end

    return vim.treesitter.query.get(parser, "highlights") ~= nil
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = PARSERS,
    callback = function(args)
        if can_highlight(args.match) then
            vim.treesitter.start(args.buf)
        end
    end
})
