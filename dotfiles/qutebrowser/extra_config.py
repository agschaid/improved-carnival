# base16-qutebrowser (https://github.com/theova/base16-qutebrowser)
# Base16 qutebrowser template by theova
# Solarized Dark scheme by Ethan Schoonover (modified by aramisgithub)

base03 = "#002b36"
base02 = "#073642"
base01 = "#586e75"
base00 = "#657b83"
base0 = "#839496"
base1 = "#93a1a1"
base2 = "#eee8d5"
base3 = "#fdf6e3"
red = "#dc322f"
orange = "#cb4b16"
yellow = "#b58900"
green = "#859900"
cyan = "#2aa198"
blue = "#268bd2"
violet = "#6c71c4"
magenta = "#d33682"

# set qutebrowser colors

# Text color of the completion widget. May be a single color to use for
# all columns or a list of three colors, one for each column.
c.colors.completion.fg = base1

# Background color of the completion widget for odd rows.
c.colors.completion.odd.bg = base02

# Background color of the completion widget for even rows.
c.colors.completion.even.bg = base03

# Foreground color of completion widget category headers.
c.colors.completion.category.fg = yellow

# Background color of the completion widget category headers.
c.colors.completion.category.bg = base03

# Top border color of the completion widget category headers.
c.colors.completion.category.border.top = base03

# Bottom border color of the completion widget category headers.
c.colors.completion.category.border.bottom = base03

# Foreground color of the selected completion item.
c.colors.completion.item.selected.fg = base1

# Background color of the selected completion item.
c.colors.completion.item.selected.bg = base01

# Top border color of the selected completion item.
c.colors.completion.item.selected.border.top = base01

# Bottom border color of the selected completion item.
c.colors.completion.item.selected.border.bottom = base01

# Foreground color of the matched text in the selected completion item.
c.colors.completion.item.selected.match.fg = green

# Foreground color of the matched text in the completion.
c.colors.completion.match.fg = green

# Color of the scrollbar handle in the completion view.
c.colors.completion.scrollbar.fg = base1

# Color of the scrollbar in the completion view.
c.colors.completion.scrollbar.bg = base03

# Background color of disabled items in the context menu.
c.colors.contextmenu.disabled.bg = base02

# Foreground color of disabled items in the context menu.
c.colors.contextmenu.disabled.fg = base0

# Background color of the context menu. If set to null, the Qt default is used.
c.colors.contextmenu.menu.bg = base03

# Foreground color of the context menu. If set to null, the Qt default is used.
c.colors.contextmenu.menu.fg =  base1

# Background color of the context menu’s selected item. If set to null, the Qt default is used.
c.colors.contextmenu.selected.bg = base01

#Foreground color of the context menu’s selected item. If set to null, the Qt default is used.
c.colors.contextmenu.selected.fg = base1

# Background color for the download bar.
c.colors.downloads.bar.bg = base03

# Color gradient start for download text.
c.colors.downloads.start.fg = base03

# Color gradient start for download backgrounds.
c.colors.downloads.start.bg = blue

# Color gradient end for download text.
c.colors.downloads.stop.fg = base03

# Color gradient stop for download backgrounds.
c.colors.downloads.stop.bg = cyan

# Foreground color for downloads with errors.
c.colors.downloads.error.fg = red

# Font color for hints.
c.colors.hints.fg = base03

# Background color for hints. Note that you can use a `rgba(...)` value
# for transparency.
c.colors.hints.bg = yellow

# Font color for the matched part of hints.
c.colors.hints.match.fg = base1

# Text color for the keyhint widget.
c.colors.keyhint.fg = base1

# Highlight color for keys to complete the current keychain.
c.colors.keyhint.suffix.fg = base1

# Background color of the keyhint widget.
c.colors.keyhint.bg = base03

# Foreground color of an error message.
c.colors.messages.error.fg = base03

# Background color of an error message.
c.colors.messages.error.bg = red

# Border color of an error message.
c.colors.messages.error.border = red

# Foreground color of a warning message.
c.colors.messages.warning.fg = base03

# Background color of a warning message.
c.colors.messages.warning.bg = violet

# Border color of a warning message.
c.colors.messages.warning.border = violet

# Foreground color of an info message.
c.colors.messages.info.fg = base1

# Background color of an info message.
c.colors.messages.info.bg = base03

# Border color of an info message.
c.colors.messages.info.border = base03

# Foreground color for prompts.
c.colors.prompts.fg = base1

# Border used around UI elements in prompts.
c.colors.prompts.border = base03

# Background color for prompts.
c.colors.prompts.bg = base03

# Background color for the selected item in filename prompts.
c.colors.prompts.selected.bg = base01

# Foreground color of the statusbar.
c.colors.statusbar.normal.fg = green

# Background color of the statusbar.
c.colors.statusbar.normal.bg = base03

# Foreground color of the statusbar in insert mode.
c.colors.statusbar.insert.fg = base03

# Background color of the statusbar in insert mode.
c.colors.statusbar.insert.bg = blue

# Foreground color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.fg = base03

# Background color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.bg = cyan

# Foreground color of the statusbar in private browsing mode.
c.colors.statusbar.private.fg = base03

# Background color of the statusbar in private browsing mode.
c.colors.statusbar.private.bg = base02

# Foreground color of the statusbar in command mode.
c.colors.statusbar.command.fg = base1

# Background color of the statusbar in command mode.
c.colors.statusbar.command.bg = base03

# Foreground color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.fg = base1

# Background color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.bg = base03

# Foreground color of the statusbar in caret mode.
c.colors.statusbar.caret.fg = base03

# Background color of the statusbar in caret mode.
c.colors.statusbar.caret.bg = violet

# Foreground color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.fg = base03

# Background color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.bg = blue

# Background color of the progress bar.
c.colors.statusbar.progress.bg = blue

# Default foreground color of the URL in the statusbar.
c.colors.statusbar.url.fg = base1

# Foreground color of the URL in the statusbar on error.
c.colors.statusbar.url.error.fg = red

# Foreground color of the URL in the statusbar for hovered links.
c.colors.statusbar.url.hover.fg = base1

# Foreground color of the URL in the statusbar on successful load
# (http).
c.colors.statusbar.url.success.http.fg = cyan

# Foreground color of the URL in the statusbar on successful load
# (https).
c.colors.statusbar.url.success.https.fg = green

# Foreground color of the URL in the statusbar when there's a warning.
c.colors.statusbar.url.warn.fg = violet

# Background color of the tab bar.
c.colors.tabs.bar.bg = base03

# Color gradient start for the tab indicator.
c.colors.tabs.indicator.start = blue

# Color gradient end for the tab indicator.
c.colors.tabs.indicator.stop = cyan

# Color for the tab indicator on errors.
c.colors.tabs.indicator.error = red

# Foreground color of unselected odd tabs.
c.colors.tabs.odd.fg = base1

# Background color of unselected odd tabs.
c.colors.tabs.odd.bg = base02

# Foreground color of unselected even tabs.
c.colors.tabs.even.fg = base1

# Background color of unselected even tabs.
c.colors.tabs.even.bg = base03

# Background color of pinned unselected even tabs.
c.colors.tabs.pinned.even.bg = cyan

# Foreground color of pinned unselected even tabs.
c.colors.tabs.pinned.even.fg = base3

# Background color of pinned unselected odd tabs.
c.colors.tabs.pinned.odd.bg = green

# Foreground color of pinned unselected odd tabs.
c.colors.tabs.pinned.odd.fg = base3

# Background color of pinned selected even tabs.
c.colors.tabs.pinned.selected.even.bg = base03

# Foreground color of pinned selected even tabs.
c.colors.tabs.pinned.selected.even.fg = orange

# Background color of pinned selected odd tabs.
c.colors.tabs.pinned.selected.odd.bg = base03

# Foreground color of pinned selected odd tabs.
c.colors.tabs.pinned.selected.odd.fg = orange

# Foreground color of selected odd tabs.
c.colors.tabs.selected.odd.fg = orange

# Background color of selected odd tabs.
c.colors.tabs.selected.odd.bg = base03

# Foreground color of selected even tabs.
c.colors.tabs.selected.even.fg = orange

# Background color of selected even tabs.
c.colors.tabs.selected.even.bg = base03

# Background color for webpages if unset (or empty to use the theme's
# color).
# c.colors.webpage.bg = base03

########################

# if the websites puts the focus on an input field on load -> switch to insert mode
c.input.insert_mode.auto_load = True

