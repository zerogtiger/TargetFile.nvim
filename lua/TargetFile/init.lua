local TargetFile = require('TargetFile.targetfile')

local M = {}

local tf = TargetFile:new()

---(Optional) Configure the default terminal
---@param cfg Config
function M.setup(cfg)
    tf:setup(cfg)
end

function M.print_path()
  tf:print_path()
end

function M.reset_path()
  tf:reset_path()
  tf:print_path()
end

function M.custom_path()
  tf:custom_path()
  tf:print_path()
end

function M.preview_window()
  tf:window_preview()
end

function M.reset_window()
  tf:window_reset()
end

function M.print_window_size()
  tf:print_window_size()
end

function M.reset_window_size()
  tf:window_size_reset()
end

function M.custom_window_size()
  tf:window_size_custom()
end

function M.print_window_location()
  tf:print_window_location()
end

function M.reset_window_location()
  tf:window_location_reset()
end

function M.custom_window_location()
  tf:window_location_custom()
end

function M.execute()
  tf:execute()
end

function M.compile()
  tf:compile()
end

function M.compile_execute()
  tf:compile_execute()
end

function M.debug()
  tf:debug()
end
-- User commands
vim.api.nvim_create_user_command("TFPath", function()
  M.print_path()
end, {})

vim.api.nvim_create_user_command("TFResetPath", function()
  M.reset_path()
end, {})

vim.api.nvim_create_user_command("TFCustomPath", function()
  M.custom_path()
end, {})

vim.api.nvim_create_user_command("TFExecute", function()
  M.execute()
end, {})

vim.api.nvim_create_user_command("TFCompile", function()
  M.compile()
end, {})

vim.api.nvim_create_user_command("TFCompileExecute", function()
  M.compile_execute()
end, {})

vim.api.nvim_create_user_command("TFDebug", function()
  M.debug()
end, {})

-- Window
-- Shows a brief preview of window
vim.api.nvim_create_user_command("TFPreviewWindow", function()
  M.preview_window()
end, {})

-- Resets to default window size and location
vim.api.nvim_create_user_command("TFResetWindow", function()
  M.reset_window()
end, {})

-- Displays windows size
vim.api.nvim_create_user_command("TFWindowSize", function()
  M.print_window_size()
end, {})

-- Resets default window size
vim.api.nvim_create_user_command("TFresetWindowSize", function()
  M.reset_window_size()
end, {})

-- Sets a custom window size from uesr
vim.api.nvim_create_user_command("TFCustomWindowSize", function()
  M.custom_window_size()
end, {})

-- Displays windows location
vim.api.nvim_create_user_command("TFWindowLocation", function()
  M.print_window_location()
end, {})

-- Resets default window location
vim.api.nvim_create_user_command("TFResetWindowLocation", function()
  M.reset_window_location()
end, {})

-- Sets a custom window location from user
vim.api.nvim_create_user_command("TFCustomWindowLocation", function()
  M.custom_window_location()
end, {})

-- Keymappings
vim.keymap.set('n', tf.config.leader .. 'ps', vim.cmd.TargetFilePath, { desc = 'target file [P]ath [S]how' })
vim.keymap.set('n', targetfile_leader .. 'pr', vim.cmd.TargetFilePathReset, { desc = 'target file [P]ath [R]eset' })
vim.keymap.set('n', targetfile_leader .. "pc", vim.cmd.TargetFilePathCustom, { desc = 'target file [P]ath [C]ustom' })
vim.keymap.set('n', targetfile_leader .. "e", vim.cmd.TargetFileExecute, { desc = '[E]xecute target file' })
vim.keymap.set('n', targetfile_leader .. "c", vim.cmd.TargetFileCompile, { desc = '[C]ompile target file' })
vim.keymap.set('n', targetfile_leader .. "<space>", vim.cmd.TargetFileCompileExecute,
  { desc = 'compiles & executes target file' })
vim.keymap.set('n', targetfile_leader .. "d", vim.cmd.TargetFileDebug, { desc = '[D]ebugs target file' })
vim.keymap.set('n', targetfile_leader .. "ws", vim.cmd.TargetFileWindow, { desc = 'target file [W]indow preview [S]how' })
vim.keymap.set('n', targetfile_leader .. "wr", vim.cmd.TargetFileWindowReset, { desc = 'target file [W]indow [R]eset' })
vim.keymap.set('n', targetfile_leader .. "ss", vim.cmd.TargetFileWindowSize,
  { desc = 'target file window [S]ize [S]how' })
vim.keymap.set('n', targetfile_leader .. "sr", vim.cmd.TargetFileWindowSizeReset,
  { desc = 'target file window [S]ize [R]eset' })
vim.keymap.set('n', targetfile_leader .. "sc", vim.cmd.TargetFileWindowSizeCustom,
  { desc = 'target file window [S]ize [C]ustom' })
vim.keymap.set('n', targetfile_leader .. "ls", vim.cmd.TargetFileWindowLocation,
  { desc = 'target file window [L]ocation [S]how' })
vim.keymap.set('n', targetfile_leader .. "lr", vim.cmd.TargetFileWindowLocationReset,
  { desc = 'target file window [L]ocation [R]eset' })
vim.keymap.set('n', targetfile_leader .. "lc", vim.cmd.TargetFileWindowLocationCustom,
  { desc = 'target file window [L]ocation [C]ustom' })

-- ---Run a arbitrary command inside the default terminal
-- ---@param cmd Command
-- function M.run(cmd)
--     if not cmd then
--         return vim.notify('FTerm: Please provide a command to run', vim.log.levels.ERROR)
--     end
--
--     t:run(cmd)
-- end
--
-- ---Returns the job id of the terminal if it exists
-- function M.get_job_id()
--   return t.terminal
-- end
--
-- ---To create a scratch (use and throw) terminal. Like those good ol' C++ build terminal.
-- ---@param cfg Config
-- function M.scratch(cfg)
--     if not cfg then
--         return vim.notify('FTerm: Please provide configuration for scratch terminal', vim.log.levels.ERROR)
--     end
--
--     cfg.auto_close = false
--
--     M:new(cfg):open()
-- end

-- ---Creates a custom terminal
-- ---@param cfg Config
-- ---@return Term
-- function M:new(cfg)
--     return Term:new():setup(cfg)
-- end

-- ---Opens the default terminal
-- function M.open()
--     tf:open()
-- end
--
-- ---Closes the default terminal window but preserves the actual terminal session
-- function M.close()
--     t:close()
-- end
--
-- ---Exits the terminal session
-- function M.exit()
--     t:close(true)
-- end
--
-- ---Toggles the default terminal
-- function M.toggle()
--     t:toggle()
-- end

return M
