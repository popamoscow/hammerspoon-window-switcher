--[[
PAVEL'S WINDOW SWITCHER — standalone English edition

Author: Pavel Potasuev
Questions and contact: https://potasuev.ru

Too many windows from the same app? Cmd+Tab shows individual windows with
thumbnails when available, including windows on other Spaces. Choose with the
keyboard or mouse, then release Cmd to jump to your choice. Recent windows
come first, making two documents as easy to switch between as two apps.

Copy this file to ~/.hammerspoon/init.lua, or load it as a module and call start().
Accessibility permission is required. Thumbnails may need Screen Recording.
All user-facing settings are below. Change values, then Reload Config.
]]

local CONFIG = {
  -- Choose "default", "large", "wide", "one-row", "two-rows", or "compact".
  -- This selects a starting layout. Explicit values below override that preset.
  preset = "default",

  -- nil uses the preset (default: 300 points). Increase for larger cards and fewer
  -- columns; decrease for smaller cards and more columns. Cards can shrink to fit.
  cardWidth = nil,

  -- nil uses the preset (default: 0.62). Preview height / preview width.
  -- Increase for taller previews and fewer rows; decrease for wide, short previews.
  thumbnailAspect = nil,

  -- nil uses the preset (default: "auto"). "auto" fills a grid; "rows" uses rows;
  -- "columns" uses columns. Overflow goes to another page, not microscopic cards.
  layout = nil,

  -- nil uses the preset (default: 2); used only by layout="rows".
  -- Increase for more rows per page; decrease to 1 for a single horizontal row.
  -- Small screens may reduce the requested row count to keep cards readable.
  rows = nil,

  -- nil uses the preset (default: 4); used only by layout="columns".
  -- Increase for more, narrower columns; decrease for fewer, wider cards.
  columns = nil,

  -- Increase to use more screen width and fit more columns; decrease for a narrower
  -- centered panel. Fraction of screen width, 0.20 to 0.98.
  screenWidth = 0.86,

  -- Increase to use more screen height and fit more rows; decrease for a shorter
  -- panel. Fraction of screen height, 0.20 to 0.98.
  screenHeight = 0.80,

  -- Increase to keep overflow cards larger (more pages); decrease to fit smaller
  -- cards on small screens. Points; an extremely narrow screen overrides this floor.
  minimumCardWidth = 160,

  -- Increase for more space between cards and fewer cards per page; decrease
  -- for a tighter grid. Points, 0 or greater.
  cardGap = 16,

  -- Increase for a wider border of empty space around the grid; decrease for a
  -- tighter outer panel and more room for cards. Points, 0 or greater.
  panelPadding = 24,

  -- Increase for rounder outer-panel corners; decrease toward 0 for square corners.
  panelRadius = 22,

  -- Increase for rounder card corners; decrease toward 0 for square cards.
  cardRadius = 12,

  -- Increase for more space around preview images and less image area; decrease
  -- for larger images inside each card. Points, 0 or greater.
  imagePadding = 10,

  -- Increase for taller labels under previews (less space for previews); decrease
  -- for shorter labels. Minimum 36 points keeps both text lines readable.
  footerHeight = 44,

  -- Increase for larger application labels; decrease for smaller labels. Points.
  appTextSize = 12,

  -- Increase for larger window titles; decrease for smaller titles. Points.
  titleTextSize = 11,

  -- Increase for a larger application icon beside the labels; decrease for a
  -- smaller icon and more room for label text. Points.
  iconSize = 22,

  -- Increase for larger page-number text; decrease for smaller text. Points.
  pageTextSize = 11,

  -- Font name, not a number: choose an installed font. The system font is the default.
  font = ".AppleSystemUIFont",

  -- RGBA channels, each 0..1: raise R/G/B to add that color, lower to remove it.
  -- For grayscale, raise all RGB values to lighten, lower all to darken.
  -- Raise alpha (the 4th value) for more opacity; lower for more transparency.
  backdropColor = {0, 0, 0, 0.18}, -- Outside dimming: alpha up darkens, down reveals the desktop.
  panelColor = {0.13, 0.13, 0.15, 0.92}, -- Panel: RGB up lightens, down darkens; alpha up makes it more solid.
  panelBorderColor = {1, 1, 1, 0.10}, -- Panel outline: alpha up strengthens it, down softens it.
  cardColor = {1, 1, 1, 0.05}, -- Ordinary card: alpha up brightens this white overlay, down fades it.
  cardBorderColor = {1, 1, 1, 0.08}, -- Ordinary outline: alpha up strengthens it, down softens it.
  selectedCardColor = {1, 1, 1, 0.14}, -- Selected fill: alpha up emphasizes selection, down reduces it.
  selectedBorderColor = {1, 1, 1, 0.55}, -- Selected outline: alpha up strengthens selection, down softens it.
  appTextColor = {0.96, 0.96, 0.97, 1}, -- App label: RGB up lightens, down darkens; alpha down fades it.
  titleTextColor = {0.96, 0.96, 0.97, 0.55}, -- Window title and page number: alpha up brightens, down fades.

  -- Increase for a thicker outline on an ordinary card; decrease toward 0 to hide it.
  cardBorderWidth = 1,

  -- Increase for a stronger selected-card outline; decrease for a subtler outline.
  selectedBorderWidth = 2.5,

  -- true lists windows from other Spaces; false limits the list to this Space.
  -- Other Spaces use application icons instead of capturing their windows.
  includeOtherSpaces = true,

  -- true shows window previews when available; false uses application icons only.
  -- Turn off to avoid Screen Recording snapshots entirely.
  showThumbnails = true,

  -- "cmd" replaces Cmd+Tab; "alt" replaces Option+Tab instead. This is a choice,
  -- not a numeric scale. Using "alt" leaves the native Cmd+Tab shortcut available.
  triggerModifier = "cmd",

  -- true commits the choice when the trigger modifier is released; false leaves
  -- the panel open until Enter, a mouse click or Escape. No numeric increase/decrease.
  commitOnRelease = true,

  -- Modifier names for the separate sticky-panel shortcut. Change the combination,
  -- not its magnitude. Valid Hammerspoon names include "ctrl", "alt", "cmd", "shift".
  stickyModifiers = {"ctrl", "alt"},

  -- Key name for the sticky-panel shortcut. Choose a key, not a numeric value.
  stickyKey = "space",

  -- Increase for less accidental hover selection from hand jitter; decrease for
  -- faster mouse takeover. Pixels the mouse must move after the panel opens.
  mouseThreshold = 8,

  -- Increase to check modifier release less often (slower response, fewer checks);
  -- decrease for quicker response and more checks. Seconds; minimum 0.01.
  releasePoll = 0.02,

  -- Increase to keep thumbnails longer (older previews, fewer captures); decrease
  -- for fresher previews and more captures. Seconds; 0 captures again each opening.
  thumbnailCacheSeconds = 60,

  -- Increase for sharper cached images and more memory; decrease for softer images
  -- and less memory. Image pixels per logical display point, 1..3.
  thumbnailScale = 2,

  -- true captures one visible window periodically; false captures only on demand.
  -- This can add screen-capture work. It has no effect when showThumbnails=false.
  prewarmThumbnails = false,

  -- Increase for less frequent background captures; decrease for fresher previews
  -- and more background work. Seconds; minimum 5, used only when prewarming is on.
  prewarmInterval = 30,

  -- Increase to check disabled taps/stuck panels less often; decrease for quicker
  -- recovery and more checks. Seconds; minimum 0.5.
  watchdogInterval = 2,

  -- Increase to wait longer before closing a stuck held-modifier panel; decrease
  -- for faster recovery. Seconds; does not close intentionally sticky panels.
  stuckPanelSeconds = 4,
}

local PRESETS = {
  default = {cardWidth=300, thumbnailAspect=0.62, layout="auto", rows=2, columns=4},
  large = {cardWidth=420, thumbnailAspect=0.62, layout="auto", rows=2, columns=3},
  wide = {cardWidth=420, thumbnailAspect=0.40, layout="auto", rows=2, columns=3},
  ["one-row"] = {cardWidth=300, thumbnailAspect=0.62, layout="rows", rows=1, columns=4},
  ["two-rows"] = {cardWidth=300, thumbnailAspect=0.62, layout="rows", rows=2, columns=4},
  compact = {cardWidth=220, thumbnailAspect=0.55, layout="auto", rows=2, columns=5},
}

local preset = assert(PRESETS[CONFIG.preset], "Unknown Window Switcher preset")
for k,v in pairs(preset) do if CONFIG[k] == nil then CONFIG[k] = v end end
local function number(name, minimum, maximum, integer)
  local v = CONFIG[name]
  assert(type(v)=="number" and v==v and v~=math.huge and v~=-math.huge and
    v>=minimum and (not maximum or v<=maximum) and (not integer or v%1==0),
    "Invalid Window Switcher setting: "..name)
end
for _,k in ipairs({"cardWidth","minimumCardWidth"}) do number(k,80,1200) end
number("thumbnailAspect",0.15,2)
for _,k in ipairs({"rows","columns"}) do number(k,1,20,true) end
for _,k in ipairs({"screenWidth","screenHeight"}) do number(k,0.20,0.98) end
for _,k in ipairs({"cardGap","panelPadding","panelRadius","cardRadius","imagePadding"}) do number(k,0,80) end
number("footerHeight",36,120)
for _,k in ipairs({"appTextSize","titleTextSize","pageTextSize"}) do number(k,8,30) end
number("iconSize",8,48)
for _,k in ipairs({"cardBorderWidth","selectedBorderWidth"}) do number(k,0,10) end
number("mouseThreshold",0,100); number("releasePoll",0.01,1)
number("thumbnailCacheSeconds",0,3600); number("thumbnailScale",1,3)
number("prewarmInterval",5,600); number("watchdogInterval",0.5,30); number("stuckPanelSeconds",1,30)
assert(CONFIG.layout=="auto" or CONFIG.layout=="rows" or CONFIG.layout=="columns", "Invalid layout")
assert(CONFIG.triggerModifier=="cmd" or CONFIG.triggerModifier=="alt", "Invalid triggerModifier")
for _,k in ipairs({"includeOtherSpaces","showThumbnails","commitOnRelease","prewarmThumbnails"}) do
  assert(type(CONFIG[k])=="boolean","Invalid boolean setting: "..k)
end
assert(type(CONFIG.font)=="string" and #CONFIG.font>0,"Invalid font")
assert(type(CONFIG.stickyKey)=="string" and #CONFIG.stickyKey>0,"Invalid stickyKey")
assert(type(CONFIG.stickyModifiers)=="table","Invalid stickyModifiers")
for _,mod in ipairs(CONFIG.stickyModifiers) do
  assert(mod=="cmd" or mod=="ctrl" or mod=="alt" or mod=="shift" or mod=="fn","Invalid sticky modifier")
end
for _,k in ipairs({"backdropColor","panelColor","panelBorderColor","cardColor","cardBorderColor",
    "selectedCardColor","selectedBorderColor","appTextColor","titleTextColor"}) do
  assert(type(CONFIG[k])=="table" and #CONFIG[k]==4,"Expected RGBA color: "..k)
  for _,v in ipairs(CONFIG[k]) do assert(type(v)=="number" and v>=0 and v<=1,"Invalid RGBA channel: "..k) end
end

local M = {config=CONFIG, presets=PRESETS, running=false, jobs={}, cache={}, icons={}, recency={}, sequence=0}
local state = {visible=false, opening=false, selected=1, windows={}, canvas=nil,
  page=1, grid=nil, cardElements={}, mouseEngaged=false, generation=0, pendingSteps=0}
local KEY = {tab=48, escape=53, enter=36, space=49, left=123, right=124, up=126, down=125}
local filter = CONFIG.includeOtherSpaces and hs.window.filter.default or hs.window.filter.defaultCurrentSpace
local spaceFilter = hs.window.filter.defaultCurrentSpace
local fallbackImage = hs.image.imageFromName("NSStopProgressTemplate")
local render

local function color(k)
  local c=CONFIG[k]; return {red=c[1],green=c[2],blue=c[3],alpha=c[4]}
end

-- Pure geometry: screen fractions include the outer padding and page indicator.
-- Fixed rows/columns paginate when more cards exist than fit on the screen.
function M.layout(count, frame)
  count=math.max(1,count)
  local outer=math.min(CONFIG.panelPadding,frame.w*0.1,frame.h*0.1)
  local footer=math.max(CONFIG.footerHeight,(CONFIG.appTextSize+CONFIG.titleTextSize)*1.35+10,CONFIG.iconSize+12)
  local areaW=math.max(80,frame.w*CONFIG.screenWidth-2*outer)
  local areaH=math.max(footer+4,frame.h*CONFIG.screenHeight-2*outer-24)
  local gap=CONFIG.cardGap
  local pad=math.min(CONFIG.imagePadding,CONFIG.cardWidth/4)
  local function cardH(w) return math.max(1,w-2*math.min(pad,w/4))*CONFIG.thumbnailAspect+2*math.min(pad,w/4)+footer end
  local minW=math.min(CONFIG.minimumCardWidth,areaW)
  local width=math.min(CONFIG.cardWidth,areaW)
  local columns, rows
  if CONFIG.layout=="columns" then
    columns=math.min(count,CONFIG.columns,math.max(1,math.floor((areaW+gap)/(minW+gap))))
    width=math.min(width,(areaW-gap*(columns-1))/columns)
  else
    columns=math.min(count,math.max(1,math.floor((areaW+gap)/(width+gap))))
  end
  local height=cardH(width)
  local heightFloor=math.min(areaH,cardH(minW))
  if CONFIG.layout=="rows" then
    rows=math.min(CONFIG.rows,count,math.max(1,math.floor((areaH+gap)/(heightFloor+gap))))
    local limit=(areaH-gap*(rows-1))/rows
    if height>limit then
      width=math.min(width,math.max(1,(limit-footer-2*pad)/CONFIG.thumbnailAspect+2*pad))
      height=cardH(width)
      columns=math.min(count,math.max(1,math.floor((areaW+gap)/(width+gap))))
    end
  else
    if height>areaH then
      width=math.min(width,math.max(1,(areaH-footer-2*pad)/CONFIG.thumbnailAspect+2*pad))
      height=cardH(width)
    end
    rows=math.min(math.ceil(count/columns),math.max(1,math.floor((areaH+gap)/(height+gap))))
  end
  return {columns=columns,rows=rows,cardWidth=width,cardHeight=height,padding=pad,panelPadding=outer,footerHeight=footer,
    capacity=columns*rows,totalWidth=columns*width+(columns-1)*gap,
    totalHeight=rows*height+(rows-1)*gap}
end

local function defer(fn)
  local id={}; local generation=state.generation
  M.jobs[id]=hs.timer.doAfter(0,function()
    M.jobs[id]=nil
    if state.generation==generation then fn() end
  end)
end

local function touch(win)
  if win and win:id() then M.sequence=M.sequence+1; M.recency[win:id()]=M.sequence end
end

local function windows()
  local list={}
  for _,w in ipairs(filter:getWindows(hs.window.filter.sortByFocusedLast)) do
    local app=w:application()
    if w:id() and app and app:bundleID()~="org.hammerspoon.Hammerspoon" and w:isVisible() and w:isStandard() then
      list[#list+1]=w
    end
  end
  local order={}; for i,w in ipairs(list) do order[w:id()]=i end
  for id in pairs(M.cache) do if not order[id] then M.cache[id]=nil end end
  table.sort(list,function(a,b)
    local x,y=M.recency[a:id()] or 0,M.recency[b:id()] or 0
    return x==y and order[a:id()]<order[b:id()] or x>y
  end)
  return list
end

local function icon(w)
  local app=w and w:application(); local id=app and app:bundleID()
  if not id then return fallbackImage end
  if not M.icons[id] then M.icons[id]=hs.image.imageFromAppBundle(id) or fallbackImage end
  return M.icons[id]
end

local function capture(w)
  local shot=hs.window.snapshotForID(w:id())
  if not shot then return nil end
  local width=CONFIG.cardWidth-2*math.min(CONFIG.imagePadding,CONFIG.cardWidth/4)
  local small=shot:setSize({w=width*CONFIG.thumbnailScale,h=width*CONFIG.thumbnailAspect*CONFIG.thumbnailScale}) or shot
  M.cache[w:id()]={image=small,time=hs.timer.secondsSinceEpoch()}
  return small
end

local function thumbnail(w,here)
  if not CONFIG.showThumbnails or not here[w:id()] then return icon(w) end
  local cached=M.cache[w:id()]
  if cached and hs.timer.secondsSinceEpoch()-cached.time<CONFIG.thumbnailCacheSeconds then return cached.image end
  return capture(w) or icon(w)
end

local function stopReleaseTimer()
  if M.releaseTimer then M.releaseTimer:stop(); M.releaseTimer=nil end
end

function M.close()
  state.generation=state.generation+1
  for _,timer in pairs(M.jobs) do timer:stop() end
  M.jobs={}
  stopReleaseTimer()
  if state.canvas then state.canvas:delete(); state.canvas=nil end
  state.visible=false; state.opening=false; state.windows={}; state.grid=nil
  state.pendingSteps=0; state.mouseEngaged=false
end

function M.choose()
  local w=state.windows[state.selected]
  M.close()
  if not w or not w:id() then return end
  if w:isMinimized() then w:unminimize() end
  w:focus()
end

local function paintSelection()
  if not state.canvas then return end
  for i,element in pairs(state.cardElements) do
    local selected=i==state.selected
    state.canvas[element].fillColor=color(selected and "selectedCardColor" or "cardColor")
    state.canvas[element].strokeColor=color(selected and "selectedBorderColor" or "cardBorderColor")
    state.canvas[element].strokeWidth=selected and CONFIG.selectedBorderWidth or CONFIG.cardBorderWidth
  end
end

function M.select(index)
  if #state.windows==0 then return end
  state.selected=((index-1)%#state.windows)+1
  local page=math.floor((state.selected-1)/state.grid.capacity)+1
  if page~=state.page then render() else paintSelection() end
end

local function modifierHeld()
  return hs.eventtap.checkKeyboardModifiers()[CONFIG.triggerModifier]==true
end

local function watchRelease()
  stopReleaseTimer()
  if state.sticky or not CONFIG.commitOnRelease then return end
  M.releaseTimer=hs.timer.doEvery(CONFIG.releasePoll,function()
    if state.visible and not modifierHeld() then M.choose() end
  end)
end

local function keyboardMode()
  state.mouseEngaged=false; state.mouseOrigin=hs.mouse.absolutePosition()
end

local function mouse(_,message,element)
  if (message=="mouseMove" or message=="mouseEnter") and state.mouseOrigin and not state.mouseEngaged then
    local now=hs.mouse.absolutePosition()
    local dx,dy=now.x-state.mouseOrigin.x,now.y-state.mouseOrigin.y
    state.mouseEngaged=math.sqrt(dx*dx+dy*dy)>=CONFIG.mouseThreshold
  end
  local index=type(element)=="string" and tonumber(element:match("^card:(%d+)$")) or nil
  if message=="mouseEnter" and index and state.mouseEngaged then M.select(index) end
  if message=="mouseUp" then
    if index then state.selected=index; M.choose()
    elseif element=="backdrop" then M.close() end
  end
end

render=function()
  if state.canvas then state.canvas:delete() end
  local focused=hs.window.focusedWindow()
  local screen=(focused and focused:screen()) or hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
  local sf=screen:fullFrame()
  local grid=M.layout(#state.windows,sf); state.grid=grid
  state.page=math.floor((state.selected-1)/grid.capacity)+1
  local pages=math.ceil(#state.windows/grid.capacity)
  local startX=(sf.w-grid.totalWidth)/2; local startY=(sf.h-grid.totalHeight-24)/2
  local canvas=hs.canvas.new(sf)
  canvas:level("screenSaver"):behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
  canvas:clickActivating(false):canvasMouseEvents(true,true,true,true)
  canvas:appendElements({id="backdrop",type="rectangle",action="fill",fillColor=color("backdropColor"),
    frame={x=0,y=0,w=sf.w,h=sf.h},trackMouseUp=true,trackMouseMove=true})
  canvas:appendElements({type="rectangle",action="strokeAndFill",fillColor=color("panelColor"),
    strokeColor=color("panelBorderColor"),strokeWidth=1,
    roundedRectRadii={xRadius=CONFIG.panelRadius,yRadius=CONFIG.panelRadius},
    frame={x=startX-grid.panelPadding,y=startY-grid.panelPadding,
      w=grid.totalWidth+2*grid.panelPadding,h=grid.totalHeight+2*grid.panelPadding+24}})
  local here={}; for _,w in ipairs(spaceFilter:getWindows()) do here[w:id()]=true end
  state.cardElements={}
  local first=(state.page-1)*grid.capacity+1
  local last=math.min(#state.windows,first+grid.capacity-1)
  for i=first,last do
    local slot=i-first; local x=startX+(slot%grid.columns)*(grid.cardWidth+CONFIG.cardGap)
    local y=startY+math.floor(slot/grid.columns)*(grid.cardHeight+CONFIG.cardGap)
    local win=state.windows[i]
    canvas:appendElements({id="card:"..i,type="rectangle",action="strokeAndFill",fillColor=color("cardColor"),
      strokeColor=color("cardBorderColor"),strokeWidth=CONFIG.cardBorderWidth,
      roundedRectRadii={xRadius=CONFIG.cardRadius,yRadius=CONFIG.cardRadius},
      frame={x=x,y=y,w=grid.cardWidth,h=grid.cardHeight},trackMouseUp=true,trackMouseEnterExit=true})
    state.cardElements[i]=#canvas
    local p=math.min(grid.padding,grid.cardWidth/4)
    canvas:appendElements({type="image",image=thumbnail(win,here),imageScaling="scaleProportionally",imageAlignment="center",
      frame={x=x+p,y=y+p,w=grid.cardWidth-2*p,h=grid.cardHeight-grid.footerHeight-2*p}})
    local footerY=y+grid.cardHeight-grid.footerHeight
    local ico=math.min(CONFIG.iconSize,grid.footerHeight-12,grid.cardWidth/4)
    canvas:appendElements({type="image",image=icon(win),imageScaling="scaleProportionally",frame={x=x+p,y=footerY+6,w=ico,h=ico}})
    local textX=x+p+ico+8; local textW=math.max(1,grid.cardWidth-(textX-x)-p)
    canvas:appendElements({type="text",text=win:application():name(),textFont=CONFIG.font,textSize=CONFIG.appTextSize,
      textColor=color("appTextColor"),textLineBreak="truncateTail",frame={x=textX,y=footerY+3,w=textW,h=grid.footerHeight/2}})
    local title=(win:title() or ""):gsub("\n"," "); if title=="" then title="Untitled" end
    canvas:appendElements({type="text",text=title,textFont=CONFIG.font,textSize=CONFIG.titleTextSize,
      textColor=color("titleTextColor"),textLineBreak="truncateTail",frame={x=textX,y=footerY+grid.footerHeight/2,w=textW,h=grid.footerHeight/2}})
  end
  canvas:appendElements({type="text",text=pages>1 and ("Page "..state.page.." / "..pages) or "",
    textFont=CONFIG.font,textSize=CONFIG.pageTextSize,textColor=color("titleTextColor"),textAlignment="center",
    frame={x=startX,y=startY+grid.totalHeight+5,w=grid.totalWidth,h=18}})
  state.canvas=canvas
  paintSelection()
  canvas:mouseCallback(mouse):show()
end

function M.show(sticky)
  if state.visible then return end
  if not hs.accessibilityState(false) then hs.alert.show("Window Switcher needs Accessibility permission"); return end
  state.windows=windows()
  if #state.windows==0 then hs.alert.show("No windows to switch to"); return end
  state.visible=true; state.sticky=sticky~=false; state.selected=1
  keyboardMode(); render(); watchRelease()
end

function M.state()
  return {visible=state.visible,selected=state.selected,count=#state.windows,page=state.page,
    capacity=state.grid and state.grid.capacity or 0,rows=state.grid and state.grid.rows or 0,
    columns=state.grid and state.grid.columns or 0,opening=state.opening}
end

-- Optional: an image of the actual canvas; no Screen Recording capture is needed
-- for the canvas itself. Window thumbnails still follow showThumbnails.
function M.savePreview(path)
  if not state.canvas then return false end
  return state.canvas:imageFromCanvas():saveToFile(path)
end

local function onKey(event)
  local flags=event:getFlags(); local key=event:getKeyCode()
  local down=event:getType()==hs.eventtap.event.types.keyDown
  local trigger=key==KEY.tab and flags[CONFIG.triggerModifier] and not flags.ctrl
    and not flags[CONFIG.triggerModifier=="cmd" and "alt" or "cmd"]
  if trigger then
    if down then
      local delta=flags.shift and -1 or 1
      if state.visible then defer(function() M.select(state.selected+delta); keyboardMode() end)
      elseif state.opening then state.pendingSteps=state.pendingSteps+delta
      else
        state.opening=true; state.pendingSteps=0
        defer(function()
          state.opening=false; M.show(false)
          if not state.visible then state.pendingSteps=0; return end
          local start=1; local focused=hs.window.focusedWindow()
          if #state.windows>1 then
            if delta<0 then start=#state.windows
            elseif focused and state.windows[1]:id()==focused:id() then start=2 end
          end
          M.select(start+state.pendingSteps); state.pendingSteps=0
          if CONFIG.commitOnRelease and not modifierHeld() then M.choose() end
        end)
      end
    end
    return true
  end
  if not down or not (state.visible or state.opening) then return false end
  if key==KEY.escape then
    state.generation=state.generation+1
    defer(M.close); return true
  end
  if not state.visible then return false end
  if key==KEY.enter or key==KEY.space then defer(M.choose); return true end
  local delta=({[KEY.left]=-1,[KEY.right]=1,[KEY.up]=-state.grid.columns,[KEY.down]=state.grid.columns})[key]
  if delta then defer(function() M.select(state.selected+delta); keyboardMode() end); return true end
  return false
end

function M.start()
  if M.running then return M end
  if not hs.accessibilityState(false) then hs.alert.show("Enable Accessibility for Hammerspoon, then reload"); return M end
  local previous=rawget(_G,"PavelWindowSwitcher")
  if previous and previous~=M and type(previous.stop)=="function" then previous.stop() end
  M.running=true
  if not M.shutdownInstalled then
    local previousShutdown=hs.shutdownCallback
    hs.shutdownCallback=function()
      M.stop()
      if previousShutdown then previousShutdown() end
    end
    M.shutdownInstalled=true
  end
  local initial=hs.window.orderedWindows(); for i=#initial,1,-1 do touch(initial[i]) end
  filter:subscribe(hs.window.filter.windowFocused,touch)
  M.tap=hs.eventtap.new({hs.eventtap.event.types.keyDown,hs.eventtap.event.types.keyUp},onKey):start()
  M.hotkey=hs.hotkey.bind(CONFIG.stickyModifiers,CONFIG.stickyKey,function() defer(function() M.show(true) end) end)
  M.watchdog=hs.timer.doEvery(CONFIG.watchdogInterval,function()
    if not M.running then return end
    if not M.tap:isEnabled() then M.tap:start() end
    local stuck=state.visible and not state.sticky and CONFIG.commitOnRelease and not modifierHeld() and not M.releaseTimer
    if not stuck then M.stuckSince=nil
    elseif not M.stuckSince then M.stuckSince=hs.timer.secondsSinceEpoch()
    elseif hs.timer.secondsSinceEpoch()-M.stuckSince>=CONFIG.stuckPanelSeconds then M.close(); M.stuckSince=nil end
  end)
  if CONFIG.prewarmThumbnails and CONFIG.showThumbnails then
    local cursor=0
    M.prewarmer=hs.timer.doEvery(CONFIG.prewarmInterval,function()
      local list=spaceFilter:getWindows(hs.window.filter.sortByFocusedLast)
      if #list==0 then return end
      cursor=cursor%#list+1; local w=list[cursor]
      local cached=w:id() and M.cache[w:id()]
      if w:id() and w:isVisible() and w:isStandard() and (not cached or hs.timer.secondsSinceEpoch()-cached.time>=CONFIG.thumbnailCacheSeconds) then capture(w) end
    end)
  end
  -- One explicit namespace retains all taps/timers; the shared config is untouched.
  _G.PavelWindowSwitcher=M
  return M
end

function M.stop()
  M.running=false; M.close()
  if M.tap then M.tap:stop() end
  if M.hotkey then M.hotkey:delete(); M.hotkey=nil end
  if M.watchdog then M.watchdog:stop(); M.watchdog=nil end
  if M.prewarmer then M.prewarmer:stop(); M.prewarmer=nil end
  filter:unsubscribe(touch)
  return M
end

-- Running as init.lua starts immediately. Loading as a named module lets the caller
-- inspect or configure it before calling start(); show(true) only opens a sticky panel.
local moduleName=...
if moduleName==nil then M.start() end
return M
