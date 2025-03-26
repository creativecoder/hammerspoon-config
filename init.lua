-- Hammerspoon configuration
-- https://www.hammerspoon.org/docs/index.html

--[[
-- Hotfix for `AXEnhancedUserInterface` issue
-- https://github.com/Hammerspoon/hammerspoon/issues/3224
]]--

local function axHotfix(win)
    if not win then win = hs.window.frontmostWindow() end

    local axApp = hs.axuielement.applicationElement(win:application())
    local wasEnhanced = axApp.AXEnhancedUserInterface
    axApp.AXEnhancedUserInterface = false

    return function()
        hs.timer.doAfter(hs.window.animationDuration * 2, function()
            axApp.AXEnhancedUserInterface = wasEnhanced
        end)
    end
end

local function withAxHotfix(fn, position)
    if not position then position = 1 end
    return function(...)
        local revert = axHotfix(select(position, ...))
        fn(...)
        revert()
    end
end

local windowMT = hs.getObjectMetatable("hs.window")
windowMT._setFrameInScreenBounds = windowMT._setFrameInScreenBounds or windowMT.setFrameInScreenBounds -- Keep the original, if needed
windowMT.setFrameInScreenBounds = withAxHotfix(windowMT.setFrameInScreenBounds)

--[[Functions]]--

local function isWindowAtScreenEdges(window, screen)
  local tolerance = 2

-- Check edge alignment with tolerance
  local leftAligned = math.abs(window.x - screen.x) < tolerance
  local rightAligned = math.abs((window.x + window.w) - (screen.x + screen.w)) < tolerance
  local topAligned = math.abs(window.y - screen.y) < tolerance
  local bottomAligned = math.abs((window.y + window.h) - (screen.y + screen.h)) < tolerance

  return leftAligned, rightAligned, topAligned, bottomAligned
end

--[[Window Movement]]--

-- Move window to the top of the screen
local function moveWindowToTop()
  local window = hs.window.focusedWindow()
  if not window then return end

  local screenFrame = window:screen():frame()
  local winFrame = window:frame()

  winFrame.y = screenFrame.y
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "up", moveWindowToTop)

-- Move window to the bottom of the screen
local function moveWindowToBottom()
  local window = hs.window.focusedWindow()
  if not window then return end

  local screenFrame = window:screen():frame()
  local winFrame = window:frame()

  winFrame.y = screenFrame.y + screenFrame.h - winFrame.h
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "down", moveWindowToBottom)

-- Move window to the right side of the screen
local function moveWindowToRight()
  local window = hs.window.focusedWindow()
  if not window then return end

  local screenFrame = window:screen():frame()
  local winFrame = window:frame()

  winFrame.x = screenFrame.x + screenFrame.w - winFrame.w
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "right", moveWindowToRight)

-- Move window to the left side of the screen
local function moveWindowToLeft()
  local window = hs.window.focusedWindow()
  if not window then return end

  local screenFrame = window:screen():frame()
  local winFrame = window:frame()

  winFrame.x = screenFrame.x
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "left", moveWindowToLeft)

--[[Window Resizing]]--
local windowPreviousFrames = {}

-- Center window
local function windowToCenter()
  local window = hs.window.focusedWindow()
  if not window then return end

  local screenFrame = window:screen():frame()
  local winFrame = window:frame()

  winFrame.x = screenFrame.x + (screenFrame.w - winFrame.w) / 2
  winFrame.y = screenFrame.y + (screenFrame.h - winFrame.h) / 2
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", windowToCenter)

-- Maximize window
local function windowMaximize()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  -- Window already maximized
  if winFrame:equals(screenFrame) then return end

  windowPreviousFrames[window:id()] = winFrame
  window:setFrame(screenFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "m", windowMaximize)

-- Restore window
local function windowRestorePreviousSize()
  local window = hs.window.focusedWindow()
  if not window then return end

  local prevFrame = windowPreviousFrames[window:id()]

  if prevFrame then
    window:setFrame(prevFrame)
    windowPreviousFrames[window:id()] = nil
  end
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "return", windowRestorePreviousSize)

-- Maximize window height
local function maximizeWindowHeight()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  if winFrame.h == screenFrame.h then return end -- Already max height

  local newFrame = hs.geometry.rect(
    winFrame.x, -- Keep horizontal position
    screenFrame.y,  -- Align to top of screen
    winFrame.w, -- Keep current width
    screenFrame.h   -- Set to full screen height
  )
  window:setFrameInScreenBounds(newFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "up", maximizeWindowHeight)

-- Half screen functions
local function windowRightHalf()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  winFrame.x, winFrame.y, winFrame.w, winFrame.h = screenFrame.x + screenFrame.w / 2, screenFrame.y, screenFrame.w / 2, screenFrame.h
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd","alt","ctrl"}, "3", windowRightHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "d", windowRightHalf)

local function windowLeftHalf()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  winFrame.x, winFrame.y, winFrame.w, winFrame.h = screenFrame.x, screenFrame.y, screenFrame.w / 2, screenFrame.h
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd","alt","ctrl"}, "1", windowLeftHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "a", windowLeftHalf)

local function windowTopHalf()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  winFrame.x, winFrame.y, winFrame.w, winFrame.h = screenFrame.x, screenFrame.y, screenFrame.w, screenFrame.h / 2
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd","alt","ctrl"}, "8", windowTopHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "w", windowTopHalf)

local function windowBottomHalf()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  winFrame.x, winFrame.y, winFrame.w, winFrame.h = screenFrame.x, screenFrame.y + screenFrame.h / 2, screenFrame.w, screenFrame.h / 2
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd","alt","ctrl"}, "2", windowBottomHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "s", windowBottomHalf)

-- Two-thirds functions
local function windowLeftTwoThirds()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  winFrame.x, winFrame.y, winFrame.w, winFrame.h = screenFrame.x, screenFrame.y, screenFrame.w*2 / 3, screenFrame.h
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd","alt","ctrl"}, "7", windowLeftTwoThirds)
hs.hotkey.bind({"cmd","alt","ctrl"}, "q", windowLeftTwoThirds)

local function windowRightTwoThirds()
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()

  winFrame.x, winFrame.y, winFrame.w, winFrame.h = screenFrame.x + screenFrame.w / 3, screenFrame.y, screenFrame.w*2 / 3, screenFrame.h
  window:setFrame(winFrame)
end
hs.hotkey.bind({"cmd","alt","ctrl"}, "9", windowRightTwoThirds)
hs.hotkey.bind({"cmd","alt","ctrl"}, "e", windowRightTwoThirds)

-- Resize functions
local function windowResizeStep(scale)
  local window = hs.window.focusedWindow()
  if not window then return end

  local winFrame = window:frame()
  local screenFrame = window:screen():frame()
  local isMaximized = winFrame:equals(screenFrame)

  -- Check if window is already maximized
  if isMaximized and scale > 1 then return end

  -- Calculate new dimensions with constraints
  local newWidth = math.min(winFrame.w * scale, screenFrame.w)
  local newHeight = math.min(winFrame.h * scale, screenFrame.h)

  -- Check if any window edges are aligned at the edge of the screen
  local leftAligned, rightAligned, topAligned, bottomAligned = isWindowAtScreenEdges(winFrame, screenFrame)

  -- Adjust X position
  if leftAligned and not isMaximized then
    winFrame.x = screenFrame.x -- Stay on left edge
  elseif rightAligned and not isMaximized then
    winFrame.x = screenFrame.x + screenFrame.w - newWidth -- Stay on right edge
  else
    winFrame.x = winFrame.x + (winFrame.w - newWidth)/2  -- Center horizontally if no edge alignment
  end

  -- Adjust Y position
  if topAligned and not isMaximized then
    winFrame.y = screenFrame.y -- Stay on top edge
  elseif bottomAligned and not isMaximized then
    winFrame.y = screenFrame.y + screenFrame.h - newHeight -- Stay on bottom edge
  else
    winFrame.y = winFrame.y + (winFrame.h - newHeight)/2  -- Center vertically if no edge alignment
  end

  winFrame.w, winFrame.h = newWidth, newHeight
  window:setFrameInScreenBounds(winFrame)
end
hs.hotkey.bind({"cmd","alt","ctrl"}, "-", function() windowResizeStep(0.95) end)  -- Smaller
hs.hotkey.bind({"cmd","alt","ctrl"}, "=", function() windowResizeStep(1.05) end)  -- Bigger

--[[Window to Screen Movement]]--

local function moveWindowToScreen(direction)
  return function()
    local window = hs.window.focusedWindow()
    if not window then return end

    -- Move window to new screen, only resize if needed, and place in the same relative screen position

    local screen = window:screen()
    local winFrame = window:frame()
    local screenFrame = screen:frame()
    local newScreen = direction == "right" and screen:next() or screen:previous()
    local newScreenFrame = newScreen:frame()
    local newX, newY, newW, newH

    -- Simulate centering the new screen inside the current one, then check the window position
    -- If the window is effectively inside the new screen, move it to the same position on the new screen
    -- Otherwise calculate the same relative window position on the new screen
    -- local newScreenBoundX = (screenFrame.w - newScreenFrame.w)/2 + screenFrame.x
    -- local newScreenBoundY = (screenFrame.h - newScreenFrame.h)/2 + screenFrame.y
    -- local windowWidthInScreenBounds = winFrame.x > newScreenBoundX and winFrame.w < newScreenFrame.w
    -- local windowHeightInScreenBounds = winFrame.y > newScreenBoundY and winFrame.h < newScreenFrame.h

    -- Horizontal positioning
    if winFrame.w > newScreenFrame.w then
      -- Maximize window width if larger than new screen
      newX = newScreenFrame.x
      newW = newScreenFrame.w
    elseif winFrame.w >= (screenFrame.w - 2) then
      -- Center on new screen if window is at or near max width
      newX = newScreenFrame.x + (newScreenFrame.w - winFrame.w)/2
      newW = winFrame.w
    -- elseif not windowWidthInScreenBounds then
    --   -- Clamp new window position to nearest screen edge
    --   if winFrame.x > newScreenBoundX then
    --     newX = (newScreenFrame.x + newScreenFrame.w) - winFrame.w
    --   else
    --     newX = newScreenFrame.x
    --   end
    --   newW = winFrame.w
    else
      -- Place window in the same relative position on the new screen
      local prevAvailableWidth = screenFrame.w - winFrame.w
      local newAvailableWidth = newScreenFrame.w - winFrame.w
      local leftMargin = winFrame.x - screenFrame.x
      newX = newScreenFrame.x + (leftMargin/prevAvailableWidth) * newAvailableWidth
      newW = winFrame.w
    end

    -- Vertical positioning
    if winFrame.h > newScreenFrame.h then
      -- Maximize on new screen if window is larger than new screen
      newY = newScreenFrame.y
      newH = newScreenFrame.h
    elseif winFrame.h >= (screenFrame.h - 2) then
      -- Move to top if window is at or near max height
      newY = newScreenFrame.y
      newH = winFrame.h
    -- elseif not windowHeightInScreenBounds then
    --   -- Clamp new window position to nearest edge
    --   if winFrame.y > newScreenBoundY then
    --     newY = (newScreenFrame.y + newScreenFrame.h) - winFrame.h
    --   else
    --     newY = newScreenFrame.y
    --   end
    --   newH = winFrame.h
    else
      -- Place window in the same relative position on the new screen
      local prevAvailableHeight = screenFrame.h - winFrame.h
      local newAvailableHeight = newScreenFrame.h - winFrame.h
      local topMargin = winFrame.y - screenFrame.y
      newY = newScreenFrame.y + (topMargin/prevAvailableHeight) * newAvailableHeight
      newH = winFrame.h
    end

    window:setFrameInScreenBounds(hs.geometry.rect(newX, newY, newW, newH))
  end
end
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "right", moveWindowToScreen("right"))
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "left", moveWindowToScreen("left"))

--[[Remember Window Positions]]--

local function positionScreenWindows()
  local macbookScreen = hs.screen'Built%-in'

  if not macbookScreen then
    return
  end

  local macbookScreenLayout = {
    {"Ghostty", nil, macbookScreen, hs.layout.maximized, nil, nil},
    {"Obsidian", nil, macbookScreen, hs.layout.maximized, nil, nil},
    {"Reminders", nil, macbookScreen, {x=0.34, y=0, w=0.66, h=1}, nil, nil},
    {"Finder", nil, macbookScreen, {x=0.10, y=0.2, h=0.6, w=0.8}, nil, nil},
    {"Slack", nil, macbookScreen, {x=0, y=0, h=1, w=0.95}, nil, nil},
  }

  hs.layout.apply(macbookScreenLayout)
end
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "w", positionScreenWindows)
