return {
  -- NOTE: First, some plugins that don't require any configuration

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",
  -- Lua configuration
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
  },
  {
    "max397574/better-escape.nvim",
    opts = {
      default_mappings = false,
      mappings = {
        i = {
          j = {
            -- These can all also be functions
            k = "<Esc>",
          },
        },
        c = {
          j = {
            k = "<Esc>",
          },
        },
        s = {
          j = {
            k = "<Esc>",
          },
        },
      },
    },
  },
  -- Useful plugin to show you pending keybinds.
  {
    "folke/which-key.nvim",
    opts = {
      win = {
        border = "rounded",
      },
      icons = {
        mappings = false
      }
    }
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable "git" == 1,
    event = "User FileOpened",
    opts = {
      current_line_blame = true,
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d (%a) @ %H:%M> - <abbrev_sha> - <summary>',
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Actions
        -- visual mode
        map("v", "<leader>gS", function()
          gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "stage git hunk" })
        map("v", "<leader>gR", function()
          gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, { desc = "reset git hunk" })
        -- normal mode
        map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
        map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
        map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
        map("n", "<leader>gb", function()
          gs.blame_line { full = false }
        end, { desc = "git blame line" })
        map("n", "<leader>gd", gs.diffthis, { desc = "git diff against index" })
        map("n", "<leader>gD", function()
          gs.diffthis "~"
        end, { desc = "git diff against last commit" })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
      end,
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "VimEnter", -- Workaround: if do later, some highlights are not working
    opts = {
      indent = { char = "▏" },
      scope = { show_start = false, show_end = false },
      exclude = {
        buftypes = {
          "nofile",
          "terminal",
        },
        filetypes = {
          "help",
          "startify",
          "aerial",
          "alpha",
          "dashboard",
          "lazy",
          "neogitstatus",
          "NvimTree",
          "neo-tree",
          "Trouble",
        },
      },
    },
  },
  {
    -- Set lualine as statusline
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { "dokwork/lualine-ex" },
      { "nvim-lua/plenary.nvim" },
      {
        'linrongbin16/lsp-progress.nvim',
        config = function()
          require('lsp-progress').setup()
        end
      },
      { "cbochs/grapple.nvim" },
    },
    event = "VeryLazy",
    config = function(_, opts)
      local function encoding()
        local ret, _ = (vim.bo.fenc or vim.go.enc):gsub("^utf%-8$", "")
        return ret
      end
      -- fileformat: Don't display if &ff is unix.
      local function fileformat()
        local ret, _ = vim.bo.fileformat:gsub("^unix$", "")
        return ret
      end
      local function ts_enabled()
        if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] == nil then
          return ""
        end
        return "[TS]"
      end
      local function list_lsp_and_null_ls()
        local buf_clients = vim.lsp.get_active_clients { bufnr = vim.api.nvim_get_current_buf() }
        local null_ls_installed, null_ls = pcall(require, "null-ls")
        local buf_client_names = {}
        local seen = {}
        for _, client in pairs(buf_clients) do
          if client.name == "null-ls" then
            if null_ls_installed then
              for _, source in ipairs(null_ls.get_source({ filetype = vim.bo.filetype })) do
                if not seen[source.name] == true then
                  table.insert(buf_client_names, source.name)
                  seen[source.name] = true
                end
              end
            end
          else
            if not seen[client.name] then
              table.insert(buf_client_names, client.name)
              seen[client.name] = true
            end
          end
        end
        if buf_client_names == nil then
          return "no lsp"
        end
        return table.concat(buf_client_names, ", ")
      end

      local c = require("vscode.colors").get_colors()
      local custom_opts = {
        options = {
          icons_enabled = true,
          theme = {
            normal = {
              a = { fg = c.vscNone, bg = c.vscPopupHighlightBlue },
              b = { fg = c.vscNone, bg = c.vscLeftDark },
              c = { fg = c.vscNone, bg = c.vscCursorDarkDark },
            },
            visual = {
              a = { fg = c.vscBack, bg = c.vscOrange },
              b = { fg = c.vscNone, bg = c.vscLeftDark },
              c = { fg = c.vscNone, bg = c.vscCursorDarkDark },
            },
            inactive = {
              a = { fg = c.vscNone, bg = c.vscCursorDarkDark },
              b = { fg = c.vscNone, bg = c.vscCursorDarkDark },
            },
            replace = {
              a = { fg = c.vscNone, bg = c.vscDiffRedDark },
              b = { fg = c.vscNone, bg = c.vscLeftDark },
              c = { fg = c.vscNone, bg = c.vscCursorDarkDark },
            },
            insert = {
              a = { fg = c.vscNone, bg = c.vscDiffGreenLight },
              b = { fg = c.vscNone, bg = c.vscLeftDark },
              c = { fg = c.vscNone, bg = c.vscCursorDarkDark },
            },
          },
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "NvimTree", "neo%-tree", "dashboard", "Outline", "aerial" },
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 100,
          }
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              "branch",
              color = { fg = c.vscPink }
            },
            { "diff" },
            { "diagnostics" },
          },
          lualine_c = {
            { "ex.relative_filename", max_length = -1, separator = '', },
            { fileformat },
            { encoding },
          },
          lualine_x = {
            {
              function()
                -- invoke `progress` here.
                return require('lsp-progress').progress()
              end,
              color = { fg = c.vscPink },
            },
            { list_lsp_and_null_ls },
            {
              -- display if the current file is tagged in `grapple`
              function()
                return "[G]"
              end,
              cond = function()
                return package.loaded["grapple"] and require("grapple").exists()
              end,
              color = { fg = c.vscBlueGreen, gui = "bold" },
            },
            {
              ts_enabled,
              color = { fg = c.vscGreen, gui = "bold" },
            },
          },
          lualine_y = { "progress" },
          lualine_z = { "location" }
        },
      }
      require("lualine").setup(vim.tbl_deep_extend("force", opts, custom_opts))
    end
  },
  {
    "numToStr/Comment.nvim",
    event = "User FileOpened",
    opts = {
      ---LHS of operator-pending mappings in NORMAL and VISUAL mode
      toggler = {
        ---Line-comment keymap
        line = "<leader>/",
      },
      opleader = {
        ---Line-comment keymap
        line = "<leader>/",
      },
    }
  },
  -- Spectre replace
  {
    'nvim-pack/nvim-spectre',
    event = "VeryLazy",
    opts = {}
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local actions = require "fzf-lua.actions"
      local vert_winopts = {
        preview = {
          vertical = "down:50%",
          layout = "vertical",
        },
      }

      require("fzf-lua").setup({
        winopts = {
          on_create = function()
            vim.keymap.set("t", "jk", "<Esc>", { silent = true, buffer = true })
          end,
          height    = 0.95,
          width     = 0.9,
          row       = 0.5,
          -- treesitter = {
          --   -- enabled    = true,
          --   -- fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
          -- },
          -- hl = { normal = "Pmenu" },
        },
        fzf_opts = {
          ["--no-info"] = "",
          ["--info"] = "hidden",
          -- ["--header"] = " ",
          ["--no-scrollbar"] = "",
          -- for history, see https://github.com/ibhagwan/fzf-lua/wiki#how-do-i-setup-input-history-keybinds
          ['--history'] = vim.fn.stdpath("data") .. '/fzf-lua-history',
        },
        keymap = {
          builtin = {
            true, -- inherit from defaults
            ["<M-down>"] = "preview-down",
            ["<M-up>"]   = "preview-up",
          },
          fzf = {
            ["ctrl-q"] = "select-all+accept",
          },
        },
        files = {
          winopts    = { preview = { hidden = "hidden" } },
          rg_opts    = [[--color=never --hidden --files -g "!.git"]],
          fd_opts    = [[--color=never --hidden --type f --type l --exclude .git]],
          cwd_prompt = false,
          prompt     = 'Files> '

        },
        lsp = { winopts = vert_winopts },
        blines = { winopts = vert_winopts },
        grep = {
          rg_opts =
          [[--hidden --follow -g "!.git" --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e]],
          actions = {
            ["ctrl-f"] = { actions.grep_lgrep },
            ["ctrl-g"] = false,
          },
          winopts = vert_winopts
        },
        oldfiles = {
          cwd_only                = true,
          include_current_session = true, -- include bufs from current session
        },

      })
    end
  },
  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    config = function()
      local setup_fn = function()
        require("nvim-treesitter.configs").setup {
          -- Add languages to be installed here that you want installed for treesitter
          ensure_installed = {
            "python",
            "bash",
            "yaml"
          },

          -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
          auto_install = false,

          highlight = { enable = true },
          indent = { enable = true },
          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "<c-space>",
              node_incremental = "<c-space>",
              scope_incremental = "<c-s>",
              node_decremental = "<M-space>",
            },
          },
        }
      end
      vim.defer_fn(setup_fn, 0)
    end
  },
  {
    "akinsho/bufferline.nvim",
    event = "User FileOpened",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
      { "famiu/bufdelete.nvim" },
      { "Mofiqul/vscode.nvim" },
    },
    config = function(_, opts)
      local c = require("vscode.colors").get_colors()
      local custom_opts = {
        highlights = {
          fill = {
            bg = c.vscGreen,
          },
          buffer_visible = {
            fg = c.vscFront,
          },
        },
        options = {
          max_name_length = 35,
          truncate_names = false,
          show_buffer_icons = true,
          show_buffer_close_icons = false,
        }
      }
      require("bufferline").setup(vim.tbl_deep_extend("force", opts, custom_opts))
    end
  },
  { "nvim-tree/nvim-web-devicons" },
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    commit = "44acc60e150907a327aefc676ea56ee53bdae5a6",
    config = function()
      local c = require("vscode.colors").get_colors()
      require("vscode").setup({
        transparent = false,
        -- Override colors (see ./lua/vscode/colors.lua)
        color_overrides = {
          -- Approx of color 256 but slightly darker
          vscLeftDark = "#282828", -- We use it for `NormalNC`/`WinBarNC`, see `highlights.lua`
          vscCursorDarkDark = "#303030",
        },
        -- Override highlight groups (see ./lua/vscode/theme.lua)
        group_overrides = {
          -- this supports the same val table as vim.api.nvim_set_hl
          -- use colors from this colorscheme by requiring vscode.colors!
          ["@text.reference"] = { fg = c.vscLightBlue, bg = "NONE" },
          ["@text.uri"] = { fg = c.vscOrange, bg = "NONE" },
          ["@text.todo.unchecked"] = { fg = c.vscOrange, bg = "NONE" },
          ["@text.todo.checked"] = { fg = c.vscOrange, bg = "NONE" },
          ["@text.quote"] = { fg = c.vscLightBlue, bg = "NONE" },
          ["@punctuation.special"] = { fg = c.vscYellow, bg = "NONE" },
        },
      })
      vim.cmd("colorscheme vscode")
    end,
  },
  -- Allows git links for lines and selections
  {
    "ruifm/gitlinker.nvim",
    event = "User FileOpened",
    dependencies = { "nvim-lua/plenary.nvim", "ojroques/nvim-osc52" },
    config = function()
      require("gitlinker").setup({
        callbacks = {
          ["gitlab-master.nvidia.com"] = require "gitlinker.hosts".get_gitlab_type_url
        },
        opts = {
          action_callback = function(url)
            -- yank to unnamed register
            vim.api.nvim_command("let @\" = '" .. url .. "'")
            -- copy to the system clipboard using OSC52
            require("osc52").copy_register("")
          end,
        },
      })
    end,
  },
  -- Allows vim to feel losing and gaining focus from tmux
  { "sjl/vitality.vim" },
  -- Pounce allows to quickly jump to fuzzy place on visible screen
  {
    "rlane/pounce.nvim",
    event = "User FileOpened",
    dependencies = { "Mofiqul/vscode.nvim" }, -- Uses colors from the palette.
  },
  -- Helm gotpl+yaml highlighter, see also `on_attach` for `yamlls`
  {
    "towolf/vim-helm",
    ft = "helm",
  },
  -- For yanking from terminal, see
  {
    "ojroques/nvim-osc52",
    event = "User FileOpened",
    config = function()
      require("osc52").setup({
        max_length = 0,          -- Maximum length of selection (0 for no limit)
        silent = true,           -- Disable message on successful copy
        trim = false,            -- Trim surrounding whitespaces before copy
        tmux_passthrough = true, -- Use tmux passthrough (requires tmux: set -g allow-passthrough on)
      })
      local function copy()
        if (vim.v.event.operator == "y" or vim.v.event.operator == "d") and vim.v.event.regname == "" then
          require("osc52").copy_register("")
        end
      end
      vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
    end,
  },
  -- Allowing seamless navigation btw tmux and vim
  { "christoomey/vim-tmux-navigator" },
  -- This is a better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      preview = {
        win_height = 999,
        winblend = 0,
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    event = "WinEnter",
    opts = {
      ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
      ignored_buftypes = { "nofile" },
    }
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    version = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer NeoTree (root dir)", remap = true },
      {
        "<leader>o",
        function()
          if vim.bo.filetype == "neo-tree" then
            vim.cmd.wincmd "p"
          else
            vim.cmd.Neotree "focus"
          end
        end
        ,
        desc = "Explorer NeoTree (toggle)",
        remap = true
      },
    },
    opts = {
      close_if_last_window = true,
      default_source = "filesystem",
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      window = {
        position = "right",
        width = 55,
        mappings = {
          ["<S-h>"] = "prev_source",
          ["<S-l>"] = "next_source",
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = true,
        },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      event_handlers = {
        {
          -- https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#auto-close-on-open-file
          event = "file_opened",
          handler = function(_) -- argument is `file_path`
            --auto close
            require("neo-tree").close_all()
          end
        },
      },
    }
  },
  -- Seems that editorconfig in nvim 0.8 is not picked up, and `guess-indent.nvim`
  -- gets messed up with it,
  -- see https://github.com/NMAC427/guess-indent.nvim/issues/15#issuecomment-1586308382
  {
    "gpanders/editorconfig.nvim",
    event = "User FileOpened",
    opt = {}
  },
  {
    "akinsho/toggleterm.nvim",
    event = "User FileOpened",
    opts = {
      border = "single",
      -- like `size`, width and height can be a number or function which is passed the current terminal
      width = function()
        return math.ceil(vim.o.columns * 0.87)
      end,
      height = function()
        return math.ceil(vim.o.lines * 0.85)
      end,
      direction = "float",
      float_opts = { border = "rounded" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
      vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>",
        { desc = "ToggleTerm vert" })
      vim.keymap.set({ "n", "t" }, "<F7>", "<cmd>ToggleTerm<cr>", { desc = "ToggleTerm" })
    end
  },
}
