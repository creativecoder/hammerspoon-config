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
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "up", function()
  local win = hs.window.focusedWindow()

  local screen = win:screen()
  local max = screen:frame()

  local f = win:frame()
  f.y = max.y
  win:setFrame(f)
end)

-- Move window to the bottom of the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "down", function()
  local win = hs.window.focusedWindow()

  local screen = win:screen()
  local max = screen:frame()

  local f = win:frame()
  f.y = max.y + max.h - f.h
  win:setFrame(f)
end)

-- Move window to the right side of the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "right", function()
  local win = hs.window.focusedWindow()

  local screen = win:screen()
  local max = screen:frame()

  local f = win:frame()
  f.x = max.x + max.w - f.w
  win:setFrame(f)
end)

-- Move window to the left side of the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "left", function()
  local win = hs.window.focusedWindow()

  local screen = win:screen()
  local max = screen:frame()

  local f = win:frame()
  f.x = max.x
  win:setFrame(f)
end)

--[[Window Resizing]]--
local windowPreviousFrames = {}

-- Center window
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "c", function()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local max = screen:frame()
  local f = win:frame()

  f.x = max.x + (max.w - f.w) / 2
  f.y = max.y + (max.h - f.h) / 2
  win:setFrame(f)
end)

-- Maximize window
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "m", function()
  local win = hs.window.focusedWindow()
  local currentFrame = win:frame()
  local screenFrame = win:screen():frame()

  if not currentFrame:equals(screenFrame) then
    windowPreviousFrames[win:id()] = currentFrame
    win:setFrame(screenFrame)
  end
end)

-- Restore window
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "return", function()
  local win = hs.window.focusedWindow()
  local prevFrame = windowPreviousFrames[win:id()]

  if prevFrame then
    win:setFrame(prevFrame)
    windowPreviousFrames[win:id()] = nil
  end
end)

-- Maximize window height
local function maximizeWindowHeight()
  local win = hs.window.focusedWindow()
  local currentFrame = win:frame()
  local screenFrame = win:screen():frame()

  if currentFrame.h == screenFrame.h then return end  -- Already max height

  local newFrame = hs.geometry.rect(
    currentFrame.x,        -- Keep horizontal position
    screenFrame.y,         -- Align to top of screen
    currentFrame.w,        -- Keep current width
    screenFrame.h          -- Set to full screen height
  )
  win:setFrameInScreenBounds(newFrame)
end
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "up", maximizeWindowHeight)

-- Half screen functions
local function windowRightHalf()

  local win = hs.window.focusedWindow()

  local f = win:frame()

  local max = win:screen():frame()
  f.x, f.y, f.w, f.h = max.x+max.w/2, max.y, max.w/2, max.h

  win:setFrame(f)

end
hs.hotkey.bind({"cmd","alt","ctrl"}, "3", windowRightHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "d", windowRightHalf)

local function windowLeftHalf()

  local win = hs.window.focusedWindow()

  local f = win:frame()

  local max = win:screen():frame()
  f.x, f.y, f.w, f.h = max.x, max.y, max.w/2, max.h

  win:setFrame(f)

end
hs.hotkey.bind({"cmd","alt","ctrl"}, "1", windowLeftHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "a", windowLeftHalf)

local function windowTopHalf()

  local win = hs.window.focusedWindow()

  local f = win:frame()

  local max = win:screen():frame()
  f.x, f.y, f.w, f.h = max.x, max.y, max.w, max.h/2

  win:setFrame(f)

end
hs.hotkey.bind({"cmd","alt","ctrl"}, "8", windowTopHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "w", windowTopHalf)

local function windowBottomHalf()

  local win = hs.window.focusedWindow()

  local f = win:frame()

  local max = win:screen():frame()
  f.x, f.y, f.w, f.h = max.x, max.y+max.h/2, max.w, max.h/2

  win:setFrame(f)

end
hs.hotkey.bind({"cmd","alt","ctrl"}, "2", windowBottomHalf)
hs.hotkey.bind({"cmd","alt","ctrl"}, "s", windowBottomHalf)

-- Two-thirds functions
local function windowLeftTwoThirds()

  local win = hs.window.focusedWindow()

  local f = win:frame()

  local max = win:screen():frame()
  f.x, f.y, f.w, f.h = max.x, max.y, max.w*2/3, max.h

  win:setFrame(f)

end
hs.hotkey.bind({"cmd","alt","ctrl"}, "7", windowLeftTwoThirds)
hs.hotkey.bind({"cmd","alt","ctrl"}, "q", windowLeftTwoThirds)

local function windowRightTwoThirds()

  local win = hs.window.focusedWindow()

  local f = win:frame()

  local max = win:screen():frame()
  f.x, f.y, f.w, f.h = max.x+max.w/3, max.y, max.w*2/3, max.h

  win:setFrame(f)

end
hs.hotkey.bind({"cmd","alt","ctrl"}, "9", windowRightTwoThirds)
hs.hotkey.bind({"cmd","alt","ctrl"}, "e", windowRightTwoThirds)

-- Resize functions
local function windowResizeStep(scale)

  local win = hs.window.focusedWindow()

  local frame = win:frame()
  local screen = win:screen()
  local max = screen:frame()
  local isMaximized = frame:equals(max)

  -- Check if window is already maximized
  if isMaximized and scale > 1 then
    return
  end

  -- Calculate new dimensions with constraints
  local newWidth = math.min(frame.w * scale, max.w)
  local newHeight = math.min(frame.h * scale, max.h)

  -- Check if any window edges are aligned at the edge of the screen
  local leftAligned, rightAligned, topAligned, bottomAligned = isWindowAtScreenEdges(frame, max)

  -- Adjust X position
  if leftAligned and not isMaximized then
    frame.x = max.x -- Stay on left edge
  elseif rightAligned and not isMaximized then
    frame.x = max.x + max.w - newWidth -- Stay on right edge
  else
    frame.x = frame.x + (frame.w - newWidth)/2  -- Center horizontally if no edge alignment
  end

  -- Adjust Y position
  if topAligned and not isMaximized then
    frame.y = max.y -- Stay on top edge
  elseif bottomAligned and not isMaximized then
    frame.y = max.y + max.h - newHeight -- Stay on bottom edge
  else
    frame.y = frame.y + (frame.h - newHeight)/2  -- Center vertically if no edge alignment
  end

  frame.w, frame.h = newWidth, newHeight
  win:setFrameInScreenBounds(frame)
end

hs.hotkey.bind({"cmd","alt","ctrl"}, "-", function() windowResizeStep(0.95) end)  -- Smaller
hs.hotkey.bind({"cmd","alt","ctrl"}, "=", function() windowResizeStep(1.05) end)  -- Bigger

--[[Window to Screen Movement]]--

local function moveWindowToScreen(direction)
  return function()
    local win = hs.window.focusedWindow()
    local currentScreen = win:screen()
    local newScreen = direction == "right" and currentScreen:next() or currentScreen:previous()

    if not newScreen then
      return
    end

    -- Move window to new screen, don't resize, and place in the same relative screen position

    local currentFrame = win:frame()
    local currentScreenFrame = currentScreen:frame()
    local newScreenFrame = newScreen:frame()
    local newX, newY, newW, newH

    -- Negative space around window before moving
    local oldAvailW = currentScreenFrame.w - currentFrame.w
    local oldAvailH = currentScreenFrame.h - currentFrame.h

    -- Horizontal positioning
    if oldAvailW <= 0 then
      newX = newScreenFrame.x + (newScreenFrame.w - currentFrame.w)/2  -- Center if window was at max width
    else
      local newAvailW = newScreenFrame.w - currentFrame.w
      local leftMargin = currentFrame.x - currentScreenFrame.x
      newX = newScreenFrame.x + (leftMargin/oldAvailW) * newAvailW -- Otherwise position window in the same relative position
    end

    newW = currentFrame.w

    -- Vertical positioning
    if oldAvailH <= 0 then
      newY = 0 -- Move to top if window was at max height
    else
      local newAvailH = newScreenFrame.h - currentFrame.h
      local topMargin = currentFrame.y - currentScreenFrame.y
      newY = newScreenFrame.y + (topMargin/oldAvailH) * newAvailH -- Otherwise position window in the same relative position
    end

    newH = currentFrame.h

    win:setFrameInScreenBounds(hs.geometry.rect(newX, newY, newW, newH))
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
    {"Finder", nil, macbookScreen, {x=0.10, y=0.2, h=0.6, w=0.8}, nil, nil}
  }

  hs.layout.apply(macbookScreenLayout)
end
hs.hotkey.bind({"cmd", "alt", "ctrl", "shift"}, "w", positionScreenWindows)
