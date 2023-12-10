local path = require "plenary.path"   

require("cmake-tools").setup {
  cmake_build_directory = tostring(path:new('build', '${variant:buildType}')), -- this is used to specify generate directory for cmake
  cmake_regenerate_on_save = true, -- Saves CMakeLists.txt file only if mofified.
  cmake_soft_link_compile_commands = true, -- if softlink compile commands json file
  -- cmake_compile_commands_from_lsp = true,
  cmake_build_options = { "-j32" },
  
  cmake_kits_path = nil,

  cmake_executor = { -- executor to use
    name = "quickfix", -- name of the executor
    opts = {}, -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
    default_opts = { -- a list of default and possible values for executors
      quickfix = {
        show = "always", -- "always", "only_on_error"
        position = "belowright", -- "bottom", "top"
        size = 10,
        encoding = "utf-8", -- if encoding is not "utf-8", it will be converted to "utf-8" using `vim.fn.iconv`
      },
      overseer = {
        new_task_opts = {}, -- options to pass into the `overseer.new_task` command
        on_new_task = function(task) end, -- a function that gets overseer.Task when it is created, before calling `task:start`
      },
      terminal = {}, -- terminal executor uses the values in cmake_terminal
    },
  },

  cmake_terminal = {
    name = "overseer",
  },

  cmake_dap_configuration = {
    name = "cpp",
    type = "codelldb",
    request = "launch",
    stopOnEntry = false,
    runInTerminal = false,
    initCommands = function()
      local cmds = {}

      local scan = require "plenary.scandir"

      local dbh_path = path:new "./tools/debughelpers/lldb/"

      if dbh_path:exists() then
        local files = scan.scan_dir(dbh_path.filename, {})
        for _, v in ipairs(files) do
          table.insert(cmds, "command script import " .. v)
        end
      end

      local ok, res = pcall(function()
        return dofile "dap.lua"
      end)
      if ok then
        for _, v in ipairs(res) do
          table.insert(cmds, v)
        end
      end

      table.insert(cmds, [[settings set target.process.thread.step-avoid-regexp '']])
      table.insert(cmds, [[breakpoint name configure --disable cpp_exception]])
      return cmds
    end,
  },
  cmake_notifications = {
    enabled = true, -- show cmake execution progress in nvim-notify
    spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
    refresh_rate_ms = 100, -- how often to iterate icons
  },
}
