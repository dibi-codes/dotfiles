local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local LIST_ALL = "aerospace list-workspaces --all"
local LIST_CURRENT = "aerospace list-workspaces --focused" -- 0,5s
local LIST_MONITORS = "aerospace list-monitors | awk '{print $1}'"
local LIST_WORKSPACES = "aerospace list-workspaces --monitor %s"
local LIST_APPS = "aerospace list-windows --workspace %s | awk -F'|' '{gsub(/^ *| *$/, \"\", $2); print $2}'" -- 0,5s

local spaces = {}

local function getIconForApp(appName)
    return app_icons[appName] or app_icons["default"]
end

local function getMonitors()
  local handle = io.popen(LIST_MONITORS)
  -- reads command output.
  local output = handle:read('*a')
  handle:close()
  -- replaces any newline with a space
  return output:gmatch("[^\r\n]+")
end

local function numberOfMonitors()
  local monitors = getMonitors()

  local count = 0
  for _ in monitors do
      count = count + 1
  end
  return count
end

local function updateSpaceIcons(spaceId, workspaceName)
    local icon_strip = ""
    local shouldDraw = false

    sbar.exec(LIST_APPS:format(workspaceName), function(appsOutput)
        local appFound = false

        for app in appsOutput:gmatch("[^\r\n]+") do
            local appName = app:match("^%s*(.-)%s*$")  -- Trim whitespace
            if appName and appName ~= "" then
                icon_strip = icon_strip .. " " .. getIconForApp(appName)
                appFound = true
                shouldDraw = true
            end
        end

        if not appFound then
            icon_strip = " —"
            shouldDraw = true
        end

        if spaces[spaceId] then
            spaces[spaceId].item:set({
                label = { string = icon_strip, drawing = shouldDraw}
            })
        else
            print("Warning: Space ID '" .. spaceId .. "' not found when updating icons.")
        end
    end)
end


local function addWorkspaceItem(workspaceName, monitorId, isSelected)
    local spaceId = "workspace_" .. workspaceName

    if numberOfMonitors() >= 3 then
      if monitorId == "1" then
        monitorId = "2"
      elseif monitorId == "2" then
        monitorId = "1"
      end
    end

    if not spaces[spaceId] then
      local space_item = sbar.add("item", spaceId, {
            icon = {
              font = { family = settings.font.numbers },
              string = workspaceName,
              padding_left = 15,
              padding_right = 8,
              color = colors.white,
              highlight_color = colors.red,
            },
            label = {
              padding_right = 20,
              color = colors.grey,
              highlight_color = colors.white,
              font = "sketchybar-app-font:Regular:16.0",
              y_offset = -1,
            },
            padding_right = 1,
            padding_left = 1,
            background = {
              color = colors.bg1,
              border_width = 1,
              height = 26,
              border_color = colors.black,
            },
            display = monitorId,
            popup = { background = { border_width = 5, border_color = colors.black } }
        })

        -- Create bracket for double border effect
        local space_bracket = sbar.add("bracket", { spaceId }, {
          background = {
            color = colors.transparent,
            border_color = colors.bg2,
            height = 28,
            border_width = 2
          }
        })

        -- Padding space
        sbar.add("space", "space.padding." .. workspaceName, {
          space = spaceId,
          script = "",
          width = settings.group_paddings,
        })

        -- Subscribe to mouse events for changing workspace
        space_item:subscribe("mouse.clicked", function()
            sbar.exec("aerospace workspace " .. workspaceName)
        end)

        -- Store both the item and its bracket in the spaces table
        spaces[spaceId] = { item = space_item, bracket = space_bracket }
    end

    spaces[spaceId].item:set({
        icon = { highlight = isSelected },
        label = { highlight = isSelected },
        background = { border_color = isSelected and colors.black or colors.bg2 }
    })

    spaces[spaceId].bracket:set({
        background = { border_color = isSelected and colors.grey or colors.bg2 }
    })

    updateSpaceIcons(spaceId, workspaceName)
end

local function listWorkspacesForMonitor(monitorId, callback)
  sbar.exec(LIST_WORKSPACES:format(monitorId), function(workspacesOutput)
    callback(workspacesOutput:gmatch("[^\r\n]+"))
  end)
end

local function drawSpaces()
  local monitors = getMonitors()
    -- Cache the focused workspace to avoid multiple `LIST_CURRENT` queries
  sbar.exec(LIST_CURRENT, function(focusedWorkspaceOutput)
      local focusedWorkspace = focusedWorkspaceOutput:match("[^\r\n]+")
      -- Iterate through monitors and workspaces
      for monitorId in monitors do
        listWorkspacesForMonitor(monitorId, function(workspace)
          for workspaceName in workspace do
            local isSelected = workspaceName == focusedWorkspace
            addWorkspaceItem(workspaceName, monitorId, isSelected)
          end
        end)
      end
  end)
end

drawSpaces()

local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true,
})

space_window_observer:subscribe("aerospace_workspace_change", function(env)
  drawSpaces()
  -- for t in env do
  --   print(t)
  -- end
end)
  
  -- space_window_observer:subscribe("display_change", function(env)
  --     print(env.INFO)
  -- end)
  
space_window_observer:subscribe("front_app_switched", function()
  drawSpaces()
end)

space_window_observer:subscribe("space_windows_change", function()
    drawSpaces()
end)



--[[
-- Indicator for swapping menus and spaces
local spaces_indicator = sbar.add("item", {
    padding_left = -3,
    padding_right = 3,
    icon = {
        padding_left = 8,
        padding_right = 9,
        color = colors.grey,
        string = icons.switch.on,
    },
    label = {
        width = 0,
        padding_left = 0,
        padding_right = 8,
        string = "Spaces",
        color = colors.bg1,
    },
    background = {
        color = colors.with_alpha(colors.grey, 0.0),
        border_color = colors.with_alpha(colors.bg1, 0.0),
    }
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
        icon = currently_on and icons.switch.off or icons.switch.on
    })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 1.0 },
                border_color = { alpha = 0.5 },
            },
            icon = { color = colors.bg1 },
            label = { width = "dynamic" }
        })
    end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 0.0 },
                border_color = { alpha = 0.0 },
            },
            icon = { color = colors.grey },
            label = { width = 0, }
        })
    end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
end)
]]--