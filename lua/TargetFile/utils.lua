local U = {}

---@class Config
---@field window_size number: how large the window is (only applicable to non-float options)
---@field window_location number: Where the window appears (1: north; 2: east; 3: south; 4: west; 5: float)
---@field supported_languages table: file extensions and the corresponding compile/execute commands
---@field leader string: leader key that triggers TargetFile keybindings

U.defaults = {
  window_size = 60,
  window_location = 2,
  supported_languages = {},
  leader = [[<space>\]],
}

function U.file_ext(flnm)
  return flnm:match("(%.%w+)$") or ""
end

function U.file_name(flnm)
  return flnm:sub(string.find(flnm, "/[^/]*$") + 1, #flnm - #U.file_ext(flnm))
end

return U

