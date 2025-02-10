local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local LIST_CURRENT = "aerospace list-workspaces --focused"
local LIST_MONITORS = "aerospace list-monitors --format '%{monitor-id}'"
local NO_MONITORS = "aerospace list-monitors --count"
local LIST_WORKSPACES = "aerospace list-workspaces --monitor %s"
local LIST_APPS = "aerospace list-windows --workspace %s --format '%%{app-name}'"

local spaces = {}
local cachedMonitors = nil
local numberOfMonitors = 0
local cachedFocusedWorkspace = nil

-- Fetch monitors and cache result
local function getMonitors()
    if not cachedMonitors then
        local handle = io.popen(LIST_MONITORS)
        local output = handle:read('*a')
        handle:close()
        cachedMonitors = {}
        for line in output:gmatch("[^\r\n]+") do
            table.insert(cachedMonitors, line)
        end
    end
    return cachedMonitors
end

local function getNumberOfMonitors()
  if numberOfMonitors == 0 then
    local handle = io.popen(NO_MONITORS)
    numberOfMonitors = handle:read('*a'):match("[^\r\n]+")
    handle:close()
  end

  return tonumber(numberOfMonitors)
end

-- Fetch current focused workspace and cache result
local function getFocusedWorkspace(force)
    if not cachedFocusedWorkspace or force then
        local handle = io.popen(LIST_CURRENT)
        cachedFocusedWorkspace = handle:read('*a'):match("[^\r\n]+")
        handle:close()
    end
    return cachedFocusedWorkspace
end

-- Get icon for an app with default fallback
local function getIconForApp(appName)
    return app_icons[appName] or app_icons["default"]
end

-- Update workspace icons dynamically
local function updateSpaceIcons(spaceId, workspaceName)
    local iconStrip = {}
    local shouldDraw = false

    sbar.exec(LIST_APPS:format(workspaceName), function(appsOutput)
        for app in appsOutput:gmatch("[^\r\n]+") do
            local appName = app:match("^%s*(.-)%s*$")
            if appName and appName ~= "" then
                table.insert(iconStrip, getIconForApp(appName))
                shouldDraw = true
            end
        end

        if #iconStrip == 0 then
            iconStrip = { "—" }
            shouldDraw = true
        end

        if spaces[spaceId] then
            spaces[spaceId].item:set({
                label = { string = table.concat(iconStrip, " "), drawing = shouldDraw }
            })
        else
            print("Warning: Space ID '" .. spaceId .. "' not found when updating icons.")
        end
    end)
end

-- Add a workspace item to the UI
local function addWorkspaceItem(workspaceName, monitorId, isSelected)
    local spaceId = "workspace_" .. workspaceName

    if getNumberOfMonitors() >= 3 then
      if monitorId == "1" then
        monitorId = "2"
      elseif monitorId == "2" then
        monitorId = "1"
      end
    end

    if not spaces[spaceId] then
        local spaceItem = sbar.add("item", spaceId, {
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
            background = {
                color = colors.bg1,
                border_width = 1,
                height = 26,
                border_color = colors.black,
            },
            display = monitorId,
        })

        spaces[spaceId] = { item = spaceItem }

        spaceItem:subscribe("mouse.clicked", function()
            sbar.exec("aerospace workspace " .. workspaceName)
        end)
    end

    spaces[spaceId].item:set({
        icon = { highlight = isSelected },
        label = { highlight = isSelected },
        background = { border_color = isSelected and colors.black or colors.bg2 }
    })

    updateSpaceIcons(spaceId, workspaceName)
end

-- Draw all spaces based on monitors and workspaces
local function drawSpaces()
    cachedMonitors = nil -- Refresh monitors
    cachedFocusedWorkspace = nil -- Refresh focused workspace

    local monitors = getMonitors()
    local focusedWorkspace = getFocusedWorkspace()

    for _, monitorId in ipairs(monitors) do
        sbar.exec(LIST_WORKSPACES:format(monitorId), function(workspacesOutput)
            for workspaceName in workspacesOutput:gmatch("[^\r\n]+") do
                local isSelected = workspaceName == focusedWorkspace
                addWorkspaceItem(workspaceName, monitorId, isSelected)
            end
        end)
    end
end

local lastFocusedWorkspace = nil

-- Update a single workspace's UI
local function updateWorkspace(workspaceName, isSelected)
    local spaceId = "workspace_" .. workspaceName

    if spaces[spaceId] then
        spaces[spaceId].item:set({
            icon = { highlight = isSelected },
            label = { highlight = isSelected },
            background = { border_color = isSelected and colors.black or colors.bg2 }
        })
        updateSpaceIcons(spaceId, workspaceName)
    end
end

-- Handle focus change efficiently
local function handleFocusChange()
    local newFocusedWorkspace = getFocusedWorkspace(true)
    
    if newFocusedWorkspace ~= lastFocusedWorkspace then
        -- Update the previously focused workspace to unselected
        if lastFocusedWorkspace then
            updateWorkspace(lastFocusedWorkspace, false)
        end

        -- Update the newly focused workspace to selected
        if newFocusedWorkspace then
            updateWorkspace(newFocusedWorkspace, true)
        end

        -- Update the cached focused workspace
        lastFocusedWorkspace = newFocusedWorkspace
    else
      local spaceId = "workspace_" .. newFocusedWorkspace

      updateSpaceIcons(spaceId, newFocusedWorkspace)
    end
end

drawSpaces()

local spaceObserver = sbar.add("item", { drawing = false, updates = true })

-- Subscribe to focus change and use the optimized handler
spaceObserver:subscribe("front_app_switched", handleFocusChange)
spaceObserver:subscribe("aerospace_workspace_change", handleFocusChange)
spaceObserver:subscribe("space_windows_change", handleFocusChange)
spaceObserver:subscribe("power_source_change", function()
    spaces = {}
    cachedMonitors = nil
    numberOfMonitors = 0
    cachedFocusedWorkspace = nil

    local sec = tonumber(os.clock() + 5);
      while (os.clock() < sec) do
    end

    drawSpaces()
end)