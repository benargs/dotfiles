local M = {}

local ns = vim.api.nvim_create_namespace("tree")
local WIDTH = 32

local state = { buf = nil, win = nil, root = nil, open = {}, hidden = true, items = {} }

local function list(dir)
  local dirs, files = {}, {}
  for name, kind in vim.fs.dir(dir) do
    if name ~= ".git" and (state.hidden or name:sub(1, 1) ~= ".") then
      if kind == "link" then
        local st = vim.uv.fs_stat(dir .. "/" .. name)
        kind = st and st.type or "file"
      end
      table.insert(kind == "directory" and dirs or files, name)
    end
  end
  local by_name = function(a, b) return a:lower() < b:lower() end
  table.sort(dirs, by_name)
  table.sort(files, by_name)
  return dirs, files
end

local function render()
  local lines, items = { vim.fn.fnamemodify(state.root, ":~") }, { { path = state.root, dir = true } }

  local function walk(dir, depth)
    local dirs, files = list(dir)
    local indent = string.rep("  ", depth)
    for _, name in ipairs(dirs) do
      local path = dir .. "/" .. name
      table.insert(lines, indent .. (state.open[path] and "▾ " or "▸ ") .. name .. "/")
      table.insert(items, { path = path, dir = true })
      if state.open[path] then walk(path, depth + 1) end
    end
    for _, name in ipairs(files) do
      table.insert(lines, indent .. "  " .. name)
      table.insert(items, { path = dir .. "/" .. name, dir = false })
    end
  end
  walk(state.root, 0)

  state.items = items
  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false

  vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
  for i, item in ipairs(items) do
    if item.dir then
      vim.api.nvim_buf_set_extmark(state.buf, ns, i - 1, 0, { end_col = #lines[i], hl_group = "Directory" })
    end
  end
end

local function current()
  return state.items[vim.api.nvim_win_get_cursor(state.win)[1]]
end

local function goto_path(path)
  for i, item in ipairs(state.items) do
    if item.path == path then
      vim.api.nvim_win_set_cursor(state.win, { i, 0 })
      return
    end
  end
end

local function edit_target()
  local prev = vim.fn.win_getid(vim.fn.winnr("#"))
  local function usable(w) return w ~= state.win and vim.api.nvim_win_get_config(w).relative == "" end
  if prev ~= 0 and usable(prev) then return prev end
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if usable(w) then return w end
  end
end

-- make an editor window current, splitting off the tree if there isn't one
local function focus_editor()
  local target = edit_target()
  if not target then
    vim.cmd("vertical rightbelow new")
    target = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(state.win, WIDTH)
  end
  vim.api.nvim_set_current_win(target)
end

local function open_file(path)
  focus_editor()
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

-- the tree window only ever shows the tree: <S-h>/<S-l>, :edit, the fuzzy pickers etc. pressed
-- while it's focused get redirected to an editor window instead of replacing it
local group = vim.api.nvim_create_augroup("tree", { clear = true })

local quitting = false
vim.api.nvim_create_autocmd("QuitPre", {
  group = group,
  callback = function()
    if vim.api.nvim_get_current_win() ~= state.win then return end
    quitting = true
    vim.schedule(function() quitting = false end) -- the :q's WinClosed fires before this runs
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(a)
    local quit_from_tree = quitting and tonumber(a.match) == state.win
    vim.schedule(function()
      local wins = vim.api.nvim_tabpage_list_wins(0)
      if #wins == 1 and (wins[1] == state.win or quit_from_tree) then
        local ok, err = pcall(vim.api.nvim_command, "quit")
        if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = group,
  callback = function(a)
    local win = state.win
    if not (win and vim.api.nvim_win_is_valid(win)) then return end
    if a.buf == state.buf or vim.api.nvim_get_current_win() ~= win then return end
    if not vim.api.nvim_buf_is_loaded(state.buf) then -- tree buffer was :bdelete'd, so this is just an editor window now
      state.win = nil
      return
    end
    vim.schedule(function()
      if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(a.buf)) then return end
      vim.api.nvim_win_set_buf(win, state.buf)
      focus_editor()
      vim.api.nvim_set_current_buf(a.buf)
    end)
  end,
})

local function activate()
  local item = current()
  if not item then return end
  if not item.dir then return open_file(item.path) end
  if item.path == state.root then return end
  state.open[item.path] = not state.open[item.path] or nil
  render()
end

local function collapse()
  local item = current()
  if not item or item.path == state.root then return end
  if item.dir and state.open[item.path] then
    state.open[item.path] = nil
    render()
  else
    local parent = vim.fs.dirname(item.path)
    if parent ~= state.root then goto_path(parent) end
  end
end

local function set_root(path)
  state.root = path
  render()
  vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
end

local function enter_dir()
  local item = current()
  if item and item.dir and item.path ~= state.root then set_root(item.path) end
end

local function up_dir()
  local parent = vim.fs.dirname(state.root)
  if parent ~= state.root then
    local from = state.root
    set_root(parent)
    goto_path(from)
  end
end

local function toggle_hidden()
  state.hidden = not state.hidden
  local item = current()
  render()
  if item then goto_path(item.path) end
end

local function refresh()
  local item = current()
  render()
  if item then goto_path(item.path) end
end

-- expand every directory between the root and `path` so it shows up in the tree
local function reveal(path)
  if path == "" or path:sub(1, #state.root + 1) ~= state.root .. "/" then return end
  local dir = vim.fs.dirname(path)
  while dir ~= state.root do
    state.open[dir] = true
    dir = vim.fs.dirname(dir)
  end
  render()
  goto_path(path)
end

local function err(msg) vim.notify(msg, vim.log.levels.ERROR) end

-- netrw-style file operations work in the directory under the cursor, or the cursor file's directory
local function target_dir()
  local item = current()
  if not item then return state.root end
  return item.dir and item.path or vim.fs.dirname(item.path)
end

-- prompt for a name relative to `dir`; nil if cancelled
local function prompt_path(dir, prompt)
  local name = vim.fn.input(prompt .. vim.fn.fnamemodify(dir, ":~") .. "/", "", "file")
  vim.cmd("redraw")
  if name == "" then return end
  return vim.fs.normalize(vim.fs.joinpath(dir, name))
end

local function new_file()
  local path = prompt_path(target_dir(), "New file: ")
  if not path then return end
  if vim.uv.fs_stat(path) then return err(path .. " already exists") end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local fd, e = vim.uv.fs_open(path, "w", 420) -- 0644
  if not fd then return err(e) end
  vim.uv.fs_close(fd)
  render()
  reveal(path)
  open_file(path)
end

local function new_dir()
  local path = prompt_path(target_dir(), "New directory: ")
  if not path then return end
  if vim.uv.fs_stat(path) then return err(path .. " already exists") end
  if vim.fn.mkdir(path, "p") == 0 then return err("couldn't create " .. path) end
  state.open[path] = true
  render()
  reveal(path)
end

local function delete()
  local item = current()
  if not item or item.path == state.root then return end
  local what = vim.fn.fnamemodify(item.path, ":~") .. (item.dir and "/ and everything in it" or "")
  if vim.fn.confirm("Delete " .. what .. "?", "&Yes\n&No", 2) ~= 1 then return end
  if vim.fn.delete(item.path, item.dir and "rf" or "") ~= 0 then return err("couldn't delete " .. item.path) end
  local row = vim.api.nvim_win_get_cursor(state.win)[1]
  render()
  vim.api.nvim_win_set_cursor(state.win, { math.min(row, #state.items), 0 })
end

local function rename()
  local item = current()
  if not item or item.path == state.root then return end
  local to = vim.fn.input("Rename to: ", item.path, "file")
  vim.cmd("redraw")
  if to == "" or to == item.path then return end
  to = vim.fs.normalize(to)
  if vim.uv.fs_stat(to) then return err(to .. " already exists") end
  vim.fn.mkdir(vim.fs.dirname(to), "p")
  local ok, e = vim.uv.fs_rename(item.path, to)
  if not ok then return err(e) end
  -- point any buffer open on the old file at the new one, so :w doesn't recreate the old path
  local buf = vim.fn.bufnr(item.path)
  if not item.dir and buf ~= -1 then
    vim.api.nvim_buf_set_name(buf, to)
    if not vim.bo[buf].modified then vim.api.nvim_buf_call(buf, function() vim.cmd("silent! write!") end) end
  end
  state.open[to], state.open[item.path] = state.open[item.path], nil
  render() -- reveal only re-renders for paths under the root
  reveal(to)
end

local function ensure_buf()
  if state.buf and vim.api.nvim_buf_is_loaded(state.buf) then return end
  -- :bdelete unloads the buffer (dropping its keymaps) without invalidating it
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then vim.api.nvim_buf_delete(state.buf, { force = true }) end
  state.buf = vim.api.nvim_create_buf(false, true)
  local b = state.buf
  vim.bo[b].buftype = "nofile"
  vim.bo[b].swapfile = false
  vim.bo[b].filetype = "tree"
  vim.bo[b].modifiable = false

  local map = function(lhs, fn, desc) vim.keymap.set("n", lhs, fn, { buffer = b, nowait = true, desc = desc }) end
  map("<CR>", activate, "Open file / toggle directory")
  map("l", activate, "Open file / toggle directory")
  map("h", collapse, "Collapse directory / go to parent")
  map("c", enter_dir, "Make directory the root")
  map("-", up_dir, "Go up a directory")
  map("H", toggle_hidden, "Toggle hidden files")
  map("<C-l>", refresh, "Refresh")
  map("%", new_file, "New file")
  map("d", new_dir, "New directory")
  map("D", delete, "Delete")
  map("R", rename, "Rename / move")
  map("q", M.close, "Close tree")
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  state.win = nil
end

function M.open()
  state.root = state.root or vim.uv.cwd()
  local file = vim.api.nvim_buf_get_name(0)
  ensure_buf()

  vim.cmd("topleft " .. WIDTH .. "vsplit")
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  local wo = vim.wo[state.win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.winfixwidth = true
  wo.cursorline = true
  wo.wrap = false
  wo.scrolloff = 0 -- the global scrolloff would pin the cursor to the middle

  render()
  reveal(file)
end

-- closed -> open; open but elsewhere -> focus it; focused -> close
function M.toggle()
  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then return M.open() end
  if vim.api.nvim_get_current_win() == state.win then M.close() else vim.api.nvim_set_current_win(state.win) end
end

return M
