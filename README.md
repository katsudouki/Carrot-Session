# Carrot Session

Carrot Session is a Neovim plugin that allows you to save and load active tabs, virtual environments (virtualenv), and the state of NvimTree. This plugin is ideal for developers who want to keep their workspace organized and easily recoverable.

## Features

- **Save Sessions**: Saves the current virtual environment and open tabs. You can pass an argument for the session name. If used without arguments, the session name will be the same as the current directory + the git branch.
- **Load Sessions**: Loads previously saved sessions.
- **List Sessions**: Lists all saved sessions.
- **Delete Sessions**: Deletes a specific session.
- **Clear Sessions**: Removes all saved sessions.

## Commands

- `:CarrotSave [session_name]`: Saves the current virtual environment and tabs. If no name is provided, the default will be the current directory + the git branch.
- `:CarrotLoad [session_name]`: Loads a saved session.
- `:CarrotList`: Lists all saved sessions.
- `:CarrotDelete [session_name]`: Deletes a specific session.
- `:CarrotClear`: Removes all saved sessions.

## Installation

To install Carrot Session, add the following to your Neovim configuration file:

```lua
use 'katsudouki/Carrot-Session'