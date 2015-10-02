local http = require("socket.http")

function pasteGet(pasteID)
  local ret, status = http.request("http://pastebin.com/raw.php?i=" .. pasteID)
  if status == 200 then
    return ret
  else
    return false
  end
end

function command_pasteget(Split, Player)
  LOG(("Player %s called pasteget!"):format(Player:GetName()))
  if #Split < 2 then
    Player:SendMessage("Usage: /pasteGet [pastebin ID] [lenght]")
    return true
  end

  local pasteID = Split[2]

  local lenght = tonumber(Split[3])

  local paste = pasteGet(pasteID)
  if not paste then
    Player:SendMessage("Can't contact Pastebin Server!")
    return true
  end

  if lenght then
    Player:SendMessage(paste:gsub("\r", ""))
  else
    Player:SendMessage(paste:gsub("\r", ""):sub(1, lenght))
  end

  return true
end



function rightClickHandler(Player, ...)
  Player.settings = Player.settings or {}
  Player.settings.last_right = {...}
end

function OnUpdatedSign(World, BlockX, BlockY, BlockZ, Line1, Line2, Line3, Line4, Player)
  LOG("LEL1:" .. tostring(Line1))
  LOG("LEL2:" .. tostring(Line2))
  LOG("LEL3:" .. tostring(Line3))
  LOG("LEL4:" .. tostring(Line4))
end

function testCallback(Split, Player)
  local oldtime = os.time()
  local counter = 1
  while true do
    if os.time() ~= oldtime then
      oldtime = os.time()
      Player:SendMessage("Lel, counter: " .. counter)
      if counter >= 5 then
        break
      end
      counter = counter + 1
    end
  end

  Player:SendMessage("Lel, counter: " .. os.time())
  return true
end



function mapCallback(Map)
  LOG("Center X: " .. Map:GetCenterX())
  LOG("Center Z: " .. Map:GetCenterZ())

  LOG("Height:   " .. Map:GetHeight())
  LOG("Width:    " .. Map:GetWidth())


  Map:SetScale(10)

  for x=0, 127 do
    for y=0, 127 do
      Map:SetPixel(x,y,16)
    end
  end

end



function command_display(Split, Player)

  local item = Player:GetInventory():GetHotbarSlot(Player:GetInventory():GetEquippedSlotNum())

  if Split[2] == "own" then
    -- Take ownership of a map, add it to players map list
    if item.m_ItemType == 358 then
      local mapID = item.m_ItemDamage
      local mapManager = Player:GetWorld():GetMapManager()
      mapManager:DoWithMap(mapID, function(Map)
        Player.settings = Player.settings or {}
        Player.settings.maps = Player.settings.maps or {}
        Player.settings.maps[mapID] = Map
        Player:SendMessage("You now own Map #" .. mapID)
      end)
    else
      Player:SendMessage("You must hold a map in your hand!")
    end
  elseif Split[2] == "list" then
    Player:SendMessage("Currently owned maps:")
    for id,map in pairs(Player.settings.maps) do
      Player:SendMessage("  " .. id)
    end
  elseif Split[2] == "testpattern" then
    Player:SendMessage("Putting test patterns on all your owned maps...")
    for id,map in pairs(Player.settings.maps) do

      map:SetPosition(-100000, -100000)

      for x=0, 127 do
        for y=0, 127 do
          map:SetPixel(x,y,cMap.E_BASE_COLOR_BROWN)
        end
      end

    end
  else
    Player:SendMessage("Unknown command!")
  end

  return true

end


local colors = {
  BLUE = 48,
  BROWN = 40,
  DARK_BROWN = 52,
  DARK_GRAY = 44,
  DARK_GREEN = 28,
  GRAY_1 = 12,
  GRAY_2 = 24,
  LIGHT_BLUE = 5,
  LIGHT_BROWN = 8,
  LIGHT_GRAY = 36,
  LIGHT_GREEN = 4,
  PALE_BLUE = 20,
  RED = 16,
  TRANSPARENT = 0,
  WHITE = 32
}




function Initialize(Plugin)
	Plugin:SetName("rightFICK")
	Plugin:SetVersion(1)

	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, rightClickHandler);
  cPluginManager:AddHook(cPluginManager.HOOK_UPDATED_SIGN, OnUpdatedSign);

  cPluginManager.BindCommand("/test", nil, testCallback, " - Test Function, varies")
  cPluginManager.BindCommand("/pasteget", nil, command_pasteget, " - Gets text from pastebin")

  cPluginManager.BindCommand("/display", nil, command_display, " - lel fgt")

	LOG("Initialized " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())

	return true
end
