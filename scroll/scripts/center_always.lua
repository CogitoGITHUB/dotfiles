local scroll = require("scroll")

local function on_create_ws(workspace, _)
  scroll.command(workspace, "set_mode center_horiz center_vert")
end

scroll.add_callback("workspace_create", on_create_ws, nil)