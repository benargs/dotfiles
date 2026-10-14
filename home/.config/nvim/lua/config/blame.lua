local M = {}

local ns = vim.api.nvim_create_namespace("blame")
local enabled = false
local cache = {} 
local timer

local function clear(buf)
  if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end
end

local function relative(ts)
  local d = os.time() - ts
  for _, u in ipairs({ { 31536000, "year" }, { 2592000, "month" }, { 604800, "week" }, { 86400, "day" }, { 3600, "hour" }, { 60, "minute" } }) do
    if d >= u[1] then
      local n = math.floor(d / u[1])
      return n .. " " .. u[2] .. (n > 1 and "s" or "") .. " ago"
    end
  end
  return "just now"
end

-- porcelain: a header per line ("<hash> <orig> <final> [count]"), commit attributes only the
-- first time a hash appears, then a tab-prefixed content line
local function parse(out)
  local commits, lines, cur = {}, {}, nil
  for line in out:gmatch("[^\n]*") do
    if line:sub(1, 1) == "\t" then
      -- content line, nothing to record
    elseif line:match("^%x+ %d+ %d+") then
      local hash, final = line:match("^(%x+) %d+ (%d+)")
      commits[hash] = commits[hash] or {}
      cur = commits[hash]
      lines[tonumber(final)] = cur
      cur.hash = hash
    elseif cur then
      local k, v = line:match("^([%w%-]+) ?(.*)$")
      if k then cur[k] = v end
    end
  end
  local out_lines = {}
  for lnum, c in pairs(lines) do
    local text = c.hash:match("^0+$") and "not committed yet"
      or string.format("%s, %s · %s", c.author, relative(tonumber(c["author-time"])), c.summary)
    out_lines[lnum] = text
  end
  return out_lines
end

local function render(buf)
  clear(buf)
  local c = cache[buf]
  if not c or c.tick ~= vim.api.nvim_buf_get_changedtick(buf) then return end
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  if c.lines[lnum] then
    vim.api.nvim_buf_set_extmark(buf, ns, lnum - 1, 0, { virt_text = { { "  " .. c.lines[lnum], "Blame" } }, virt_text_pos = "eol" })
  end
end

local function refresh(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" or vim.bo[buf].buftype ~= "" then return end
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  if cache[buf] and cache[buf].tick == tick then return render(buf) end
  local contents = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  vim.system(
    { "git", "-C", vim.fs.dirname(file), "blame", "--porcelain", "--contents", "-", "--", file },
    { stdin = contents, text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 or not enabled or not vim.api.nvim_buf_is_valid(buf) then return end
      cache[buf] = { tick = tick, lines = parse(res.stdout) }
      render(buf)
    end)
  )
end

local function on_change(a)
  if timer then timer:stop() end
  timer = vim.defer_fn(function() refresh(a.buf) end, 300)
end

local function enable()
  enabled = true
  vim.api.nvim_set_hl(0, "Blame", { fg = vim.api.nvim_get_hl(0, { name = "NonText" }).fg, italic = true })
  local group = vim.api.nvim_create_augroup("blame", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, { group = group, callback = function(a) refresh(a.buf) end })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { group = group, callback = on_change })
  vim.api.nvim_create_autocmd("CursorMoved", { group = group, callback = function(a) render(a.buf) end })
  refresh(vim.api.nvim_get_current_buf())
end

local function disable()
  enabled = false
  vim.api.nvim_del_augroup_by_name("blame")
  for b in pairs(cache) do clear(b) end
  cache = {}
end

function M.toggle()
  if enabled then disable() else enable() end
end

return M
