local U = require('TargetFile.utils')
local fterm = require('FTerm')

---@class TargetFile
---@field file_path string
---@field config Config

local locations = { 'North', 'East', 'South', 'West', 'Float' }
local location_cmd = { 'K', 'L', 'J', 'H', '' }
local location_split_cmd = { 'v', '', 'v', '', '' }
local resize_cmd = { '', 'vertical', '', 'vertical', '' }

local TargetFile = {}

---TargetFile:new creates a new terminal instance
function TargetFile:new()
  return setmetatable({
    file_path = vim.fn.expand('%:p'),
    config = U.defaults,
  }, { __index = self })
end

---TargetFile:setup overrides the terminal windows configuration ie. dimensions
---@param cfg Config
---@return TargetFile|nil
function TargetFile:setup(cfg)
  if not cfg then
    return vim.notify('TargetFile: setup() is optional. Please remove it!', vim.log.levels.WARN)
  end

  self.config = vim.tbl_deep_extend('force', self.config, cfg)

  return self
end

---TargetFile:sets the path of the target file
---@param file_path string
---@return TargetFile
function TargetFile:path_set(file_path)
  if file_path == '' or file_path == nil then
    file_path = vim.fn.expand('%:p')
  end
  self.file_path = file_path

  return self
end

---TargetFile:prints the path of the current target file
---@return TargetFile
function TargetFile:print_path()
  print(self.file_path)

  return self
end

---TargetFile:resets the path to the current buffer path
---@return TargetFile
function TargetFile:reset_path()
  self:path_set("")

  return self
end

---TargetFile:sets the path to a custom file path
---@return TargetFile
function TargetFile:custom_path()
  self:file_path_reset(vim.fn.input("Absolute target file path > "))

  return self
end

---TargetFile:expands the placeholder strings provided to the respective values
---@param unexpanded_cmd string
---@return string
function TargetFile:expand_to_cmd(unexpanded_cmd)
  local expanded_cmd = string.gsub(unexpanded_cmd, "%%fp", self.file_path)
  expanded_cmd = string.gsub(expanded_cmd, "%%fen",
    self.file_path:sub(0, #(self.file_path) - #file_ext(self.file_path)))
  expanded_cmd = string.gsub(expanded_cmd, "%%fben",
    self.file_path:sub(0, #(self.file_path) - #file_ext(self.file_path) - #file_name(self.file_path)) ..
    '.build/' .. file_name(self.file_path))
  expanded_cmd = string.gsub(expanded_cmd, "%%fdb",
    self.file_path:sub(0, #(self.file_path) - #file_ext(self.file_path) - #file_name(self.file_path)) ..
    '.build/')
  expanded_cmd = string.gsub(expanded_cmd, "%%fn", file_name(self.file_path))

  return expanded_cmd
end

---TargetFile:provides the vim command to open/split windows
---@return table|string
function TargetFile:window_open_cmd()
  if self.config.window_location <= 4 then
    local open_cmd = 'new | wincmd ' ..
        location_cmd[self.config.window_location] ..
        ' | ' ..
        resize_cmd[self.config.window_location] ..
        ' resize ' ..
        self.config.window_size ..
        ' | set nowrap | redraw | '
    local split_cmd = location_split_cmd[self.config.window_location] .. 'new | set nowrap | redraw | '
    return { open_cmd = open_cmd, split_cmd = split_cmd }
  else
    return 'FTermOpen \n'
  end
end

---TargetFile:Generates command to preview the window
---@return string
function TargetFile:window_preview_cmd()
  local window_cmds = self:window_open_cmd()
  if self.config.window_location <= 4 then
    return (window_cmds.open_cmd .. window_cmds.split_cmd .. 'sleep 500m | bd! | bd!')
  else
    return (window_cmds .. 'redraw \n sleep 500m \n FTermClose')
  end
end

---TargetFile:shows a brief preview of window
---@return TargetFile
function TargetFile:window_preview()
  vim.cmd(self:window_preview_cmd())
  return self
end

---Resets to default window size and location
---@return TargetFile
function TargetFile:window_reset()
  self.config.window_size = 60
  self.config.window_location = 2
  return self
end

---TargetFile:Displays windows size
---@return TargetFile
function TargetFile:print_window_size()
  print(self.config.window_size)
  return self
end

---TargetFile:Resets default window size
---@return TargetFile
function TargetFile:window_size_reset()
  self.config.window_size = 20
  if (self.config.window_location % 2 == 0) then
    self.config.window_size = 60
  end
  return self
end

---TargetFile:Sets a custom window size from uesr
---@return TargetFile
function TargetFile:window_size_custom()
  self.config.window_size = tonumber(vim.fn.input("Window size > "))
  return self
end

---TargetFile:displays windows location
---@return TargetFile
function TargetFile:print_window_location()
  print(locations[self.config.window_location])
  return self
end

---TargetFile:resets default window location
---@return TargetFile
function TargetFile:window_location_reset()
  local old_location = self.config.window_location
  self.config.window_location = 2
  if old_location % 2 ~= self.config.window_location % 2 then
    self:window_size_reset()
  end
  return self
end

---TargetFile:sets a custom window location from user
---@return TargetFile
function TargetFile:window_location_custom()
  window_location_reset(vim.fn.input("\n1: North\n2: East\n3: South\n4: West\n5: Float\nWindow location > "))
  vim.cmd(window_preview_cmd())
  return self
end

---TargetFile:executes the target file
---@return TargetFile
function TargetFile:execute()
  local filetype = self.config.supported_languages[U.file_ext(self.file_path)]
  if filetype == nil then
    print 'No assigned executable for current file type'
  elseif filetype.execute_cmd ~= nil then
    if self.config.window_location <= 4 then
      vim.cmd(self:window_open_cmd().open_cmd .. 'term ' .. self:expand_to_cmd(filetype.execute_cmd))
    else
      fterm.run(self:expand_to_cmd(filetype.execute_cmd))
      vim.cmd('stopinsert')
    end
  end
  return self
end

---TargetFile:compiles the target file
---@return TargetFile
function TargetFile:compile()
  local filetype = self.config.supported_languages[U.file_ext(self.file_path)]
  if filetype == nil then
    print 'No assigned compiler for current file type'
  elseif filetype.compile_cmd ~= nil then
    if self.config.window_location <= 4 then
      vim.cmd(self:window_open_cmd().open_cmd .. 'term ' .. self:expand_to_cmd(filetype.compile_cmd))
    else
      fterm.run(self:expand_to_cmd(filetype.compile_cmd))
      vim.cmd('stopinsert')
    end
  end
  return self
end

---TargetFile:compiles and executes the current target file
---@return TargetFile
function TargetFile:compile_execute()
  local window_cmds = self:window_open_cmd()
  local filetype = self.config.supported_languages[U.file_ext(self.file_path)]
  if filetype == nil then
    print('No assigned compiler / executable for current file type')
  elseif filetype.compile_cmd ~= nil then
    if self.config.window_location <= 4 then
      vim.cmd(window_cmds.open_cmd .. 'term ' .. self:expand_to_cmd(filetype.compile_cmd))
      local exit_code = vim.fn.jobwait({ vim.b.terminal_job_id }, -1)[1]
      if (exit_code == 0) then
        vim.cmd(window_cmds.split_cmd .. 'term ' .. self:expand_to_cmd(filetype.execute_cmd))
      end
    else
      fterm.run(self:expand_to_cmd(filetype.compile_cmd))
      fterm.run(self:expand_to_cmd(filetype.execute_cmd))
      vim.cmd('stopinsert')
    end
  elseif filetype.execute_cmd then
    if self.config.window_location <= 4 then
      vim.cmd(self:window_open_cmd().open_cmd .. 'term ' .. self:expand_to_cmd(filetype.execute_cmd))
    else
      fterm.run(self:expand_to_cmd(filetype.execute_cmd))
      vim.cmd('stopinsert')
    end
  end
  return self
end

---TargetFile:runs the debug command on the current file
---@return TargetFile
function TargetFile:debug()
  local filetype = self.config.supported_languages[self:file_ext(self.file_path)]
  if filetype == nil then
    print 'No assigned debugger for current file type'
  elseif filetype.debug_cmd ~= nil then
    vim.cmd(filetype.debut_window_cmd .. self:expand_to_cmd(filetype.debug_cmd))
  end
  return self
end

-- function TargetFile:window_size_reset(window_size)
--   window_size = tonumber(window_size)
--   target_file_window_size = 20
--   if (target_file_window_location % 2 == 0) then
--     target_file_window_size = 60
--   end
--   target_file_window_size = window_size or target_file_window_size
-- end

-- function window_location_reset(window_location)
--   window_location = tonumber(window_location)
--   local old_location = target_file_window_location
--   target_file_window_location = window_location or target_file_window_location
--   if old_location % 2 ~= target_file_window_location % 2 then
--     window_size_reset()
--   end
-- end

-- -- Absolute file path
-- local target_file_path = vim.fn.expand('%:p')
-- local target_file_window_size = 60
-- local target_file_window_location = 2 -- 1: north; 2: east; 3: south; 4: west; 5: float
-- local locations = { 'North', 'East', 'South', 'West', 'Float' }
-- local location_cmd = { 'K', 'L', 'J', 'H', '' }
-- local location_split_cmd = { 'v', '', 'v', '', '' }
-- local resize_cmd = { '', 'vertical', '', 'vertical', '' }
--
-- local fterm = require('FTerm')
--
-- local targetfile_leader = [[<leader>\]]

-- Markings:
-- %fp: full file path
-- %fen: full file path without file extension
-- %fben: full file path without file extension with build directory
-- %fdb: full file path without file name or extension with build directory
-- %fn: file name (without extension)

-- -- Keymappings
-- vim.keymap.set('n', targetfile_leader .. 'ps', vim.cmd.TargetFilePath, { desc = 'target file [P]ath [S]how' })
-- vim.keymap.set('n', targetfile_leader .. 'pr', vim.cmd.TargetFilePathReset, { desc = 'target file [P]ath [R]eset' })
-- vim.keymap.set('n', targetfile_leader .. "pc", vim.cmd.TargetFilePathCustom, { desc = 'target file [P]ath [C]ustom' })
-- vim.keymap.set('n', targetfile_leader .. "e", vim.cmd.TargetFileExecute, { desc = '[E]xecute target file' })
-- vim.keymap.set('n', targetfile_leader .. "c", vim.cmd.TargetFileCompile, { desc = '[C]ompile target file' })
-- vim.keymap.set('n', targetfile_leader .. "<space>", vim.cmd.TargetFileCompileExecute,
--   { desc = 'compiles & executes target file' })
-- vim.keymap.set('n', targetfile_leader .. "d", vim.cmd.TargetFileDebug, { desc = '[D]ebugs target file' })
-- vim.keymap.set('n', targetfile_leader .. "ws", vim.cmd.TargetFileWindow, { desc = 'target file [W]indow preview [S]how' })
-- vim.keymap.set('n', targetfile_leader .. "wr", vim.cmd.TargetFileWindowReset, { desc = 'target file [W]indow [R]eset' })
-- vim.keymap.set('n', targetfile_leader .. "ss", vim.cmd.TargetFileWindowSize,
--   { desc = 'target file window [S]ize [S]how' })
-- vim.keymap.set('n', targetfile_leader .. "sr", vim.cmd.TargetFileWindowSizeReset,
--   { desc = 'target file window [S]ize [R]eset' })
-- vim.keymap.set('n', targetfile_leader .. "sc", vim.cmd.TargetFileWindowSizeCustom,
--   { desc = 'target file window [S]ize [C]ustom' })
-- vim.keymap.set('n', targetfile_leader .. "ls", vim.cmd.TargetFileWindowLocation,
--   { desc = 'target file window [L]ocation [S]how' })
-- vim.keymap.set('n', targetfile_leader .. "lr", vim.cmd.TargetFileWindowLocationReset,
--   { desc = 'target file window [L]ocation [R]eset' })
-- vim.keymap.set('n', targetfile_leader .. "lc", vim.cmd.TargetFileWindowLocationCustom,
--   { desc = 'target file window [L]ocation [C]ustom' })

-- vim.keymap.set('i', '<C-e>', '<C-o>A', { desc = 'Puts cursor at the end of the line without exiting insert mode' })
-- vim.keymap.set('n', '<leader>e', function() vim.cmd [[NERDTreeToggle]] end, { desc = 'Open file explorer (NERDTree)' })

-- print(expand_to_cmd(compile_cmd['.cpp']))

-- -- User commands
-- vim.api.nvim_create_user_command("TargetFilePath", function()
--   print(target_file_path)
-- end, {})
--
-- vim.api.nvim_create_user_command("TargetFilePathReset", function()
--   file_path_reset()
--   print(target_file_path)
-- end, {})
--
-- vim.api.nvim_create_user_command("TargetFilePathCustom", function()
--   file_path_reset(vim.fn.input("Absolute target file path > "))
-- end, {})
--
-- vim.api.nvim_create_user_command("TargetFileExecute", function()
--   local filetype = supported_languages[file_ext(target_file_path)]
--   if filetype == nil then
--     print 'No assigned executable for current file type'
--     return
--   elseif filetype.execute_cmd ~= nil then
--     if target_file_window_location <= 4 then
--       vim.cmd(window_open_cmd().open_cmd .. 'term ' .. expand_to_cmd(filetype.execute_cmd))
--     else
--       fterm.run(expand_to_cmd(filetype.execute_cmd))
--       vim.cmd('stopinsert')
--     end
--   end
-- end, {})
--
-- vim.api.nvim_create_user_command("TargetFileCompile", function()
--   local filetype = supported_languages[file_ext(target_file_path)]
--   if filetype == nil then
--     print 'No assigned compiler for current file type'
--     return
--   elseif filetype.compile_cmd ~= nil then
--     if target_file_window_location <= 4 then
--       vim.cmd(window_open_cmd().open_cmd .. 'term ' .. expand_to_cmd(filetype.compile_cmd))
--     else
--       fterm.run(expand_to_cmd(filetype.compile_cmd))
--       vim.cmd('stopinsert')
--     end
--   end
-- end, {})
--
-- vim.api.nvim_create_user_command("TargetFileCompileExecute", function()
--   local window_cmds = window_open_cmd()
--   local filetype = supported_languages[file_ext(target_file_path)]
--   if filetype == nil then
--     print('No assigned compiler / executable for current file type')
--     return
--   elseif filetype.compile_cmd ~= nil then
--     if target_file_window_location <= 4 then
--       vim.cmd(window_cmds.open_cmd .. 'term ' .. expand_to_cmd(filetype.compile_cmd))
--       local exit_code = vim.fn.jobwait({ vim.b.terminal_job_id }, -1)[1]
--       if (exit_code == 0) then
--         vim.cmd(window_cmds.split_cmd .. 'term ' .. expand_to_cmd(filetype.execute_cmd))
--       end
--     else
--       fterm.run(expand_to_cmd(filetype.compile_cmd))
--       fterm.run(expand_to_cmd(filetype.execute_cmd))
--       vim.cmd('stopinsert')
--     end
--   elseif filetype.execute_cmd then
--     if target_file_window_location <= 4 then
--       vim.cmd(window_open_cmd().open_cmd .. 'term ' .. expand_to_cmd(filetype.execute_cmd))
--     else
--       fterm.run(expand_to_cmd(filetype.execute_cmd))
--       vim.cmd('stopinsert')
--     end
--   end
-- end, {})
--
-- vim.api.nvim_create_user_command("TargetFileDebug", function()
--   local filetype = supported_languages[file_ext(target_file_path)]
--   if filetype == nil then
--     print 'No assigned debugger for current file type'
--   elseif filetype.debug_cmd ~= nil then
--     vim.cmd(filetype.debut_window_cmd .. expand_to_cmd(filetype.debug_cmd))
--   end
-- end, {})
--
--
-- -- Window
-- -- Shows a brief preview of window
-- vim.api.nvim_create_user_command("TargetFileWindow", function()
--   vim.cmd(window_preview_cmd())
-- end, {})
--
-- -- Resets to default window size and location
-- vim.api.nvim_create_user_command("TargetFileWindowReset", function()
--   window_reset()
--   vim.cmd(window_preview_cmd())
-- end, {})
--
-- -- Displays windows size
-- vim.api.nvim_create_user_command("TargetFileWindowSize", function()
--   print(target_file_window_size)
-- end, {})
--
-- -- Resets default window size
-- vim.api.nvim_create_user_command("TargetFileWindowSizeReset", function()
--   window_size_reset()
--   vim.cmd(window_preview_cmd())
-- end, {})
--
-- -- Sets a custom window size from uesr
-- vim.api.nvim_create_user_command("TargetFileWindowSizeCustom", function()
--   window_size_reset(vim.fn.input("Window size > "))
--   vim.cmd(window_preview_cmd())
-- end, {})
--
-- -- Displays windows location
-- vim.api.nvim_create_user_command("TargetFileWindowLocation", function()
--   print(locations[target_file_window_location])
-- end, {})
--
-- -- Resets default window location
-- vim.api.nvim_create_user_command("TargetFileWindowLocationReset", function()
--   window_location_reset()
--   vim.cmd(window_preview_cmd())
-- end, {})
--
-- -- Sets a custom window location from user
-- vim.api.nvim_create_user_command("TargetFileWindowLocationCustom", function()
--   window_location_reset(vim.fn.input("\n1: North\n2: East\n3: South\n4: West\n5: Float\nWindow location > "))
--   vim.cmd(window_preview_cmd())
-- end, {})
--
-- -- Window
-- -- Generates command to open the specified window
-- function window_open_cmd()
--   if target_file_window_location <= 4 then
--     local open_cmd = 'new | wincmd ' ..
--         location_cmd[target_file_window_location] ..
--         ' | ' ..
--         resize_cmd[target_file_window_location] ..
--         ' resize ' ..
--         target_file_window_size ..
--         ' | set nowrap | redraw | '
--     local split_cmd = location_split_cmd[target_file_window_location] .. 'new | set nowrap | redraw | '
--     return { open_cmd = open_cmd, split_cmd = split_cmd }
--   else
--     return 'FTermOpen \n'
--   end
-- end
--
-- -- Generates command to preview the window
-- function window_preview_cmd()
--   local window_cmds = window_open_cmd()
--   if target_file_window_location <= 4 then
--     return (window_cmds.open_cmd .. window_cmds.split_cmd .. 'sleep 500m | bd! | bd!')
--   else
--     return (window_cmds .. 'redraw \n sleep 500m \n FTermClose')
--   end
-- end
--
-- function window_reset()
--   target_file_window_size = 60
--   target_file_window_location = 2
-- end
--
-- function window_size_reset(window_size)
--   window_size = tonumber(window_size)
--   target_file_window_size = 20
--   if (target_file_window_location % 2 == 0) then
--     target_file_window_size = 60
--   end
--   target_file_window_size = window_size or target_file_window_size
-- end
--
-- function window_location_reset(window_location)
--   window_location = tonumber(window_location)
--   local old_location = target_file_window_location
--   target_file_window_location = window_location or target_file_window_location
--   if old_location % 2 ~= target_file_window_location % 2 then
--     window_size_reset()
--   end
-- end
--
-- -- Target file related
-- function file_path_reset(file_path)
--   if file_path == '' or file_path == nil then
--     file_path = vim.fn.expand('%:p')
--   end
--   target_file_path = file_path
--   print(target_file_path)
-- end
--
-- function file_ext(flnm)
--   return flnm:match("(%.%w+)$") or ""
-- end
--
-- function file_name(flnm)
--   return flnm:sub(string.find(flnm, "/[^/]*$") + 1, #flnm - #file_ext(flnm))
-- end
--
-- function expand_to_cmd(unexpanded_cmd)
--   local expanded_cmd = string.gsub(unexpanded_cmd, "%%fp", target_file_path)
--   expanded_cmd = string.gsub(expanded_cmd, "%%fen",
--     target_file_path:sub(0, #target_file_path - #file_ext(target_file_path)))
--   expanded_cmd = string.gsub(expanded_cmd, "%%fben",
--     target_file_path:sub(0, #target_file_path - #file_ext(target_file_path) - #file_name(target_file_path)) ..
--     '.build/' .. file_name(target_file_path))
--   expanded_cmd = string.gsub(expanded_cmd, "%%fdb",
--     target_file_path:sub(0, #target_file_path - #file_ext(target_file_path) - #file_name(target_file_path)) ..
--     '.build/')
--   expanded_cmd = string.gsub(expanded_cmd, "%%fn", file_name(target_file_path))
--   return expanded_cmd
-- end

return TargetFile
