local Functions = {}
local HookedValues = {}

local function ProtectService(String: string)
	
	if cloneref then
		return cloneref(game:GetService(String))
	end
	return game:GetService(String)
	
end

local Players = ProtectService("Players") :: Players
local Workspace = ProtectService("Workspace") :: Workspace
local VirtualInputManager = ProtectService("VirtualInputManager") :: VirtualInputManager

local LocalPlayer = Players.LocalPlayer

local function Validate(Argument: any, Default: any)
	
	if not Argument then
		return Default
	end
	return Argument
	
end

function Functions:KeyPress(Key: Enum.KeyCode, WaitTime: number)
	
	local Key = Validate(Key,Enum.KeyCode.E) :: Enum.KeyCode
	local WaitTime = Validate(WaitTime,0) :: number
	
	VirtualInputManager:SendKeyEvent(true, Key, false, nil)
	task.wait(WaitTime)
	VirtualInputManager:SendKeyEvent(false, Key, false, nil)
	
end

function Functions:HookValue(Path: Instance, Property: string, HookValue: any)
	
	local Path = Validate(Path,LocalPlayer) :: Instance
	local Property = Validate(Property,"Parent") :: string
	local HookValue = Validate(HookValue,nil) :: any
	local Signal = nil :: RBXScriptConnection
	
	if Path:IsA("ValueBase") then
		Signal = Path.Changed:Connect(function()
			Path.Value = HookValue
		end)
	else
		Signal = Path:GetPropertyChangedSignal(Property):Connect(function()
			Path[Property] = HookValue
		end)
	end
	
	if not Signal then
		return
	end
	
	HookedValues[Path.Name..Property] = Signal
	
end

function Functions:StopHookValue(Path: Instance, Property: string)
	
	local Path = Validate(Path,LocalPlayer) :: string
	local Property = Validate(Property,"Parent") :: string
	
	for i, v in pairs(HookedValues) do -- just incase it's hooked 2 of the same value and property
		if i == Path.Name..Property then
			v:Disconnect()
			i = nil
		end
	end
	
end

function Functions:GetClosestPlayer(MaxAllowedDistance: number)
	
	local ClosestPlayer
	local MaxDistance = Validate(MaxAllowedDistance,math.huge or 9e9)
	
	local Character = LocalPlayer.Character :: Model
	
	if not Character then
		return
	end
	
	for i, v in ipairs(Players:GetPlayers()) do
		
		local TargetCharacter = v.Character :: Model
		
		if v == LocalPlayer or not TargetCharacter then
			continue
		end
		
		local TargetHRP = TargetCharacter:FindFirstChild("HumanoidRootPart") :: BasePart
		local LocalHRP = Character:FindFirstChild("HumanoidRootPart") :: BasePart
		
		if not TargetHRP then
			continue
		elseif not LocalHRP then
			return
		end
		
		local Magnitude = (LocalHRP.Position - TargetHRP.Position).Magnitude
		
		if Magnitude > MaxDistance then
			continue
		end
		
		MaxDistance = Magnitude
		ClosestPlayer = v
		
	end
	
	if not ClosestPlayer then
		return
	end
	
	return ClosestPlayer
	
end

return Functions

--[[

local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local ClosestPlayer = Functions:GetClosestPlayer()
if ClosestPlayer then
	print(ClosestPlayer.Name)
	local ClosestCharacter = ClosestPlayer.Character
end

local Character = LocalPlayer.Character

if not Character then
	return
end

local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
local ExampleTask = nil :: thread

Functions:HookValue(Humanoid,"Walkspeed",100)
ExampleTask = task.spawn(function()
	task.wait(120)
	Functions:StopHookValue(Humanoid,"Walkspeed")
	ExampleTask = nil
end)

local Keys = {
	"S",
	"O",
	"L",
	"A",
	"R",
	"Space", -- " "
	"H",
	"U",
	"B"
}

for i, v in ipairs(Keys) do
	Functions:KeyPress(Enum.KeyCode[v])
end

]]--
