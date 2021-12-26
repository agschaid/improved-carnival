local wezterm = require 'wezterm';

local profile_file = "/home/agl/.theme"

function color()

  local file = io.open(profile_file)
  if file then -- just checking whether file exists
    file:close()
    for l in io.lines(profile_file) do
      if l == "light" then
        return "Builtin Solarized Light"
      end
    end
  end

  return "Builtin Solarized Dark"
end

wezterm.add_to_config_reload_watch_list(profile_file);

return {

  -- i am using nixos packaging. So no use in showing me the newest 
  check_for_updates = false,
  enable_tab_bar = false,

  color_scheme = color(),
  font = wezterm.font("Victor Mono"),
  font_size = 13,

  window_padding = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2
  }
}

