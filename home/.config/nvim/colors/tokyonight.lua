vim.cmd("hi clear")
vim.g.colors_name = "tokyonight"
vim.o.termguicolors = true

local hi = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

-- palette
local bg0    = "#16161e"
local bg1    = "#1a1b26"
local bg2    = "#1f2335"
local bg     = "#1a1b26"
local bg4    = "#24283b"
local bg5    = "#292e42"
local bg6    = "#414868"
local fg     = "#c0caf5"
local fg_dim = "#a9b1d6"

local blue_pop1 = "#283457"
local blue_pop2 = "#3d59a1"

local string   = "#9ece6a"
local number   = "#ff9e64"
local constant = "#ff9e64"
local ident    = "#c0caf5"
local param    = "#e0af68"
local fun      = "#7aa2f7"
local keyword  = "#bb9af7"
local operator = "#89ddff"
local type_    = "#2ac3de"
local comment  = "#565f89"
local punct    = "#89ddff"
local special1 = "#7dcfff"
local special2 = "#f7768e"
local special3 = "#ff007c"
local regex    = "#b4f9f8"
local depr     = "#737aa2"

local err  = "#f7768e"
local warn = "#e0af68"
local info = "#0db9d7"
local hint = "#1abc9c"
local ok   = "#9ece6a"

local diff_add    = "#20303b"
local diff_del    = "#37222c"
local diff_change = "#252a3f"
local diff_text   = "#394b70"

local vcs_add = "#449dab"
local vcs_del = "#914c54"
local vcs_chg = "#6183bb"

-- editor
hi("Normal",       { fg = fg,     bg = bg })
hi("NormalFloat",  { fg = fg_dim, bg = bg0 })
hi("NormalNC",     { link = "Normal" })
hi("FloatBorder",  { fg = bg6,  bg = bg0 })
hi("FloatTitle",   { fg = "#c0caf5", bg = bg0, bold = true })
hi("FloatFooter",  { fg = bg6,  bg = bg0 })

hi("ColorColumn",  { bg = bg4 })
hi("Conceal",      { fg = "#c0caf5", bold = true })
hi("CurSearch",    { fg = fg, bg = blue_pop2, bold = true })
hi("Cursor",       { fg = bg,  bg = fg })
hi("lCursor",      { link = "Cursor" })
hi("CursorIM",     { link = "Cursor" })
hi("CursorColumn", { link = "CursorLine" })
hi("CursorLine",   { bg = bg5 })
hi("CursorLineNr", { fg = warn, bg = bg4, bold = true })

hi("Directory",    { fg = fun })
hi("EndOfBuffer",  { fg = bg })
hi("ErrorMsg",     { fg = err })
hi("WinSeparator", { fg = bg0 })
hi("VertSplit",    { link = "WinSeparator" })

hi("Folded",       { fg = "#7aa2f7", bg = bg4 })
hi("FoldColumn",   { fg = bg6,       bg = bg4 })
hi("SignColumn",   { fg = "#7aa2f7", bg = bg4 })

hi("IncSearch",    { fg = blue_pop1, bg = warn })
hi("Substitute",   { fg = fg, bg = vcs_del })
hi("Search",       { fg = fg, bg = blue_pop2 })

hi("LineNr",       { fg = bg6, bg = bg4 })
hi("MatchParen",   { fg = warn, bold = true })
hi("ModeMsg",      { fg = warn, bold = true })
hi("MsgArea",      { fg = fg_dim })
hi("MsgSeparator", { fg = bg0, bg = bg0 })
hi("MoreMsg",      { fg = info })
hi("NonText",      { fg = bg6 })
hi("Whitespace",   { fg = bg6 })
hi("SpecialKey",   { fg = "#7aa2f7" })

hi("Pmenu",        { fg = fg,    bg = blue_pop1 })
hi("PmenuSel",     { bg = blue_pop2 })
hi("PmenuKind",    { fg = fg_dim,      bg = blue_pop1 })
hi("PmenuKindSel", { fg = fg_dim,      bg = blue_pop2 })
hi("PmenuExtra",   { fg = "#7aa2f7",   bg = blue_pop1 })
hi("PmenuExtraSel",{ fg = "#7aa2f7",   bg = blue_pop2 })
hi("PmenuSbar",    { bg = blue_pop1 })
hi("PmenuThumb",   { bg = blue_pop2 })
hi("PmenuBorder",  { link = "FloatBorder" })
hi("WildMenu",     { link = "Pmenu" })

hi("Question",     { link = "MoreMsg" })
hi("QuickFixLine", { bg = bg4 })
hi("StatusLine",   { fg = fg_dim, bg = bg0 })
hi("StatusLineNC", { fg = bg6,   bg = bg0 })
hi("TabLine",      { fg = "#7aa2f7", bg = bg0 })
hi("TabLineFill",  { bg = bg })
hi("TabLineSel",   { fg = fg_dim, bg = bg4 })
hi("Title",        { fg = fun, bold = true })
hi("Visual",       { bg = blue_pop1 })
hi("VisualNOS",    { link = "Visual" })
hi("WarningMsg",   { fg = warn })
hi("WinBar",       { fg = fg_dim, bg = "NONE" })
hi("WinBarNC",     { fg = fg_dim, bg = "NONE" })

hi("SpellBad",     { undercurl = true, sp = err })
hi("SpellCap",     { undercurl = true, sp = warn })
hi("SpellLocal",   { undercurl = true, sp = warn })
hi("SpellRare",    { undercurl = true, sp = warn })

hi("debugPC",         { bg = diff_del })
hi("debugBreakpoint", { fg = special1, bg = bg4 })

-- diff
hi("DiffAdd",    { bg = diff_add })
hi("DiffChange", { bg = diff_change })
hi("DiffDelete", { fg = vcs_del, bg = diff_del })
hi("DiffText",   { bg = diff_text })

-- syntax
hi("Comment",    { fg = comment, italic = true })
hi("Constant",   { fg = constant })
hi("String",     { fg = string })
hi("Character",  { link = "String" })
hi("Number",     { fg = number })
hi("Boolean",    { fg = constant, bold = true })
hi("Float",      { link = "Number" })
hi("Identifier", { fg = ident })
hi("Function",   { fg = fun })
hi("Statement",  { fg = keyword, bold = true })
hi("Operator",   { fg = operator })
hi("Keyword",    { fg = keyword, italic = true })
hi("Exception",  { fg = special2 })
hi("PreProc",    { fg = special2 })
hi("Type",       { fg = type_ })
hi("Special",    { fg = special1 })
hi("Delimiter",  { fg = punct })
hi("Underlined", { fg = special1, underline = true })
hi("Bold",       { bold = true })
hi("Italic",     { italic = true })
hi("Ignore",     { link = "NonText" })
hi("Error",      { fg = err })
hi("Todo",       { fg = blue_pop1, bg = info, bold = true })

hi("markdownCode",      { fg = string })
hi("markdownCodeBlock", { fg = string })
hi("markdownEscape",    { fg = "NONE" })

-- treesitter
hi("@variable",              { fg = fg })
hi("@variable.builtin",      { fg = special2, italic = true })
hi("@variable.parameter",    { fg = param })
hi("@variable.member",       { fg = ident })
hi("@string.regexp",         { fg = regex })
hi("@string.escape",         { fg = regex, bold = true })
hi("@string.special.symbol", { fg = ident })
hi("@string.special.url",    { fg = special1, undercurl = true })
hi("@attribute",             { link = "Constant" })
hi("@constructor",           { fg = special1 })
hi("@constructor.lua",       { fg = keyword })
hi("@operator",              { link = "Operator" })
hi("@keyword.operator",      { fg = operator, bold = true })
hi("@keyword.import",        { link = "PreProc" })
hi("@keyword.return",        { fg = special3, italic = true })
hi("@keyword.exception",     { fg = special3, bold = true })
hi("@keyword.luap",          { link = "@string.regexp" })
hi("@punctuation.delimiter", { fg = punct })
hi("@punctuation.bracket",   { fg = punct })
hi("@punctuation.special",   { fg = special1 })
hi("@comment.error",         { fg = fg, bg = err, bold = true })
hi("@comment.warning",       { fg = blue_pop1, bg = warn, bold = true })
hi("@comment.note",          { fg = blue_pop1, bg = hint, bold = true })
hi("@markup.strong",         { bold = true })
hi("@markup.italic",         { italic = true })
hi("@markup.strikethrough",  { strikethrough = true })
hi("@markup.underline",      { underline = true })
hi("@markup.heading",        { link = "Function" })
hi("@markup.quote",          { link = "@variable.parameter" })
hi("@markup.math",           { link = "Constant" })
hi("@markup.environment",    { link = "Keyword" })
hi("@markup.link.url",       { link = "@string.special.url" })
hi("@markup.raw",            { link = "String" })
hi("@diff.plus",             { fg = vcs_add })
hi("@diff.minus",            { fg = vcs_del })
hi("@diff.delta",            { fg = vcs_chg })
hi("@tag.attribute",         { fg = ident })
hi("@tag.delimiter",         { fg = punct })

-- diagnostics
hi("DiagnosticError",              { fg = err })
hi("DiagnosticWarn",               { fg = warn })
hi("DiagnosticInfo",               { fg = info })
hi("DiagnosticHint",               { fg = hint })
hi("DiagnosticOk",                 { fg = ok })
hi("DiagnosticFloatingError",      { fg = err })
hi("DiagnosticFloatingWarn",       { fg = warn })
hi("DiagnosticFloatingInfo",       { fg = info })
hi("DiagnosticFloatingHint",       { fg = hint })
hi("DiagnosticFloatingOk",         { fg = ok })
hi("DiagnosticSignError",          { fg = err,  bg = bg4 })
hi("DiagnosticSignWarn",           { fg = warn, bg = bg4 })
hi("DiagnosticSignInfo",           { fg = info, bg = bg4 })
hi("DiagnosticSignHint",           { fg = hint, bg = bg4 })
hi("DiagnosticVirtualTextError",   { link = "DiagnosticError" })
hi("DiagnosticVirtualTextWarn",    { link = "DiagnosticWarn" })
hi("DiagnosticVirtualTextInfo",    { link = "DiagnosticInfo" })
hi("DiagnosticVirtualTextHint",    { link = "DiagnosticHint" })
hi("DiagnosticUnderlineError",     { undercurl = true, sp = err })
hi("DiagnosticUnderlineWarn",      { undercurl = true, sp = warn })
hi("DiagnosticUnderlineInfo",      { undercurl = true, sp = info })
hi("DiagnosticUnderlineHint",      { undercurl = true, sp = hint })

-- lsp
hi("LspReferenceText",            { bg = diff_text })
hi("LspReferenceRead",            { link = "LspReferenceText" })
hi("LspReferenceWrite",           { bg = diff_text, underline = true })
hi("LspSignatureActiveParameter", { fg = warn })
hi("LspCodeLens",                 { fg = comment })

-- vcs
hi("diffAdded",   { fg = vcs_add })
hi("diffRemoved", { fg = vcs_del })
hi("diffDeleted", { fg = vcs_del })
hi("diffChanged", { fg = vcs_chg })
hi("diffOldFile", { fg = vcs_del })
hi("diffNewFile", { fg = vcs_add })

-- terminal colors
vim.g.terminal_color_0  = bg0
vim.g.terminal_color_1  = "#f7768e"  -- red
vim.g.terminal_color_2  = string     -- green
vim.g.terminal_color_3  = operator   -- yellow
vim.g.terminal_color_4  = fun        -- blue
vim.g.terminal_color_5  = keyword    -- magenta
vim.g.terminal_color_6  = hint       -- cyan
vim.g.terminal_color_7  = fg_dim     -- white
vim.g.terminal_color_8  = comment    -- bright black
vim.g.terminal_color_9  = "#ff899d"  -- bright red
vim.g.terminal_color_10 = "#9ece6a"  -- bright green
vim.g.terminal_color_11 = "#e0af68"  -- bright yellow
vim.g.terminal_color_12 = "#7dcfff"  -- bright blue
vim.g.terminal_color_13 = "#bb9af7"  -- bright magenta
vim.g.terminal_color_14 = "#2ac3de"  -- bright cyan
vim.g.terminal_color_15 = fg
