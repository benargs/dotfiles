local M = {}

local function fzf_in_term(cmd, on_select, opts)
  opts = opts or {}
  local tmpfile = vim.fn.tempname()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
  })

  local full_cmd = string.format("%s > %s", cmd, tmpfile)

  vim.fn.termopen(full_cmd, {
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      local lines = vim.fn.readfile(tmpfile)
      vim.fn.delete(tmpfile)
      if #lines > 0 then on_select(lines) end
    end,
  })
  vim.cmd("startinsert")
end

-- will find any files
function M.find_files()
  local finder = vim.fn.executable("fd") == 1 and "fd -H --type f" or "find . -type f"
  fzf_in_term(
    finder .. " | fzf --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}'",
    function(lines)
      vim.cmd("edit " .. vim.fn.fnameescape(lines[1]))
    end
  )
end

-- will filter out .gitignored stuff, requires fd-find
function M.find_sans_git()
  local finder = vim.fn.executable("fd") == 1 and "fd -H -E .git --type f" or "find . -type f"
  fzf_in_term(
    finder .. " | fzf --preview 'bat --color=always --style=numbers {} 2>/dev/null || cat {}'",
    function(lines)
      vim.cmd("edit " .. vim.fn.fnameescape(lines[1]))
    end
  )
end

function M.live_grep()
  local rg_cmd = "rg --column --line-number --no-heading --color=always --smart-case ''"
  local fzf_cmd = string.format(
    [[%s | fzf --ansi --delimiter : --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' --preview-window '+{2}-/2']],
    rg_cmd
  )
  fzf_in_term(fzf_cmd, function(lines)
    local file, lnum, col = lines[1]:match("([^:]+):(%d+):(%d+):")
    if file then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
      vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
    end
  end)
end

function M.buffers()
  local bufs = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.fn.buflisted(b) == 1 then
      local name = vim.api.nvim_buf_get_name(b)
      if name ~= "" then table.insert(bufs, name) end
    end
  end
  local tmpfile = vim.fn.tempname()
  vim.fn.writefile(bufs, tmpfile)
  fzf_in_term(
    "cat " .. tmpfile .. " | fzf --preview 'bat --color=always {} 2>/dev/null || cat {}'",
    function(lines)
      vim.cmd("edit " .. vim.fn.fnameescape(lines[1]))
    end
  )
end

function M.grep_string()
  local word = vim.fn.expand("<cword>")
  local rg_cmd = string.format(
    "rg --column --line-number --no-heading --color=always --smart-case %s",
    vim.fn.shellescape(word)
  )
  local fzf_cmd = string.format(
    [[%s | fzf --ansi --delimiter : --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' --preview-window '+{2}-/2']],
    rg_cmd
  )
  fzf_in_term(fzf_cmd, function(lines)
    local file, lnum, col = lines[1]:match("([^:]+):(%d+):(%d+):")
    if file then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
      vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
    end
  end)
end

return M
