local M = {}

local preview = "--preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}'"
local rg_grep = "rg --column --line-number --no-heading --color=always --smart-case --hidden -g '!.git' "
local grep_preview =
"--ansi --delimiter : --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' --preview-window '+{2}-/2'"

local function fzf_in_term(cmd, on_select)
  local tmpfile = vim.fn.tempname()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
  })

  local hl = function(name) return vim.api.nvim_get_hl(0, { name = name }) end
  vim.api.nvim_set_hl(0, "FuzzBorder", { fg = hl("FloatBorder").fg, bg = hl("Normal").bg })
  vim.wo[win].winhighlight = "NormalFloat:Normal,FloatBorder:FuzzBorder"

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end

  -- safety net if you fall out of terminal mode: Esc/q closes the picker
  vim.keymap.set("n", "<Esc>", close, { buffer = buf })
  vim.keymap.set("n", "q", close, { buffer = buf })

  vim.fn.jobstart(cmd .. " > " .. tmpfile, {
    term = true,
    on_exit = vim.schedule_wrap(function()
      local ok, lines = pcall(vim.fn.readfile, tmpfile)
      vim.fn.delete(tmpfile)
      close()
      if ok and #lines > 0 then on_select(lines) end
    end),
  })
  vim.cmd("startinsert")
end

local function open_file(lines)
  vim.cmd("edit " .. vim.fn.fnameescape(lines[1]))
end

local function open_match(lines)
  local file, lnum, col = lines[1]:match("([^:]+):(%d+):(%d+):")
  if not file then return end
  vim.cmd("edit " .. vim.fn.fnameescape(file))
  vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
end

local function file_lister(respect_gitignore)
  if vim.fn.executable("rg") == 1 then
    return "rg --files --hidden -g '!.git'" .. (respect_gitignore and "" or " --no-ignore")
  end
  return "find . -path ./.git -prune -o -type f -print"
end

function M.find_files()
  fzf_in_term(file_lister(false) .. " | fzf " .. preview, open_file)
end

function M.find_sans_git()
  fzf_in_term(file_lister(true) .. " | fzf " .. preview, open_file)
end

function M.live_grep()
  fzf_in_term(rg_grep .. "'' | fzf " .. grep_preview, open_match)
end

function M.grep_string()
  local word = vim.fn.shellescape(vim.fn.expand("<cword>"))
  fzf_in_term(rg_grep .. word .. " | fzf " .. grep_preview, open_match)
end

local buf_preview = "--delimiter '\\t' --nth 2 --preview 'bat --color=always --style=numbers {2} 2>/dev/null || cat {2}'"

function M.buffers()
  local origin = vim.api.nvim_get_current_win()
  local selection = vim.fn.tempname()

  local function lines()
    local active = vim.api.nvim_win_is_valid(origin) and vim.api.nvim_win_get_buf(origin) or -1
    local out = {}
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      local name = vim.api.nvim_buf_get_name(b)
      if vim.fn.buflisted(b) == 1 and name ~= "" then
        table.insert(out, (b == active and "*" or " ") .. "\t" .. name)
      end
    end
    return out
  end

  -- fzf calls these back over $NVIM's socket, so ctrl-x never has to close the picker
  _G.FuzzBufList = function() return table.concat(lines(), "\n") end
  _G.FuzzBufDelete = function()
    local doomed = {}
    for _, name in ipairs(vim.fn.readfile(selection)) do
      local b = vim.fn.bufnr(name)
      if b ~= -1 and not vim.bo[b].modified then doomed[b] = true end
    end

    local keep
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      if not doomed[b] and vim.fn.buflisted(b) == 1 then
        keep = b
        break
      end
    end
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if doomed[vim.api.nvim_win_get_buf(w)] then
        keep = keep or vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(w, keep)
      end
    end

    for b in pairs(doomed) do pcall(vim.api.nvim_buf_delete, b, { force = false }) end
    return ""
  end

  local current = lines()
  if #current == 0 then return end

  local escaped = {}
  for _, l in ipairs(current) do table.insert(escaped, vim.fn.shellescape(l)) end

  local server = vim.v.servername
  local bind = "ctrl-x:execute-silent(printf '%s\\n' {+2} > " .. selection
      .. " && nvim --server " .. server .. " --remote-expr 'v:lua.FuzzBufDelete()' >/dev/null)"
      .. "+reload(nvim --server " .. server .. " --remote-expr 'v:lua.FuzzBufList()')"
      .. "+clear-selection"

  local cmd = "printf '%s\\n' " .. table.concat(escaped, " ")
      .. " | fzf --multi " .. buf_preview
      .. " --header 'enter: open  tab: multi-select  ctrl-x: delete'"
      .. " --bind " .. vim.fn.shellescape(bind)

  fzf_in_term(cmd, function(out)
    if #out == 0 then return end
    open_file({ out[1]:match("[^\t]*$") })
  end)
end

return M
