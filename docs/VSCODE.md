# Visual Studio Code

A workspace configuration file is provided, which includes global and extension settings in one. The global settings could be moved to the more general settings file, if needed. To do that: `Ctrl + Shift + P`, then type `Preferences: Open User Settings (JSON)`.

The configuration file is `.vscode/settings.json` and is automatically used when the workspace is opened. It also takes precedence over the user (general) VS Code `settings.json` file.

To install any extensions, open the "Extensions" tab as usual (or with `Ctrl/Cmd + Shift + X`) and search them by name.

Alternatively, they should appear on the "Recommended" tab, courtesy of `extensions.json`.

Remember to enable them by workspace to minimize performance degradation. This can be achieved by selecting a disabled extension and, through the dropdown menu, choose "Enable (Workspace)".
