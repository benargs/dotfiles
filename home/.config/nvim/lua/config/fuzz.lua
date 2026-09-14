local M = {}

local preview = "--preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}'"
local rg_grep = "rg --column --line-number --no-heading --color=always --smart-case --hidden -g '!.git' "
local grep_preview = "--ansi --delimiter : --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' --preview-window '+{2}-/2'"

local function fzf_in_term(cmd, on_select)
  local tmpfile = vim.fn.tempname()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
  })

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end

  -- safety net if you fall out of terminal mode: Esc/q closes the picker
  vim.keymap.set("n", "<Esc>", close, { buffer = buf })
  vim.keymap.set("n", "q", close, { buffer = buf })

  vim.fn.termopen(cmd .. " > " .. tmpfile, {
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

function M.buffers()
  local names = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(b)
    if vim.fn.buflisted(b) == 1 and name ~= "" then table.insert(names, vim.fn.shellescape(name)) end
  end
  if #names == 0 then return end
  fzf_in_term("printf '%s\\n' " .. table.concat(names, " ") .. " | fzf " .. preview, open_file)
end

return M
