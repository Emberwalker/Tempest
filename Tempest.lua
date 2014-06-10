-----------------------------------------------------------------------------------------------
-- Client Lua Script for Tempest
-----------------------------------------------------------------------------------------------
 
require "Window"
require "ChatSystemLib"
 
-----------------------------------------------------------------------------------------------
-- Tempest Module Definition
-----------------------------------------------------------------------------------------------
local Tempest = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Tempest:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function Tempest:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Tempest OnLoad
-----------------------------------------------------------------------------------------------
function Tempest:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Debugger.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Tempest OnDocLoaded
-----------------------------------------------------------------------------------------------
function Tempest:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "Debug", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("tempest", "OnTempestOn", self)


		-- Do additional Addon initialization here
	end
end

-----------------------------------------------------------------------------------------------
-- Tempest Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/tempest"
function Tempest:OnTempestOn()
	self.wndMain:Invoke() -- show the window
end


-----------------------------------------------------------------------------------------------
-- TempestForm Functions
-----------------------------------------------------------------------------------------------
-- GetChannels() debug
function Tempest:OnDbg_GetChannels()
	self:Log(tostring(ChatSystemLib.GetChannels()))
	for k, v in ipairs(ChatSystemLib.GetChannels()) do
		self:Log("GetChannels(): " .. tostring(k) .. " : " .. tostring(v))
		self:LogTable(getmetatable(v))
	end
end

-- Evaluate code in the EvalText box.
function Tempest:OnDbg_Eval()
	if self.evalText == nil then
		local bg = self:FindInComponent(self.wndMain, "BG_EvalText")
		self.evalText = self:FindInComponent(bg, "EvalText")
	end
	
	local f, err = loadstring("return function (t) ".. self.evalText:GetText() .." end")
	if f == nil then
		self:Log("Function failed to compile. Aborting.")
		Print(err)
		return
	end
	
	local o = f()(self)
	if o == nil then
		self:Log("No output for compiled function.")
		return
	end
	self:Log("Got output: "..tostring(o))
end

function Tempest:OnDbg_Close()
	self.wndMain:Close()
end


-----------------------------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------------------------
-- Log to console
function Tempest:Log(sStr)
	ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_System, tostring(sStr), "Tempest")
end

-- Log a table to console
function Tempest:LogTable(tTab)
	if tTab == nil then return end
	
	for k, v in pairs(tTab) do
		self:Log(tostring(k).." : "..tostring(v))
	end
end

function Tempest:FindInComponent(wWind, sName)
	for k, v in pairs(wWind:GetChildren()) do
		if (v:GetName() == sName) then return v end
	end
	return nil
end


-----------------------------------------------------------------------------------------------
-- Tempest Instance
-----------------------------------------------------------------------------------------------
local TempestInst = Tempest:new()
TempestInst:Init()
