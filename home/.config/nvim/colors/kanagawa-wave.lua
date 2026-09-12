vim.cmd("hi clear")
vim.g.colors_name = "kanagawa-wave"
vim.o.termguicolors = true

local hi = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

-- palette
local bg0    = "#16161D"
local bg1    = "#181820"
local bg2    = "#1a1a22"
local bg     = "#1F1F28"
local bg4    = "#2A2A37"
local bg5    = "#363646"
local bg6    = "#54546D"
local fg     = "#DCD7BA"
local fg_dim = "#C8C093"

local blue_pop1 = "#223249"
local blue_pop2 = "#2D4F67"

local string   = "#98BB6C"
local number   = "#D27E99"
local constant = "#FFA066"
local ident    = "#E6C384"
local param    = "#b8b4d0"
local fun      = "#7E9CD8"
local keyword  = "#957FB8"
local operator = "#C0A36E"
local type_    = "#7AA89F"
local comment  = "#727169"
local punct    = "#9CABCA"
local special1 = "#7FB4CA"
local special2 = "#E46876"
local special3 = "#FF5D62"
local regex    = "#C0A36E"
local depr     = "#717C7C"

local err  = "#E82424"
local warn = "#FF9E3B"
local info = "#658594"
local hint = "#6A9589"
local ok   = "#98BB6C"

local diff_add    = "#2B3328"
local diff_del    = "#43242B"
local diff_change = "#252535"
local diff_text   = "#49443C"

local vcs_add = "#76946A"
local vcs_del = "#C34043"
local vcs_chg = "#DCA561"

-- editor
hi("Normal",       { fg = fg,     bg = bg })
hi("NormalFloat",  { fg = fg_dim, bg = bg0 })
hi("NormalNC",     { link = "Normal" })
hi("FloatBorder",  { fg = bg6,  bg = bg0 })
hi("FloatTitle",   { fg = "#938AA9", bg = bg0, bold = true })
hi("FloatFooter",  { fg = bg6,  bg = bg0 })

hi("ColorColumn",  { bg = bg4 })
hi("Conceal",      { fg = "#938AA9", bold = true })
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

hi("Folded",       { fg = "#938AA9", bg = bg4 })
hi("FoldColumn",   { fg = bg6,       bg = bg4 })
hi("SignColumn",   { fg = "#938AA9", bg = bg4 })

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
hi("SpecialKey",   { fg = "#938AA9" })

hi("Pmenu",        { fg = fg,    bg = blue_pop1 })
hi("PmenuSel",     { bg = blue_pop2 })
hi("PmenuKind",    { fg = fg_dim,      bg = blue_pop1 })
hi("PmenuKindSel", { fg = fg_dim,      bg = blue_pop2 })
hi("PmenuExtra",   { fg = "#938AA9",   bg = blue_pop1 })
hi("PmenuExtraSel",{ fg = "#938AA9",   bg = blue_pop2 })
hi("PmenuSbar",    { bg = blue_pop1 })
hi("PmenuThumb",   { bg = blue_pop2 })
hi("PmenuBorder",  { link = "FloatBorder" })
hi("WildMenu",     { link = "Pmenu" })

hi("Question",     { link = "MoreMsg" })
hi("QuickFixLine", { bg = bg4 })
hi("StatusLine",   { fg = fg_dim, bg = bg0 })
hi("StatusLineNC", { fg = bg6,   bg = bg0 })
hi("TabLine",      { fg = "#938AA9", bg = bg0 })
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
vim.g.terminal_color_1  = "#C34043"  -- red
vim.g.terminal_color_2  = string     -- green
vim.g.terminal_color_3  = operator   -- yellow
vim.g.terminal_color_4  = fun        -- blue
vim.g.terminal_color_5  = keyword    -- magenta
vim.g.terminal_color_6  = hint       -- cyan
vim.g.terminal_color_7  = fg_dim     -- white
vim.g.terminal_color_8  = comment    -- bright black
vim.g.terminal_color_9  = "#E82424"  -- bright red
vim.g.terminal_color_10 = "#98BB6C"  -- bright green
vim.g.terminal_color_11 = "#E6C384"  -- bright yellow
vim.g.terminal_color_12 = "#7FB4CA"  -- bright blue
vim.g.terminal_color_13 = "#938AA9"  -- bright magenta
vim.g.terminal_color_14 = "#7AA89F"  -- bright cyan
vim.g.terminal_color_15 = fg
