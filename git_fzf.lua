-- local path = require("pl.path")
local sh = require("shell")

local git = sh.cmd("command", "-v", "git"):output()
sh.cmd(git, "status"):exec()

-- @todo error text should be held in an Error object type thing
local is_git_dir = sh.cmd(git, "rev-parse", "--is-inside-work-tree")
local git_dir_error = "this directory and its parents are not a git dir"
assert(is_git_dir:output(), git_dir_error)

-- @todo most variables in this file need better names...

local fzf_err = "could not find fzf executable. please make sure fzf is in your $PATH"
local FZF = assert(sh.cmd("command", "-v", "fzf"):output(), fzf_err)

local Prompt = {}

local menu_table = {
  "add",
  "commit",
  "remotes",
  "push",
  "pull"
}

Prompt.menu_list = table.concat(menu_table, "\n")

local fzf_exec = sh.cmd(FZF, "--exact", "--layout=reverse-list", "--disabled", "--multi", '--prompt="choose: "')

local initCommand = sh.cmd("echo", Prompt.menu_list) | fzf_exec
local selected_option = assert(initCommand:output(), "unable to initialize fzf menu")

Prompt.sub_menu_list = {
  [menu_table[1]] = {"all", "select"},
  [menu_table[2]] = {},
  [menu_table[3]] = {"add", "remove", "update", "list"},
  [menu_table[4]] = {},
  [menu_table[5]] = {}
}

local selected_sub_menu_option = Prompt.sub_menu_list[selected_option]
local sub_option_list = table.concat(selected_sub_menu_option, "\n")
local subOptionCommand = sh.cmd("echo", sub_option_list) | fzf_exec

local git_command = assert(subOptionCommand:output(), "unable to initialize fzf submenu")

Prompt.git_commands = {
  add = {
    all = {git, "add", "--all"},
    select = function()
      local filelist = {}
      print "not implemented"
      -- present fzf prompt, select files and save as "filelist"
      return filelist
    end
  },
  commit = {git, "commit"}, -- should this be a function to allow additional options?
  push = {git, "push"}, -- should this be a function to allow additional options?
  pull = {git, "pull"}, -- should this be a function to allow additional options?
  remotes = {opts = {}}
}

local compiled_git_command = selected_option .. git_command

if selected_option == "remotes" then
  print("remotes")
  print "remotes not implemented"
  return
end

if compiled_git_command == "add all" then
  local gcmd = Prompt.git_commands.add.all
  assert(sh.cmd(gcmd[1], gcmd[2], gcmd[3]):exec(), "issue with git add --all")
  return
end

local gcmd = Prompt.git_commands[selected_option]

local _git_exec = sh.cmd(gcmd[1], gcmd[2])
assert(_git_exec:exec(), "issue with " .. table.concat(_git_exec, "\n"))
return
