local M = {}

local session_dir = vim.fn.expand("~/.config/nvim/sessions/")

-- INFO: Ensures that the session directory exists
local function ensure_session_dir()
  if vim.fn.isdirectory(session_dir) == 0 then
    vim.fn.mkdir(session_dir, "p")
  end
end

-- INFO: Gets the current folder name and the git branch
local function get_default_name()
  -- NOTE: Gets the current folder name
  local cwd = vim.fn.getcwd():match("([^/]+)$"):lower() -- NOTE: Extracts the last folder name
  -- NOTE: Gets the git branch name
  local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1] or "no-branch"

  cwd = cwd:gsub("%s+", "") -- NOTE: Removes white spaces
  branch = branch:gsub("%s+", "") -- NOTE: Removes white spaces

  if cwd == "" then cwd = "unknown-folder" end
  if branch == "" or branch == "HEAD" then branch = "no-branch" end

  return cwd .. "-" .. branch
end

-- INFO: Function to save the session
local function save_session_files(name)
  ensure_session_dir()

  -- NOTE: If the name is not provided, generates a name automatically
  local session_name = name or get_default_name()

  local session_file = session_dir .. session_name .. ".session"
  local virtualenv_file = session_dir .. session_name .. ".virtualenv"

  -- INFO: Saving session
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))

  -- INFO: Saving virtualenv
  local venv = os.getenv("VIRTUAL_ENV") or ""
  local venv_handle = io.open(virtualenv_file, "w")
  if venv_handle then
    venv_handle:write(venv)
    venv_handle:close()
  end

  print("🥕 Carrot saved: " .. session_name)
end

-- INFO: Function to load the session and virtualenv
local function load_session_and_virtualenv(name)
  -- NOTE: If the name is not provided, generates it automatically
  local session_name = name or get_default_name()
  local session_file = session_dir .. session_name .. ".session"
  local virtualenv_file = session_dir .. session_name .. ".virtualenv"

  -- INFO: Checks if the session file exists
  if vim.fn.filereadable(session_file) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(session_file))
    print("🥕 Carrot loaded: " .. session_name)
  else
    print("No session file found for 🥕 Carrot: " .. session_name)
  end

  -- INFO: Load the virtualenv, if available
  local venv_handle = io.open(virtualenv_file, "r")
  if venv_handle then
    local venv = venv_handle:read("*a"):gsub("%s+", "")
    venv_handle:close()
    if venv ~= "" then
      vim.fn.system("source " .. vim.fn.shellescape(venv .. "/bin/activate"))
      print("Virtualenv activated: " .. venv)
    else
      print("No virtualenv found.")
    end
  else
    print("No virtualenv file found for session.")
  end
end

-- NOTE: Function to list saved sessions
local function list_sessions()
  local files = vim.fn.glob(session_dir .. "*.session", 0, 1)
  if #files == 0 then
    print("No saved sessions found.")
    return {}
  end

  local sessions = {}
  for _, file in ipairs(files) do
    local session_name = file:match("([^/]+)%.session$")
    if session_name then
      table.insert(sessions, session_name)
    end
  end

  return sessions
end

-- NOTE: Function to clear all sessions
local function clear_sessions()
  local files = vim.fn.glob(session_dir .. "*", 0, 1)
  for _, file in ipairs(files) do
    vim.fn.delete(file)
  end
  print("All sessions cleared.")
end

-- NOTE: Function to delete a specific session
local function delete_session(name)
  local session_base_path = session_dir .. name
  local session_files = {
    session_base_path .. ".session",
    session_base_path .. ".virtualenv"
  }

  for _, file in ipairs(session_files) do
    if vim.fn.filereadable(file) == 1 then
      vim.fn.delete(file)
    end
  end

  print("Session deleted: " .. name)
end

-- INFO: Command settings for the plugin
function M.setup()
  -- INFO: Command to save the session
  vim.api.nvim_create_user_command("CarrotSave", function(args)
    save_session_files(args.args ~= "" and args.args or nil)
  end, { nargs = "?" })

  -- INFO: Command to load the session and virtualenv
  vim.api.nvim_create_user_command("CarrotLoad", function(args)
    load_session_and_virtualenv(args.args ~= "" and args.args or get_default_name())
  end, {
    nargs = "?", 
    complete = function() return list_sessions() end
  })

  -- INFO: Command to list saved sessions
  vim.api.nvim_create_user_command("CarrotList", function()
    local sessions = list_sessions()
    if #sessions == 0 then
      print("No saved Carrots.")
    else
      print("Saved Carrots:")
      for _, session in ipairs(sessions) do
        print("🥕 " .. session)
      end
    end
  end, {})

  -- INFO: Command to clear all sessions
  vim.api.nvim_create_user_command("CarrotClear", clear_sessions, {})

  -- INFO: Command to delete a specific session
  vim.api.nvim_create_user_command("CarrotDelete", function(args)
    delete_session(args.args)
  end, { 
    nargs = 1,
    complete = function() return list_sessions() end
  })
end

return M
