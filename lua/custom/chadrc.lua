---@type ChadrcConfig
local M = {}

vim.cmd "function! FCmakeSelectTarget(a,b,c,d) \n CMakeSelectBuildType \n endfunction"
vim.cmd "function! FCmakeSelectRun(a,b,c,d) \n CMakeSelectLaunchTarget \n endfunction"
vim.cmd "function! FCmakeSelectBuild(a,b,c,d) \n CMakeSelectBuildTarget \n endfunction"

-- cmake ideas
--  open list.txt of curent file
--  write protect out of Source
--  build current project by file

-- vim.api.nvim_buf_set_extmark(
--   buf,
--   hl_namespace,
--   line,
--   0,
--   { virt_lines = { content }, virt_lines_above = options.virt_lines_above }
-- )
--

local dec = require "custom.deco.deco"
-- dec.init()

function DecoOff()
  dec.disable()
end

function Deco()
  dec.Clear()
  dec.Test(0)
end

local function ttraversetraversetraversetraversetraversetraversetraversetraversetraversetraversetraver(
  node,
  lines,
  test,
  test
)
end
--
-- local function traverse(node, lines)
--   local ts = vim.treesitter
--
--   if node:type() == "function_declaration" then
--     local start_row, _, end_row, _ = ts.get_node_range(node)
--     table.insert(lines, { start_row, start_row })
--   end
--
--   if node:type() == "function_declarator" then
--     local start_row, _, end_row, _ = ts.get_node_range(node)
--     table.insert(lines, { start_row, end_row })
--   end
--
--   for a = 0, node:named_child_count() - 1, 1 do
--     traverse(node:named_child(a), lines)
--   end
-- end
--
-- function Clear()
--   local ns_id = vim.api.nvim_create_namespace "xDDD"
--   local buffer_id = vim.api.nvim_get_current_buf()
--   vim.api.nvim_buf_clear_namespace(buffer_id, ns_id, 0, -1)
-- end
--
-- function Test()
--   local ts_utils = require "nvim-treesitter.ts_utils"
--   local ts = vim.treesitter
--   local current_node = vim.treesitter.get_parser(0):parse()[1]:root()
--   if not current_node then
--     return ""
--   end
--
--   local lines = {}
--   traverse(current_node, lines)
--   -- vim.notify(vim.inspect(lines))
--
--   local ns_id = vim.api.nvim_create_namespace "xDDD"
--   local buffer_id = vim.api.nvim_get_current_buf()
--
--   vim.api.nvim_set_hl(0, "FuncBg", { ctermbg = 0, bg = "#333333" })
--   vim.api.nvim_buf_clear_namespace(buffer_id, ns_id, 0, -1)
--   for key, value in pairs(lines) do
--     -- vim.highlight.range(buffer_id, ns_id, "FuncBg", { value[1], 0 }, { value[2], 120 })
--     vim.api.nvim_buf_set_extmark(
--       buffer_id,
--       ns_id,
--       value[1],
--       0,
--       { end_row = value[2] + 1, hl_group = "FuncBg", hl_eol = true, end_col = 0 }
--     )
--     --
--     local opts = {
--       virt_lines_above = true,
--       virt_lines = {
--         {
--           {
--             -- "------------------------------------------------------------------------------------------------------------------------",
--             "                                                                                                                        ",
--             "FuncBg",
--           },
--         },
--       },
--     }
--
--     pcall(function()
--       vim.api.nvim_buf_set_extmark(buffer_id, ns_id, value[1], 0, opts)
--     end)
--
--     opts.virt_lines_above = false
--
--     pcall(function()
--       vim.api.nvim_buf_set_extmark(buffer_id, ns_id, value[2], 0, opts)
--     end)
--   end
-- end

function GitDiffRange(from, to)
  if from and to then
    vim.cmd("DiffviewOpen " .. to .. ".." .. from)
  end

  local commits = vim.fn.systemlist "git log --oneline"

  if not from then
    return vim.ui.select(
      commits,
      { prompt = "Select commit 1" },
      vim.schedule_wrap(function(_, idx)
        if not idx then
          return
        end
        GitDiffRange(commits[idx]:match "^%w+", to)
      end)
    )
  end

  if not to then
    return vim.ui.select(
      commits,
      { prompt = "Select commit 2" },
      vim.schedule_wrap(function(_, idx)
        if not idx then
          return
        end
        GitDiffRange(from, commits[idx]:match "^%w+")
      end)
    )
  end
end

function GitDiffBranch(from, to)
  if from and to then
    vim.cmd("DiffviewOpen " .. to .. ".." .. from)
  end

  local commits = vim.fn.systemlist [[git branch -a --format '%(refname:short)']]
  table.insert(commits, 1, "HEAD")

  if not from then
    return vim.ui.select(
      commits,
      { prompt = "Select branch 1" },
      vim.schedule_wrap(function(_, idx)
        if not idx then
          return
        end
        GitDiffBranch(commits[idx], to)
      end)
    )
  end

  if not to then
    return vim.ui.select(
      commits,
      { prompt = "Select branch 2" },
      vim.schedule_wrap(function(_, idx)
        if not idx then
          return
        end
        GitDiffBranch(from, commits[idx])
      end)
    )
  end
end

function GitSignCodeAction()
  local ok, gitsigns_actions = pcall(require("gitsigns").get_actions)
  if not ok or not gitsigns_actions then
    return
  end

  local names = {}
  for name in pairs(gitsigns_actions) do
    table.insert(names, name)
  end

  vim.ui.select(names, { prompt = "Select launch target" }, function(_, idx)
    if not idx then
      return
    end
    gitsigns_actions[names[idx]]()
  end)
end

function CdCurrentFile()
  vim.cmd "cd %:p:h"
end

function RunPerf()
  local cmake = require "cmake-tools"
  cmake.run { wrap_call = { "perf", "record", "--call-graph", "dwarf" } }
end

function RunPerfCacheMisses()
  local cmake = require "cmake-tools"
  -- perf stat -e cycles,instructions,cache-references,cache-misses,bus-cycles
  -- /usr/bin/perf record -e cpu-cycles,cache-misses,branch-misses --call-graph dwarf,4096 -F 250 -o - -- /home/fab/Work/games/endtower/build_RelWithDebInfo/Game/Game PhysicsTest
  cmake.run {
    wrap_call = {
      "perf",
      "record",
      "-e",
      "cpu-cycles,branch-misses,cache-misses",
      "--call-graph",
      "dwarf,4096",
      "-F",
      "250",
    },
  }
end

function AnalyzePerf()
  local cmake = require "cmake-tools"
  local target = cmake.get_launch_target()

  cmake.get_cmake_launch_targets(function(targets_res)
    if targets_res == nil then
      vim.cmd "CMakeGenerate"
      if targets_res == nil then
        return
      end
    end
    local targets, targetPaths = targets_res.data.targets, targets_res.data.abs_paths
    for idx, itarget in ipairs(targets) do
      if itarget == target then
        local target_dir = vim.fn.fnamemodify(targetPaths[idx], ":h")
        local perf = require "perfanno"
        perf.load_perf_callgraph { fargs = { target_dir .. "/perf.data" } }
      end
    end
  end)
end

function RunPerfQuick()
  local cmake = require "cmake-tools"
  cmake.quick_run { fargs = {}, wrap_call = { "perf", "record", "--call-graph", "dwarf" } }
end

function RunValgrind()
  local cmake = require "cmake-tools"
  cmake.run { wrap_call = { "valgrind", "--leak-check=full" } }
end

-- local info = "#a4b595"
-- local error = "#cc6666"
-- local warn = "#DE935F"

M.ui = {
  theme = "catppuccin",
  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal
    overriden_modules = function(modules)
      -- local st_modules = require "nvchad_ui.statusline.default"
      local cmake = require "cmake-tools"
      --local icons = require "user.icons"
      -- this is just default table of statusline modules

      -- table.insert(
      --   modules,
      --   5,
      --   (function()
      --     return " between mode and filename ! xD"
      --   end)()
      -- )
      modules[5] = (function()
        local type = cmake.get_build_type()
        local run = cmake.get_launch_target()
        local tgt = cmake.get_build_target()
        local args = cmake.get_launch_args()
        local preset = cmake.get_configure_preset()
        arg = ""
        if args ~= nil then
          for _, v in ipairs(args) do
            arg = arg .. v
          end
        end

        type = preset and preset or type

        local str = "%#St_gitIcons#"
          .. "   ["
          .. (type and type or "None")
          .. "]"
          .. "   ["
          .. (tgt and tgt or "None")
          .. "]"
          .. "   ["
          .. (run and run or "None")
          .. "]"
          .. "   <"
          .. arg
          .. ">"
        -- .. "   %@FCmakeSelectTarget@% [" .. (type and type or "None") .. "]"
        -- .. "   %@FCmakeSelectBuild@% [" .. (tgt and tgt or "None") .. "]"
        -- .. "   %@FCmakeSelectRun@% [" ..  (run and run or "None") .. "]"
        -- .. "   <" ..  arg .. ">"
        return str --cmake.get_build_type()
      end)()
     --local devcontainer = require "nvim-remote-containers"
     --modules[6] = %#Container#%{devcontainer.currentContainer()}
    end,
  },
}
OIL_TOOGLE = true

M.plugins = "custom/plugins"

M.disabled = {
  n = {
    ["<leader>n"] = "",
    ["<leader>rn"] = "",
    ["<leader>gb"] = "",
    ["<S-Up>"] = "",
    ["<S-Down>"] = "",
  },
  v = {
    ["<S-Up>"] = "",
    ["<S-Down>"] = "",
  },
}

function CpFilePath()
  vim.api.nvim_call_function("setreg", { "+", (vim.fn.expand "%:p") })
  vim.notify("Copied " .. vim.fn.expand "%:p")
end

M.mappings = {
  general = {
    i = {
      ["<A-Left>"] = { "<C-o>", "Navigate Backwards" },
      ["<A-Right>"] = { "<C-i>", "Navigate Forwards" },
      ["<C-s>"] = { "<cmd> w <CR>", "Save file" },
      ["<C-S-s>"] = { "<cmd> wa <CR>", "Save all files" },
      ["<S-Down>"] = { "<Down>", "Move down" },
      ["<S-Up>"] = { "<Up>", "Move Up" },
    },

    n = {
      --["<CR>"] = { "o<Esc>", "New Line" },
      ["<C-d>"] = { "<C-d>zz", "Scroll down" },
      ["<C-f>"] = { "<C-u>zz", "Scroll up" },
      ["<C-u>"] = { "<C-u>zz", "Scroll up" },
      ["n"] = { "nzzzv", "next (search)" },
      ["N"] = { "Nzzzv", "previous (search)" },
      ["J"] = { "mzJ`z", "Move next line back" },
      ["<C-r>"] = { "<cmd> CMakeRun <CR>", "CMake run" },

      ["<A-Left>"] = { "<C-o>", "Navigate Backwards" },
      ["<A-Right>"] = { "<C-i>", "Navigate Forwards" },
      ["<C-S-s>"] = { "<cmd> wa <CR>", "Save all files" },

      ["<leader>y"] = { '"+y', "Yank to clipboard" },
      ["<leader>d"] = { '"_d', "Delete to void" },
      ["<leader>nh"] = { [[<cmd>lua require("notify").history()<CR>]], "Notification history" },
      ["<leader>dfs"] = { "<CMD>windo diffthis <CR>", "Diff split" },
      ["<leader>dfo"] = { "<CMD>windo diffoff <CR>", "Diff off" },
      ["<leader>doc"] = { "<CMD>Neogen<CR>", "Document under cursor" },
      ["<A-t>"] = { "<CMD>tabnew<CR>", "new tab" },
      ["<A-l>"] = { "<CMD>tabnext<CR>", "next tab" },
      ["<A-c>"] = { "<CMD>tabclose<CR>", "close tab" },

      ["<S-Down>"] = { "<Down>", "Move down" },
      ["<S-Up>"] = { "<Up>", "Move Up" },
      ["<C-,>"] = { "<CMD>vertical resize -5<CR>", "Resize vsplit -5" },
      ["<C-.>"] = { "<CMD>vertical resize +5<CR>", "Resize vsplit +5" },
      ["<C-;>"] = { "<CMD>resize -5<CR>", "Resize split -5" },
      ["<C-'>"] = { "<CMD>resize +5<CR>", "Resize split +5" },
    },
    v = {
      ["J"] = { ":m '>+1<CR>gv=gv", "Move down" },
      ["K"] = { ":m '<-2<CR>gv=gv", "Move Up" },
      -- ["<S-Down>"] = { ":m '>+1<CR>gv=gv", "Move down" },
      -- ["<S-Up>"] = { ":m '<-2<CR>gv=gv", "Move Up" },
      ["<S-Down>"] = { "<Down>", "Move down" },
      ["<S-Up>"] = { "<Up>", "Move Up" },

      ["<leader>y"] = { '"+y', "Yank to clipboard" },
      ["<leader>d"] = { '"_d', "Delete to void" },
      ["<leader>b"] = { ":DiffviewFileHistory<CR>", "Git history" },
    },
    x = {
      ["<leader>p"] = { '"_dP', "Paste" },
    },
  },
  trouble = {
    -- plugin = true,
    n = {
      ["<A-n>"] = { [[<cmd>lua require("trouble").next({skip_groups = true, jump = true})<CR>]], "Trouble next" },
      ["<A-m>"] = { [[<cmd>lua require("trouble").previous({skip_groups = true, jump = true})<CR>]], "Trouble prev" },
    },
  },
  lspsaga = {
    n = {
      ["sd"] = { [[<cmd>Lspsaga peek_definition<CR>]], "Peek definition" },
      ["fd"] = { [[<cmd>Lspsaga finder<CR>]], "Finder" },
      ["<A-m>"] = { [[<cmd>lua require("trouble").previous({skip_groups = true, jump = true})<CR>]], "Trouble prev" },
    },
  },
  cmake = {
    i = {
      ["<C-b>"] = { "<cmd> CMakeBuild <CR>", "CMake [b]uild" },
    },
    n = {
      ["<leader>cg"] = { "<cmd> CMakeGenerate<CR>", "CMake Generate" },
      ["<leader>cy"] = { "<cmd> CMakeSelectBuildType<CR>", "Select build type" },
      ["<leader>ct"] = { "<cmd> CMakeSelectBuildTarget <CR>", "Select CMake target" },
      ["<leader>cp"] = { "<cmd> CMakeSelectBuildPreset<CR>", "Select CMake preset" },
      ["<leader>cb"] = { "<cmd> CMakeBuild <CR>", "CMake build" },
      ["<leader>cs"] = { "<cmd> CMakeStop <CR>", "CMake stop" },
      ["<leader>cd"] = { "<cmd> CMakeDebug <CR>", "CMake debug" },
      ["<leader>ca"] = {
        function()
          local args = vim.fn.input "Command line args:"
          vim.cmd("CMakeLaunchArgs " .. args)
        end,
        "CMake launch args",
      },
      ["<C-b>"] = { "<cmd> CMakeBuild <CR>", "CMake build" },
      ["<leader>cr"] = { "<cmd> CMakeRun <CR>", "CMake run" },
      ["<C-r>"] = { "<cmd> CMakeRun <CR>", "CMake run" },
      ["<leader>cl"] = { "<cmd> CMakeSelectLaunchTarget <CR>", "CMake select launch target" },
      ["<leader>cqb"] = { "<cmd> CMakeQuickBuild <CR>", "CMake quick build" },
      ["<leader>cqd"] = { "<cmd> CMakeQuickDebug <CR>", "CMake quick debug" },
      ["<leader>cqr"] = { "<cmd> CMakeQuickRun <CR>", "CMake quick run" },
      ["<leader>cff"] = { "<cmd> Telescope cmake_tools <CR>", "Find cmake files" },
      ["<leader>cft"] = { "<cmd> CMakeShowTargetFiles <CR>", "Find cmake target files" },
      ["<leader>cct"] = { "<cmd> CMakeTargetSettings <CR>", "cmake target settings" },
      ["<leader>ccs"] = { "<cmd> CMakeSettings <CR>", "cmake settings" },
    },
  },
  perf = {
    n = {
      ["<leader>pr"] = { [[<cmd>lua RunPerf()<CR>]], "Run perf" },
      ["<leader>pa"] = { [[<cmd>lua AnalyzePerf()<CR>]], "Analyze Perf" },
      ["<leader>po"] = { [[<cmd>PerfToggleAnnotations<CR>]], "Toggle Perf" },
      ["<leader>pl"] = { [[<cmd>PerfHottestLines<CR>]], "Hottest Lines" },
      ["<leader>ps"] = { [[<cmd>PerfHottestSymbols<CR>]], "Hottest Symbols" },
      ["<leader>pf"] = { [[<cmd>PerfHottestCallersFunction<CR>]], "Hottest Callers" },
    },
  },
  gtest = {
    n = {
      ["<C-t>"] = { [[<cmd>GTestRunTestsuite<CR>]], "Run current Testsuite" },
      ["<leader>tc"] = { [[<cmd>GTestCancel<CR>]], "Cancel current test" },
      ["<leader>ts"] = { [[<cmd>GTestSelectAndRunTestsuite<CR>]], "Run Testsuite" },
      ["<leader>tt"] = { [[<cmd>GTestSelectAndRunTest<CR>]], "Run Test" },
    },
  },
  macros = {
    i = {},
  },
  fab = {
    -- plugin = true,

    i = {
      --["<F2>"] = { "<cmd> lua vim.lsp.buf.declaration() <CR><cmd> lua vim.lsp.buf.definition() <CR>", "Switch Source/Header" },
      -- ["<A-cr>"] = { "<cmd> lua vim.lsp.buf.code_action() <CR>", "Code Action" },
      ["<A-cr>"] = { "<cmd>Lspsaga code_action<CR>", "Code Action" },
      ["<F4>"] = { "<cmd> ClangdSwitchSourceHeader <CR>", "Switch Source/Header" },

      ["<A-j>"] = { "<cmd>cnext<CR>zz", "Quickfix next" },
      ["<A-k>"] = { "<cmd>cprev<CR>zz", "Quickfix previous" },
    },

    n = {
      ["ff"] = { "<cmd> ClangdSwitchSourceHeader <CR>", "Switch Source/Header" },
      ["<C-w>b"] = { "<cmd>%bd|e#<CR>", "Close other buffers" },
      ["K"] = { "<cmd> lua vim.lsp.buf.hover() <CR>", "Hover" },
      ["<F4>"] = { "<cmd> ClangdSwitchSourceHeader <CR>", "Switch Source/Header" },
      -- ["<A-cr>"] = { "<cmd> lua vim.lsp.buf.code_action() <CR>", "Code Action" },
      ["<A-cr>"] = { "<cmd>Lspsaga code_action<CR>", "Code Action" },
      -- ["<F2>"] = { "<cmd> lua vim.lsp.buf.declaration() <CR><cmd> lua vim.lsp.buf.definition() <CR>", "Follow Symbol" },
      ["cc"] = {
        function()
          vim.lsp.buf.declaration { on_list = function() end }
          vim.lsp.buf.definition {
            on_list = function()
              vim.cmd "Telescope lsp_definitions"
            end,
          }
        end,
        "Follow Symbol",
      },

      ["<leader>fr"] = { "<cmd> lua require('telescope.builtin').lsp_references() <CR>", "Find references" },
      ["<leader>fm"] = { "<cmd> Telescope marks <CR>", "Find marks" },
      ["<leader>ra"] = {
        function()
          require("nvchad.renamer").open()
        end,
        "LSP rename",
      },
      ["<leader>dd"] = {
        function()
          vim.diagnostic.open_float { border = "rounded" }
        end,
        "Floating diagnostic",
      },
      ["<A-d>"] = {
        function()
          vim.diagnostic.open_float { border = "rounded" }
        end,
        "Floating diagnostic",
      },
      ["<leader>s"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace under cursor" },

      ["<A-j>"] = { "<cmd>cnext<CR>zz", "Quickfix next" },
      ["<A-k>"] = { "<cmd>cprev<CR>zz", "Quickfix previous" },
      ["<leader>k"] = { "<cmd>lnext<CR>zz", "Location next" },
      ["<leader>j"] = { "<cmd>lprev<CR>zz", "Location previous" },
      ["<C-g>"] = {
        function()
          GitSignCodeAction()
        end,
        "Location previous",
      },

      ["<A-p>"] = { "<cmd>Gitsigns preview_hunk_inline<CR>", "git preview hunk inline" },
      ["<leader>gs"] = { "<cmd>Gitsigns stage_hunk<CR>", "git stage hunk" },
      ["<leader>gu"] = { "<cmd>Gitsigns undo_stage_hunk<CR>", "git unstage hunk" },
      ["<leader>gq"] = { "<cmd>Gitsigns setqflist<CR>", "git diffs quickfix" },
      ["<leader>gv"] = { "<cmd>DiffviewOpen<CR>", "Open diff view" },
      ["<leader>gc"] = { "<cmd>DiffviewClose<CR>", "Close diff view" },
      ["<leader>gh"] = { "<cmd>DiffviewFileHistory %<CR>", "git history" },
      ["<leader>gl"] = { "<cmd>LazyGit<CR>", "LazyGit" },
      ["<leader>gdr"] = { "<cmd>lua GitDiffRange()<CR>", "git diff range" },
      ["<leader>gdb"] = { "<cmd>lua GitDiffBranch()<CR>", "git diff branch" },
      ["-"] = { [[<cmd>Oil<CR>]], "Oil" },
      ["<leader>-"] = {
        function()
          local m = require "oil"
          if OIL_TOOGLE then
            m.set_columns {
              "icon",
              "permissions",
              "size",
              "mtime",
            }
            OIL_TOOGLE = false
          else
            m.set_columns {
              "icon",
            }
            OIL_TOOGLE = true
          end
        end,
        "Oil",
      },

      ["<leader>qc"] = { "<cmd>cclose<CR>", "Quickfix close" },
      ["<leader>qv"] = { "<cmd>cclose<CR><cmd>vert copen 100<CR>", "Quickfix open vertical" },
      ["<leader>qb"] = { "<cmd>cclose<CR><cmd>bot copen 12<CR>", "Quickfix open bottom" },
      ["<leader>qu"] = { "<cmd>cclose<CR><cmd>belowright copen 12<CR>", "Quickfix open bottom right" },
      ["<leader>qe"] = { "<cmd>cexpr []<CR><cmd>cclose<CR>", "Quickfix clear" },
      ["<leader>qr"] = {
        [[:cdo s///g | update<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>]],
        "quickfix replace",
      },
    },

    v = {
      ["<leader>s"] = { [[:s///<Left><Left>]], "Replace within selection" },
      ["<leader>r"] = { [[y:%s/<C-R>=escape(@",'/\:.')<esc>//g<Left><Left>]], "Replace selection" },

      ["<C-p>"] = { ":diffput<CR>", "Move diff of other view" },
    },
  },
  telescope = {
    plugin = true,

    i = {
      -- ["<A-q"] = {  function ()
      --   local actions = require "telescope.actions"
      --   actions.send_to_qflist()
      --   actions.open_qflist()
      -- end , "Find Symbols" },
    },
    n = {
      ["<leader>fs"] = { "<cmd> Telescope lsp_document_symbols <CR>", "Find Symbols" },
      ["<leader>fe"] = { "<cmd> Telescope lsp_dynamic_workspace_symbols <CR>", "Find symbols everywhere" },
      ["<leader>fg"] = { "<cmd> Telescope git_files <CR>", "Search git files" },
      ["<leader>fc"] = { "<cmd> Telescope git_status <CR>", "Search git diff" },
      ["<leader>fd"] = { "<cmd> Telescope diagnostics <CR>", "Diagnostics" },
      ["<leader>fu"] = { "<cmd> Telescope grep_string <CR>", "Grep string under cursor" },
    },
  },
  undotree = {
    n = {
      ["<leader>u"] = { vim.cmd.UndotreeToggle, "Undotree" },
    },
  },

  overseer = {
    n = {
      ["<leader>of"] = { "<CMD> OverseerQuickAction open float<CR>", "Overseet open float " },
      ["<leader>oh"] = { "<CMD> OverseerQuickAction open hsplit<CR>", "Overseet open hsplit" },
      ["<leader>ov"] = { "<CMD> OverseerQuickAction open vsplit<CR>", "Overseet open vsplit" },
      ["<leader>oq"] = { "<CMD> OverseerQuickAction open output in quickfix<CR>", "Overseet open quickfix" },
      ["<leader>oo"] = { "<CMD> OverseerToggle<CR>", "Overseet toggle" },
    },
  },
  dap = {
    --  ?/nat (float) i float = 9999
    --  ?/nat (char) i char = '\x0f'
    --  ?vec3 Vec4f = [NaN, 4.59163468E-41, 1.85081948E+13, 3.0611365E-41]
    --  ?/py hex($i) char[6] = "0x270f"
    --  ?i int = 9999

    n = {

      ["<leader>dt"] = {
        function()
          local w = require "dap.ui.widgets"
          w.sidebar(w.threads).open()
        end,
        "Stack frames",
      },
      ["<leader>ds"] = {
        function()
          local w = require "dap.ui.widgets"
          w.centered_float(w.frames)
        end,
        "Stack frames",
      },
      ["<leader>dv"] = {
        function()
          local w = require "dap.ui.widgets"
          w.centered_float(w.scopes)
        end,
        "Variables in Scope",
      },
      ["<leader>dg"] = {
        function()
          local lineNum = vim.api.nvim_win_get_cursor(0)[1]
          require("dap").goto_(lineNum)
        end,
        "Jump to cursor",
      },
      ["<leader><F9>"] = {
        function()
          local condition = vim.fn.input "Breakpoint Condition: "
          local hitcount = vim.fn.input "Hit count: "
          require("dap").toggle_breakpoint(condition, hitcount)
        end,
        "toogle breakpoint condition",
      },

      -- stylua: ignore start
      ["<F2>"]          = { function() require("dap").step_into() end, "step into", },
      ["<F3>"]          = { function() require("dap").step_out() end, "step out", },
      ["<leader><F1>"]  = { function() require("dap").run_to_cursor() end, "Run to cursor", },
      ["<F1>"]          = { function() require("dap").step_over() end, "step over", },
      ["<F5>"]          = { function() require("dap").continue() end, "continue", },
      ["<F6>"]          = { function() require("dap").restart() end, "restart", },
      ["<F7>"]          = { function() require("dap").run_last() end, "run last", },
      ["<F9>"]          = { function() require("dap").toggle_breakpoint() end, "toogle breakpoint", },
      ["<F10>"]         = { function() require("dap").step_over() end, "step over", },
      ["<leader><F10>"] = { function() require("dap").run_to_cursor() end, "Run to cursor", },
      ["<F12>"]         = { function() require("dap").step_into() end, "step into", },
      ["<leader><F12>"] = { function() require("dap").step_out() end, "step out", },
      ["<F11>"]         = { function() require("dap").step_into() end, "step into", },
      ["<S-F11>"]       = { function() require("dap").step_out() end, "step out", },
      ["<A-DOWN>"]      = { function() require("dap").up() end, "go up in stack", },
      ["<A-UP>"]        = { function() require("dap").down() end, "go down in stack", },
      ["<leader>di"]    = { function() require("dap").step_into() end, "step into", },
      ["<leader>do"]    = { function() require("dap").step_out() end, "step out", },
      ["<leader>du"]    = { function() require("dapui").toggle() end, "Toggle Debug UI", },
      ["<leader>dq"]    = { function() require("dap").terminate() end, "Stop debugging", },
      ["<leader>db"]    = { function() require("dap").pause() end, "Pause", },
      ["<leader>dc"]    = { function() require("dap").clear_breakpoints() end, "Clear breakpoints", },
      ["<leader>dl"]    = { function() require("dap").list_breakpoints() end, "List breakpoints", },
      ["<leader>dr"]    = { function() require("dap").repl.toggle() end, "Open repl", },
      ["<leader>dh"]    = { function() require("dap.ui.widgets").hover() end, "Hover", },
      ["<leader>dp"]    = { function() require("dap.ui.widgets").preview() end, "Preview", },
      ["<leader>dz"]    = { function() require("dap.ui.widgets").update_render() {} end, "Refresh", },
      ["<leader>de"]    = { function() require('dap').set_exception_breakpoints() end, "Set exceptions breakpoints", },
      -- stylua: ignore end
      -- ["<leader>dot"] = { function() local w = require "dap.ui.widgets" w.sidebar(w.threads).open() end, "Threds in sidebar", },
      -- ["<leader>dof"] = { function() local w = require "dap.ui.widgets" w.sidebar(w.frames).open() end, "Stack frames sidebar", },
      -- ["<leader>dos"] = { function() local w = require "dap.ui.widgets" w.sidebar(w.scopes).open() end, "Variables in Scope sidebar", },
    },
  },
}

return M
