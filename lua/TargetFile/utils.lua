local U = {}

---@class Config
---@field window_size number: how large the window is (only application to non-float options)
---@field window_location number: Where the window appears (1: north; 2: east; 3: south; 4: west; 5: float)
---@field supported_languages table: file extensions and the corresponding compile/execute commands

U.defaults = {
  window_size = 60,
  window_location = 2,
  supported_language = {
    ['.cpp'] = {
      name = 'C++',
      ext = '.cpp',
      compile_cmd = 'g++ -g -Wshadow -Wall -Wextra --std=c++17 %fp -o %fben',
      execute_cmd = '%fben',
      debug_cmd = nil,
      debut_window_cmd = nil,
      -- debug_cmd = 'gdb -tui %fben',
      -- debut_window_cmd = 'tabe | set nowrap | startinsert | term ',
    },
    ['.c'] = {
      name = 'C',
      ext = '.c',
      compile_cmd = 'gcc -g -Wshadow -Wall -Wextra -std=c99 %fp -o %fben',
      execute_cmd = '%fben',
      debug_cmd = nil,
      debut_window_cmd = nil,
      -- debug_cmd = 'gdb -tui %fben',
      -- debut_window_cmd = 'tabe | set nowrap | startinsert | term ',
    },
    ['.rs'] = {
      name = 'Rust',
      ext = '.rs',
      compile_cmd = 'rustc %fp',
      execute_cmd = '%fen',
      debug_cmd = nil,
      debut_window_cmd = nil,
      -- debug_cmd = 'gdb -tui %fben',
      -- debut_window_cmd = 'tabe | set nowrap | startinsert | term ',
    },
    ['.java'] = {
      name = 'Java',
      ext = '.java',
      compile_cmd = 'javac -d %fdb %fp',
      execute_cmd = 'java -cp %fdb %fp',
      debug_cmd = nil,
      debut_window_cmd = nil,
    },
    ['.js'] = {
      name = 'Javascript',
      ext = '.js',
      compile_cmd = nil,
      execute_cmd = 'node %fp',
      debug_cmd = nil,
      debut_window_cmd = nil,
    },
  },
  leader = [[<leader>\]],
}

function U.file_ext(flnm)
  return flnm:match("(%.%w+)$") or ""
end

function U.file_name(flnm)
  return flnm:sub(string.find(flnm, "/[^/]*$") + 1, #flnm - #file_ext(flnm))
end

return U
