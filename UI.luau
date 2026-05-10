local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

-- // @Performance
local type, typeof, pcall =
    type, typeof, pcall

local math_random, math_clamp, math_huge = 
    math.random, math.clamp, math.huge

local string_byte, string_char, string_find, string_format, string_lower, string_sub = 
    string.byte, string.char, string.find, string.format, string.lower, string.sub

local table_clear, table_insert = 
    table.clear, table.insert

local task_wait, task_spawn = 
    task.wait, task.spawn

local ipairs, pairs, next, tostring = 
    ipairs, pairs, next, tostring

local Color3_fromRGB, Color3_fromHSV = 
    Color3.fromRGB, Color3.fromHSV

local Instance_new = Instance.new
local Vector2_new = Vector2.new
local UDim_new = UDim.new
local UDim2_new = UDim2.new

local Enum_TextXAlignment_Left = Enum.TextXAlignment.Left
local Enum_TextYAlignment_Top = Enum.TextYAlignment.Top
local Enum_HorizontalAlignment_Center = Enum.HorizontalAlignment.Center
local Enum_SortOrder_LayoutOrder = Enum.SortOrder.LayoutOrder
local Enum_KeyCode = Enum.KeyCode

-- // @Services
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local HttpService: HttpService = cloneref(game:GetService("HttpService"))

local Players: Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Workspace = game:GetService('Workspace')

local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local FontFace = Enum.Font.Gotham

-- // @Modules
local Library, Commands = {}, {}
local isfolder, isfile, listfiles, makefolder = isfolder, isfile, listfiles, makefolder
Library.CommandModuleData = Library.CommandModuleData or "Command Module Library.cfg"

local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

if typeof(clonefunction) == "function" then
    local isfolder_dummy, isfile_dummy, listfiles_dummy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_dummy(tostring(math_random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(Folder)
            local Success, Data = pcall(isfolder_dummy, Folder)
            return Success and Data or false
        end

        isfile = function(File)
            local Success, Data = pcall(isfile_dummy, File)
            return Success and Data or false
        end

        listfiles = function(Folder)
            local Success, Data = pcall(listfiles_dummy, Folder)
            return Success and Data or {}
        end
    end
end

local function CreateFolder(FolderPath)
    if makefolder then
        pcall(function()
            makefolder(FolderPath)
        end)
    end
end

local function EnsurePath(FilePath)
    local Parts = {}
    for part in FilePath:gmatch("[^\\/]+") do
        table_insert(Parts, part)
    end
    
    if #Parts > 1 then
        local CurrentPath = ""
        for i = 1, #Parts - 1 do
            CurrentPath = CurrentPath .. Parts[i] .. "/"
            if isfolder and not isfolder(CurrentPath) then
                CreateFolder(CurrentPath)
            end
        end
    end
end

local function LoadConfig(Configuration)
    if readfile and Configuration then
        local Success, Data = pcall(function()
            return HttpService:JSONDecode(readfile(Configuration))
        end)
        
        if Success and Data then
            return Data
        end
    end
    return nil
end

local function SaveConfig(Configuration, Setting)
    if writefile and Configuration then
        EnsurePath(Configuration)
        local Success, Error = pcall(function()
            writefile(Configuration, HttpService:JSONEncode(Setting))
        end)
    end
end

local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math_huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

-- // @Library Functions
do
	function Library:RandomString(Length)
		local Length = Length or 15
		local Characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
		local RandomString = ""
		
		for i = 1, Length do
			local RandomIndex = math_random(1, #Characters)
			RandomString = RandomString .. string_sub(Characters, RandomIndex, RandomIndex)
		end
		
		return RandomString
	end

	function Library:HasProperty(Instance, Property)
		local Success = pcall(function()
			return Instance[Property]
		end)

		return Success and not Instance:FindFirstChild(Property)
	end

	function Library:Tween(Instance, Properties, Duration, ...)
		local TweenInfo = TweenInfo.new(Duration, ...)
		TweenService:Create(Instance, TweenInfo, Properties):Play()
	end

	function Library:Create(InstanceName, Properties, Children)
		local Object = Instance_new(InstanceName)
		local Properties = Properties or {}
		local Children = Children or {}

		for Index, Property in next, Properties do
			Object[Index] = Property
		end

		for _, Child in next, Children do
			Child.Parent = Object
		end

		return Object
	end

	function Library:Lighten(Color)
		local H, S, V = Color:ToHSV()

		V = math_clamp(V + 0.03, 0, 1)

		return Color3_fromHSV(H, S, V)
	end

	function Library:Darken(Color)
		local H, S, V = Color:ToHSV()

		V = math_clamp(V - 0.35, 0, 1)

		return Color3_fromHSV(H, S, V)
	end

	function Library:StringToKeyCode(String)
		local Byte = string_byte(String)

		for _, KeyCode in next, Enum_KeyCode:GetEnumItems() do
			if KeyCode.Value == Byte then
				return KeyCode
			end
		end
	end

	function Library:KeyCodeToString(KeyCode)
		if KeyCode.Value < 127 and KeyCode.Value > 33 then
			return string_char(KeyCode.Value)
		else
			return KeyCode.Name
		end
	end

	function Library:GetProperty(Level, Name, Properties)
		local AllProperties = {
			Window = {
				Name = {
					'Name',
					'NAME',
					'name'
				},
				Theme = {
					'Theme',
					'THEME',
					'theme'
				},
				Position = {
					'Position',
					'position',
					'POSITION'
				},
				Prefix = {
					'Prefix',
					'PREFIX',
					'prefix'
				}
			}
		}

		local PossibleNames = AllProperties[Level][Name]

		for _, Name in next, PossibleNames do
			if Properties[Name] then
				return Properties[Name]
			end
		end
	end
	
    function Library:Destroy()
        if Library.ScreenGui and Library.ScreenGui.Parent then
            local UI = Library.ScreenGui

            if UI:FindFirstChild("Main") then
                local Main = UI.Main

                for _, Item in next, Main:GetChildren() do
                    if Item.Name ~= 'MainCorner' and Item.Name ~= 'MainStroke' then
                        Item:Destroy()
                    end
                end

                if type(Library.Tween) == "function" then
                    Library:Tween(Main, { Size = UDim2_new(0, 500, 0, 0) }, 0.25)
                end
            end

            local ToolTip = UI:FindFirstChild("ToolTip")

            if ToolTip and type(Library.Tween) == "function" then
                Library:Tween(ToolTip, { BackgroundTransparency = 1 }, 0.25)
            end

            task_wait(0.25)
            UI:Destroy()
            return
        end
    end

    function Library:LevenshteinDistance(str1, str2)
        local len1, len2 = #str1, #str2
        local matrix = {}
        
        for i = 0, len1 do 
            matrix[i] = { [0] = i } 
        end
        for j = 0, len2 do 
            matrix[0][j] = j 
        end

        for i = 1, len1 do
            for j = 1, len2 do
                local cost = (str1:sub(i, i) == str2:sub(j, j)) and 0 or 1
                matrix[i][j] = math.min(
                    matrix[i-1][j] + 1,
                    matrix[i][j-1] + 1,
                    matrix[i-1][j-1] + cost
                )
            end
        end

        return matrix[len1][len2]
    end
end

function Library:CreateNotification(Title, Text, Duration)
    if not Library.ScreenGui or not Library.ScreenGui.Parent then
        return
    end
	Library.ActiveNotifications = Library.ActiveNotifications or {}

    if type(Library.Create) ~= "function" or type(Library.Tween) ~= "function" then
        return
    end

    local Container = Library.ScreenGui

    local function NotificationCount()
        if not Container or not Container.Parent then
            return 0
        end

        local Amount = 0
        for _, Notification in next, Container:GetChildren() do
            if string_find(Notification.Name, 'Notification') then
                Amount += 1
            end
        end
        return Amount
    end

    task_spawn(function()
        if type(Library.Create) ~= "function" or type(Library.Tween) ~= "function" then
            return
        end

        local TitleText = Title or 'Title'
        local MessageText = Text or 'Text'
        local Timeout = Duration or 4

        local NotifNumber = NotificationCount() + 1
        local NotifName = 'Notification' .. tostring(NotifNumber)

        local Notification = Library:Create('Frame', {
            Parent = Container,
            Name = NotifName,
            BackgroundColor3 = Library.Theme.BackgroundColor,
            BorderSizePixel = 0,
            Position = UDim2_new(1, 300, 1, -30),
            Size = UDim2_new(0, 300, 0, 50),
            BackgroundTransparency = 0,
            AnchorPoint = Vector2_new(1, 1)
        }, {
            Library:Create('UICorner', {
                CornerRadius = UDim_new(0, 5),
                Name = 'NotificationCorner'
            }),
            Library:Create('UIStroke', {
                Name = 'NotificationStroke',
                ApplyStrokeMode = 'Contextual',
                Color = Library.Theme.AccentColor,
                LineJoinMode = 'Round',
                Thickness = 1
            }),
            Library:Create('TextLabel', {
                Name = 'NotificationTitle',
                BackgroundTransparency = 1,
                Position = UDim2_new(0, 0, 0, -1),
                Size = UDim2_new(0, 300, 0, 30),
                Font = FontFace,
                Text = TitleText,
                TextColor3 = Library.Theme.PrimaryTextColor,
                TextSize = 16,
                TextXAlignment = Enum_TextXAlignment_Left
            }, {
                Library:Create('UIPadding', {
                    Name = 'NotificationTitlePadding',
                    PaddingLeft = UDim_new(0, 7)
                })
            }),
            Library:Create('TextLabel', {
                Name = 'NotificationText',
                BackgroundTransparency = 1,
                Position = UDim2_new(0, 0, 0, 25),
                Size = UDim2_new(0, 300, 0, 30),
                Font = FontFace,
                Text = MessageText,
                TextWrapped = true,
                TextColor3 = Library.Theme.SecondaryTextColor,
                TextSize = 14,
                TextXAlignment = Enum_TextXAlignment_Left
            }, {
                Library:Create('UIPadding', {
                    Name = 'NotificationTextPadding',
                    PaddingLeft = UDim_new(0, 7)
                })
            })
        })

        table_insert(Library.ActiveNotifications, Notification)

        local TitleLabel = Notification.NotificationTitle
        local MessageLabel = Notification.NotificationText
        local TextSize = TextService:GetTextSize(MessageText, 14, FontFace, Vector2_new(300, math_huge))

        Notification.Size = UDim2_new(0, 300, 0, TextSize.Y + 30)
        MessageLabel.Size = UDim2_new(0, 300, 0, TextSize.Y)

        local NotifCount = NotificationCount()

        if NotifCount > 1 then
            local PreviousSizes = 0
            for _, ExistingNotif in next, Container:GetChildren() do
                if string_find(ExistingNotif.Name, 'Notification') and ExistingNotif ~= Notification and ExistingNotif.Position.X == UDim_new(1, -30) then
                    PreviousSizes = PreviousSizes + ExistingNotif.AbsoluteSize.Y + 5
                end
            end
            Notification.Position = UDim2_new(1, 300, 1, -30 - PreviousSizes)
            if type(Library.Tween) == "function" then
                Library:Tween(Notification, { Position = UDim2_new(1, -30, 1, -30 - PreviousSizes) }, 0.25)
            end
        else
            if type(Library.Tween) == "function" then
                Library:Tween(Notification, { Position = UDim2_new(1, -30, 1, -30) }, 0.25)
            end
        end

        task_wait(Timeout - 0.5)

        if type(Library.Tween) == "function" then
            Library:Tween(Notification, { BackgroundTransparency = 0.8 }, 0.25)
            Library:Tween(TitleLabel, { TextTransparency = 0.5 }, 0.25)
            Library:Tween(MessageLabel, { TextTransparency = 0.5 }, 0.25)
        end

        task_wait(0.25)

        if type(Library.Tween) == "function" then
            Library:Tween(Notification, { Position = UDim2_new(1, 300, 1, Notification.Position.Y.Offset) }, 0.25)
        end

        task_wait(0.25)

        if Notification and Notification.Parent then
            for i, notif in ipairs(Library.ActiveNotifications) do
                if notif == Notification then
                    table.remove(Library.ActiveNotifications, i)
                    break
                end
            end
            Notification:Destroy()
        end

        local RemainingNotifs = {}
        for _, ExistingNotif in next, Container:GetChildren() do
            if string_find(ExistingNotif.Name, 'Notification') and ExistingNotif ~= Notification then
                table_insert(RemainingNotifs, ExistingNotif)
            end
        end

        for i, Notif in ipairs(RemainingNotifs) do
            local NewY = -30 - ((i - 1) * (Notif.AbsoluteSize.Y + 5))
            if type(Library.Tween) == "function" then
                Library:Tween(Notif, { Position = UDim2_new(1, -30, 1, NewY) }, 0.25)
            end
        end
    end)
end

-- // @Library Themes
Library.Transparency = 0

Library.Themes = {
	['Dark'] = {
		BackgroundColor = Color3_fromRGB(40, 40, 40),
		SecondaryColor = Color3_fromRGB(50, 50, 50),
		AccentColor = Color3_fromRGB(100, 100, 100),
		PrimaryTextColor = Color3_fromRGB(255, 255, 255),
		SecondaryTextColor = Color3_fromRGB(175, 175, 175)
	},
	['Light'] = {
		BackgroundColor = Color3_fromRGB(255, 255, 255),
		SecondaryColor = Color3_fromRGB(225, 225, 225),
		AccentColor = Color3_fromRGB(125, 125, 125),
		PrimaryTextColor = Color3_fromRGB(0, 0, 0),
		SecondaryTextColor = Color3_fromRGB(75, 75, 75)
	},
	['Red'] = {
		BackgroundColor = Color3_fromRGB(0, 0, 0),
		PrimaryTextColor = Color3_fromRGB(255, 255, 255),
		SecondaryTextColor = Color3_fromRGB(135, 135, 135),
		AccentColor = Color3_fromRGB(255, 0, 0),
		SecondaryColor = Color3_fromRGB(50, 50, 50)
	},
	['Nordic'] = {
		BackgroundColor = Color3_fromRGB(25, 30, 35),
		PrimaryTextColor = Color3_fromRGB(255, 255, 255),
		SecondaryTextColor = Color3_fromRGB(135, 135, 135),
		AccentColor = Color3_fromRGB(50, 60, 70),
		SecondaryColor = Color3_fromRGB(50, 55, 60)
	},
	['Purple'] = {
		BackgroundColor = Color3_fromRGB(30, 30, 45),
		PrimaryTextColor = Color3_fromRGB(255, 255, 255),
		SecondaryTextColor = Color3_fromRGB(135, 135, 135),
		AccentColor = Color3_fromRGB(60, 60, 80),
		SecondaryColor = Color3_fromRGB(60, 60, 80)
	},
	['Krnl'] = {
		BackgroundColor = Color3_fromRGB(40, 40, 40),
		PrimaryTextColor = Color3_fromRGB(255, 255, 255),
		SecondaryTextColor = Color3_fromRGB(125, 125, 125),
		AccentColor = Color3_fromRGB(60, 60, 60),
		SecondaryColor = Color3_fromRGB(40, 40, 40)
	},
	['Blue'] = {
		BackgroundColor = Color3_fromRGB(30, 30, 30),
		PrimaryTextColor = Color3_fromRGB(0, 125, 255),
		SecondaryTextColor = Color3_fromRGB(255, 255, 255),
		AccentColor = Color3_fromRGB(0, 125, 255),
		SecondaryColor = Color3_fromRGB(45, 45, 45)
	},
	['Orange'] = {
		BackgroundColor = Color3_fromRGB(35, 35, 35),
		PrimaryTextColor = Color3_fromRGB(255, 255, 255),
		SecondaryTextColor = Color3_fromRGB(135, 135, 135),
		AccentColor = Color3_fromRGB(255, 170, 60),
		SecondaryColor = Color3_fromRGB(50, 50, 50)
	}
}

Library.Prefix = Library:StringToKeyCode(';')
Library.Theme = nil

function Library:CreateWindow(Properties)
	-- // @Properties
	local Name = Library:GetProperty('Window', 'Name', Properties) or Library:RandomString(15)
	local Theme = Library:GetProperty('Window', 'Theme', Properties) or Library.Themes.dark
	local Position = string_lower(Library:GetProperty('Window', 'Position', Properties)) or 'top'
	local Prefix = Library:StringToKeyCode(Library:GetProperty('Window', 'Prefix', Properties)) or Library:StringToKeyCode(';')
	local Config = Properties.Config

	if not Config or Config == "" then
		Config = Library.CommandModuleData
	end

	Library.Prefix = Prefix
	Library.Configuration = Config
	Library.Instance = Library:RandomString(15)

	local Load = LoadConfig(Config)

    if Load then
        if Load.Prefix then
            Library.Prefix = Library:StringToKeyCode(Load.Prefix)
            Prefix = Library.Prefix
        end

        if Load.Theme and Library.Themes[Load.Theme] then
            Library.Theme = Library.Themes[Load.Theme]
            Theme = Library.Theme
        else
            Library.Theme = Theme
        end
    else
        Library.Theme = Theme
    end

	-- // @Custom Theme
	if type(Theme) == 'table' then
		Library.Themes['custom'] = Theme
	end

	local Container = Library:Create('ScreenGui', {
		Name = Library.Instance,
		DisplayOrder = 999999999
	}, {
		Library:Create('Frame', {
			Name = 'Main',
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			AnchorPoint = Vector2_new(0.5, 0.5),
			Position = UDim2_new(0.5, 0, 0.5, 0),
			Size = UDim2_new(0, 0, 0, 0)
		}, {
			Library:Create('UIStroke', {
				Name = 'MainStroke',
				ApplyStrokeMode = 'Contextual',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 1
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim_new(0, 5),
				Name = 'MainCorner'
			}),
		}),
	})

	ParentUI(Container)
	Library.ScreenGui = Container
	Library.Connections = {}

	local Main = Container.Main
	local MainStroke = Main.MainStroke

	MainStroke.Thickness = 0

	Library:Tween(Main, {Size = UDim2_new(0, 500, 0, 65)}, 0.25)
	Library:Tween(Main, {BackgroundTransparency = 0}, 0.25)
	MainStroke.Thickness = 1

	task_wait(0.5)

	if Position == 'top' then
		Main.AnchorPoint = Vector2_new(0.5, 0)
		Library:Tween(Main, {Position = UDim2_new(0.5, 0, 0, -72)}, 0.25)
	elseif Position == 'topleft' then
		Main.AnchorPoint = Vector2_new(0, 0)
		Library:Tween(Main, {Position = UDim2_new(0, 0, 0, -72)}, 0.25)
	elseif Position == 'topright' then
		Main.AnchorPoint = Vector2_new(1, 0)
		Library:Tween(Main, {Position = UDim2_new(1, 0, 0, -72)}, 0.25)
	elseif Position == 'bottomleft' then
		Main.AnchorPoint = Vector2_new(0, 1)
		Library:Tween(Main, {Position = UDim2_new(0, 0, 1, 36)}, 0.25)
	elseif Position == 'bottom' then
		Main.AnchorPoint = Vector2_new(0.5, 1)
		Library:Tween(Main, {Position = UDim2_new(0.5, 0, 1, 36)}, 0.25)
	elseif Position == 'bottomright' then
		Main.AnchorPoint = Vector2_new(1, 1)
		Library:Tween(Main, {Position = UDim2_new(1, 0, 1, 36)}, 0.25)
	end

	if string_find(Position, 'top') then
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			Name = 'Filler1',
			BackgroundTransparency = 0,
			Position = UDim2_new(0, 0, 0, 0),
			Size = UDim2_new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			Name = 'Filler2',
			BackgroundTransparency = 0,
			Position = UDim2_new(0, 495, 0, 0),
			Size = UDim2_new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			Name = 'Line1',
			BackgroundTransparency = 0,
			Position = UDim2_new(0, -1, 0, 0),
			Size = UDim2_new(0, 1, 0, 10)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			Name = 'Line2',
			BackgroundTransparency = 0,
			Position = UDim2_new(0, 500, 0, 0),
			Size = UDim2_new(0, 1, 0, 10)
		})
	else
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Filler1',
			Position = UDim2_new(0, 0, 0, 60),
			Size = UDim2_new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Filler2',
			Position = UDim2_new(0, 495, 0, 60),
			Size = UDim2_new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Line1',
			Position = UDim2_new(0, -1, 0, 60),
			Size = UDim2_new(0, 1, 0, 10)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Line2',
			Position = UDim2_new(0, 500, 0, 60),
			Size = UDim2_new(0, 1, 0, 10)
		})
	end

	if string_find(Position, 'bottom') then
		-- // @Command Input
		local CommandInput = Library:Create('TextBox', {
			Font = FontFace,
			PlaceholderColor3 = Theme.SecondaryTextColor,
			PlaceholderText = 'Enter Command',
			Text = '',
			TextColor3 = Theme.PrimaryTextColor,
			TextSize = 14,
			ClearTextOnFocus = false,
			Parent = Main,
			BackgroundColor3 = Theme.SecondaryColor,
			BorderSizePixel = 0,
			TextTransparency = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum_TextXAlignment_Left,
			Visible = false,
			Name = 'CommandInput',
			AnchorPoint = Vector2_new(0.5, 1),
			Position = UDim2_new(0.5, 0, 1, -5),
			Size = UDim2_new(0, 490, 0, 30)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandInputStroke',
				ApplyStrokeMode = 'Border',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 0
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim_new(0, 5),
				Name = 'CommandInputCorner'
			}),
			Library:Create('UIPadding', {
				PaddingLeft = UDim_new(0, 5),
				Name = 'CommandInputPadding'
			}),
		})

		Library:Create('TextLabel', {
			Name = 'Title',
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Position = UDim2_new(0, 0, 0, 4),
			Size = UDim2_new(0, 250, 0, 20),
			Font = FontFace,
			BorderSizePixel = 0, 
			Text = Name,
			TextColor3 = Theme.PrimaryTextColor,
			TextSize = 16,
			TextXAlignment = Enum_TextXAlignment_Left
		}, {
			Library:Create('UIPadding', {
				Name = 'TitlePadding',
				PaddingLeft = UDim_new(0, 7)
			})
		})

		Library:Create('TextButton', {
			Name = 'CloseButton',
			Position = UDim2_new(0, 475, 0, 4),
			Size = UDim2_new(0, 20, 0, 20),
			BackgroundColor3 = Theme.BackgroundColor,
			TextColor3 = Theme.PrimaryTextColor,
			AutoButtonColor = false,
			Font = FontFace,
			Parent = Main,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSizePixel = 0,
			TextSize = 30,
			Text = '≡'
		}, {
			Library:Create('UICorner', {
				Name = 'CloseButtonCorner',
				CornerRadius = UDim_new(0, 5)
			})
		})

		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			Name = 'CommandsHolder',
			Visible = false,
			Position = UDim2_new(0, 0, 0, -305),
			Size = UDim2_new(0, 500, 0, 300)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandsHolderStroke',
				ApplyStrokeMode = 'Contextual',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 1
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim_new(0, 5),
				Name = 'CommandsHolderCorner'
			}),
			Library:Create('ScrollingFrame', {
				BackgroundColor3 = Theme.BackgroundColor,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ScrollBarThickness = 1,
				ScrollBarImageColor3 = Theme.AccentColor,
				Name = 'CommandsHolderScrolling',
				Position = UDim2_new(0, 0, 0, 5),
				Size = UDim2_new(0, 500, 0, 290)
			}, {
				Library:Create('UIListLayout', {
					Name = 'CommandsHolderScrollingListLayout',
					HorizontalAlignment = Enum_HorizontalAlignment_Center,
					SortOrder = Enum_SortOrder_LayoutOrder,
					Padding = UDim_new(0, 3)
				}),
				Library:Create('Frame', {
					Name = 'UnclipTop',
					BorderSizePixel = 0,
					LayoutOrder = -999999999,
					Size = UDim2_new(0, 0, 0, -7),
					BackgroundTransparency = 1
				})
			})
		})
	else
		local CommandInput = Library:Create('TextBox', {
			Font = FontFace,
			PlaceholderColor3 = Theme.SecondaryTextColor,
			PlaceholderText = 'Enter Command',
			Text = '',
			TextColor3 = Theme.PrimaryTextColor,
			TextSize = 14,
			Parent = Main,
			BackgroundColor3 = Theme.SecondaryColor,
			BorderSizePixel = 0,
			TextTransparency = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum_TextXAlignment_Left,
			Visible = false,
			Name = 'CommandInput',
			AnchorPoint = Vector2_new(0.5, 0),
			Position = UDim2_new(0.5, 0, 0, 5),
			Size = UDim2_new(0, 490, 0, 30)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandInputStroke',
				ApplyStrokeMode = 'Border',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 0
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim_new(0, 5),
				Name = 'CommandInputCorner'
			}),
			Library:Create('UIPadding', {
				PaddingLeft = UDim_new(0, 5),
				Name = 'CommandInputPadding'
			}),
		})

		Library:Create('TextLabel', {
			Name = 'Title',
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Position = UDim2_new(0, 0, 0, 40),
			Size = UDim2_new(0, 250, 0, 20),
			Font = FontFace,
			BorderSizePixel = 0, 
			Text = Name,
			TextColor3 = Theme.PrimaryTextColor,
			TextSize = 16,
			TextXAlignment = Enum_TextXAlignment_Left
		}, {
			Library:Create('UIPadding', {
				Name = 'TitlePadding',
				PaddingLeft = UDim_new(0, 7)
			})
		})

		Library:Create('TextButton', {
			Name = 'CloseButton',
			Position = UDim2_new(0, 475, 0, 40),
			Size = UDim2_new(0, 20, 0, 20),
			BackgroundColor3 = Theme.BackgroundColor,
			TextColor3 = Theme.PrimaryTextColor,
			AutoButtonColor = false,
			Font = FontFace,
			Parent = Main,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSizePixel = 0,
			TextSize = 30,
			Text = '≡'
		}, {
			Library:Create('UICorner', {
				Name = 'CloseButtonCorner',
				CornerRadius = UDim_new(0, 5)
			}),
		})

		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			Visible = false,
			BackgroundTransparency = 1,
			Name = 'CommandsHolder',
			Position = UDim2_new(0, 0, 0, 70),
			Size = UDim2_new(0, 500, 0, 300)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandsHolderStroke',
				ApplyStrokeMode = 'Contextual',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 1
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim_new(0, 5),
				Name = 'CommandsHolderCorner'
			}),
			Library:Create('ScrollingFrame', {
				BackgroundColor3 = Theme.BackgroundColor,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ScrollBarThickness = 1,
				ScrollBarImageColor3 = Theme.AccentColor,
				Name = 'CommandsHolderScrolling',
				Position = UDim2_new(0, 0, 0, 5),
				Size = UDim2_new(0, 500, 0, 290)
			}, {
				Library:Create('UIListLayout', {
					Name = 'CommandsHolderScrollingListLayout',
					HorizontalAlignment = Enum_HorizontalAlignment_Center,
					SortOrder = Enum_SortOrder_LayoutOrder,
					Padding = UDim_new(0, 3)
				}),
				Library:Create('Frame', {
					Name = 'UnclipTop',
					BorderSizePixel = 0,
					LayoutOrder = -999999999,
					Size = UDim2_new(0, 0, 0, -7),
					BackgroundTransparency = 1
				})
			})
		})
		
		local IsInCommandsHolder = false

		local CommandEntered = CommandsHolder.MouseEnter:Connect(function()
		    IsInCommandsHolder = true
		end)
		table_insert(Library.Connections, CommandEntered)

		local CommandLeft = CommandsHolder.MouseLeave:Connect(function()
		    IsInCommandsHolder = false
		end)
		table_insert(Library.Connections, CommandLeft)
	end

	Library:Create('TextLabel', {
		Name = 'ToolTip',
		Parent = Container,
		BackgroundColor3 = Theme.BackgroundColor,
		BackgroundTransparency = 0,
		TextTransparency = 0,
		Position = UDim2_new(0, 0, 0, 0),
		Size = UDim2_new(0, 0, 0, 0),
		AnchorPoint = Vector2_new(0.5, 0),
		TextXAlignment = Enum_TextXAlignment_Left,
		TextYAlignment = Enum_TextYAlignment_Top,
		TextWrapped = true,
		RichText = true,
		ZIndex = 100,
		Text = '',
		Font = FontFace,
		BorderSizePixel = 0, 
		TextColor3 = Theme.PrimaryTextColor,
		TextSize = 15
	}, {
		Library:Create('UICorner', {
			Name = 'ToolTipCorner',
			CornerRadius = UDim_new(0, 5)
		}),
		Library:Create('UIPadding', {
			Name = 'ToolTipPadding',
			PaddingLeft = UDim_new(0, 3),
			PaddingTop = UDim_new(0, 3)
		}),
		Library:Create('UIStroke', {
			Name = 'ToolTipStroke',
			ApplyStrokeMode = 'Border',
			Color = Theme.AccentColor,
			LineJoinMode = 'Round',
			Thickness = 1
		})
	})

	task_wait(0.25)

	local CommandInput = Main.CommandInput
	local CommandInputStroke = CommandInput.CommandInputStroke
	local CloseButton = Main.CloseButton
	local CommandsHolder = Main.CommandsHolder
	local CommandsHolderScrolling = CommandsHolder.CommandsHolderScrolling
	local CommandsHolderScrollingListLayout = CommandsHolderScrolling.CommandsHolderScrollingListLayout

	for _, Element in next, Main:GetChildren() do
		if Element:IsA('TextBox') or Element:IsA('TextLabel') or Element:IsA('TextButton') or Element:IsA('ImageButton') then
			Element.Visible = true

			if Library:HasProperty(Element, 'BackgroundTransparency') then
				Library:Tween(Element, {BackgroundTransparency = 0}, 0.25)
			end

			if Library:HasProperty(Element, 'TextTransparency') then
				Library:Tween(Element, {TextTransparency = 0}, 0.25)
			end

			if Library:HasProperty(Element, 'ImageTransparency') then
				Library:Tween(Element, {ImageTransparency = 0}, 0.25)
			end
		end
	end

	CommandInputStroke.Thickness = 1

	local Entered = CloseButton.MouseEnter:Connect(function()
		Library:Tween(CloseButton, {TextColor3 = Library:Darken(Theme.PrimaryTextColor)}, 0.25)
	end)
	table_insert(Library.Connections, Entered)

	local Left = CloseButton.MouseLeave:Connect(function()
		Library:Tween(CloseButton, {TextColor3 = Theme.PrimaryTextColor}, 0.25)
	end)
	table_insert(Library.Connections, Left)
	
	local function UpdateFrameSizes()
		local Count = 0

		for _, Instance in next, CommandsHolderScrolling:GetChildren() do
			if not Instance:IsA('UIListLayout') and Instance.Name ~= "UnclipTop" and Instance.Visible then
				Count += 1 
			end
		end

		local Size = Count * 30
		local Padding = 3 * Count

		Size += Padding - 3

		if Count == 0 then
			Library:Tween(CommandsHolder, {Size = UDim2_new(0, 500, 0, 0)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {Size = UDim2_new(0, 500, 0, Size)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {CanvasSize = UDim2_new(0, 500, 0, Size)}, 0.25)

		elseif Count < 9 then
			Library:Tween(CommandsHolder, {Size = UDim2_new(0, 500, 0, Size + 10)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {Size = UDim2_new(0, 500, 0, Size)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {CanvasSize = UDim2_new(0, 500, 0, Size)}, 0.25)

			if string_find(Position, 'bottom') then
				if Main.Position.Y == UDim_new(1, 1) or Main.Position.Y == UDim_new(1, 0) or Main.Position.Y == UDim_new(1, 2) or Main.Position.Y == UDim_new(0, -37) then
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset - Size - 13)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset - Size + 22)}, 0.25)
				end
			else
				if Main.Position.Y == UDim_new(1, 36) or Main.Position.Y == UDim_new(0, -72) then
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset - 3)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset + 33)}, 0.25)
				end
			end
		else
			Library:Tween(CommandsHolder, {Size = UDim2_new(0, 500, 0, 270)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {Size = UDim2_new(0, 500, 0, 260)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {CanvasSize = UDim2_new(0, 500, 0, Size)}, 0.25)

			if string_find(Position, 'bottom') then
				if Main.Position.Y == UDim_new(1, 1) or Main.Position.Y == UDim_new(1, 0) or Main.Position.Y == UDim_new(1, 2) or Main.Position.Y == UDim_new(0, -37) then
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset - 273)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset - 237)}, 0.25)
				end
			else
				if Main.Position.Y == UDim_new(1, 36) or Main.Position.Y == UDim_new(0, -72) then
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset - 3)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2_new(0, 0, 0, -Main.Position.Y.Offset + 33)}, 0.25)
				end
			end
		end
	end
	
	local function UpdateNotifications()
	    Library.ActiveNotifications = Library.ActiveNotifications or {}

	    for _, Notif in ipairs(Library.ActiveNotifications) do
            if Notif and Notif.Parent then
                Notif.BackgroundColor3 = Library.Theme.BackgroundColor

				local Stroke = Notif:FindFirstChild("NotificationStroke")
				if Stroke then
					Stroke.Color = Library.Theme.AccentColor
				end

				local Title = Notif:FindFirstChild("NotificationTitle")
				if Title then
					Title.TextColor3 = Library.Theme.PrimaryTextColor
				end

				local Text = Notif:FindFirstChild("NotificationText")
				if Text then
                    Text.TextColor3 = Library.Theme.SecondaryTextColor
				end
			end
		end
	end

	Library.IgnoreNextInput = false
	Library.HoverDebounce = false

	local function OpenList()
	    if Main.Position.Y == UDim_new(1, 37) or Main.Position.Y == UDim_new(1, 36) or Main.Position.Y == UDim_new(0, -72) then
			Library.IgnoreNextInput = true

			CommandInput:CaptureFocus()
			CommandInput.Text = ""
        
		    local Offset = string_find(Position, 'bottom') and -36 or 36
			Library:Tween(Main, {Position = Main.Position + UDim2_new(0, 0, 0, Offset)}, 0.25)
			
			task_wait(0.1)
			CommandsHolder.Visible = true
			Library:Tween(CommandsHolder, {BackgroundTransparency = 0.25}, 0.2)
			
			task_wait(0.1)
			UpdateFrameSizes()

			for _, Instance in next, CommandsHolderScrolling:GetDescendants() do
				if not Instance:IsA('UIListLayout') and not Instance:IsA('TextButton') then
					if Instance:IsA('Frame') and Instance.Name ~= 'Seperation' and Instance.Name ~= 'UnclipTop' then
						Library:Tween(Instance, {BackgroundTransparency = 0.25}, 0.2)
					end
					if Library:HasProperty(Instance, 'TextTransparency') then
						Library:Tween(Instance, {TextTransparency = 0}, 0.2)
					end
				end
			end
		end
	end

	local function CloseList()
		if not Library.HoverDebounce then
			task_spawn(function()
				Library.HoverDebounce = true
				task_wait(0.5)
				Library.HoverDebounce = false 
			end)

			if Main.Position.Y == UDim_new(1, 0) or Main.Position.Y == UDim_new(0, -36) then
				local isBottom = string_find(Position, 'bottom')
				CommandInput.Text = ''

				for _, Instance in next, CommandsHolderScrolling:GetDescendants() do
					if not Instance:IsA('UIListLayout') and not Instance:IsA('TextButton') then
						if Instance:IsA('Frame') and Instance.Name ~= 'Seperation' and Instance.Name ~= 'UnclipTop' then
							if type(Library.Tween) == "function" then
								Library:Tween(Instance, {BackgroundTransparency = 1}, 0.15)
							end					
						end
						if type(Library.HasProperty) == "function" and Library:HasProperty(Instance, 'TextTransparency') then
							Library:Tween(Instance, {TextTransparency = 1}, 0.15)
						end
					end
				end

				task_wait(0.1)

				if type(Library.Tween) == "function" then
					Library:Tween(CommandsHolder, {BackgroundTransparency = 1}, 0.25)
					Library:Tween(Main, {Position = Main.Position + UDim2_new(0, 0, 0, isBottom and 36 or -36)}, 0.3)
				end
				task_wait(0.1)
				CommandsHolder.Visible = false
			end
		end
	end

	local Added = CommandsHolderScrolling.ChildAdded:Connect(UpdateFrameSizes)
	local Removed = CommandsHolderScrolling.ChildRemoved:Connect(UpdateFrameSizes)

	table_insert(Library.Connections, Added)
	table_insert(Library.Connections, Removed)

    local Clicked = CloseButton.MouseButton1Down:Connect(OpenList)
	table_insert(Library.Connections, Clicked)

	-- // @Prefix
	local Pressed = UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
		if not GameProcessedEvent and Input.KeyCode.Name == Library.Prefix.Name then
			OpenList()
		end
	end)
	table_insert(Library.Connections, Pressed)

	-- // @Search Engine
	local function GetCorrectedCommand(Input)
	    Input = Input:lower()
		local Matches = {}

		for cmdName, cmdData in pairs(Commands) do
			local cmdLower = cmdName:lower()

            if cmdLower:sub(1, #Input) == Input then
                table_insert(Matches, {name = cmdName, data = cmdData, type = "prefix"})
			else
                local Distance = Library:LevenshteinDistance(Input, cmdLower)
                if Distance <= 2 then
                    table_insert(Matches, {name = cmdName, data = cmdData, type = "fuzzy", distance = Distance})
				end
			end
		end

		table.sort(Matches, function(a, b)
		    if a.type ~= b.type then
                return a.type == "prefix"
			elseif a.type == "fuzzy" then
                return a.distance < b.distance
			end
			return a.name < b.name
		end)
		return Matches
	end

	-- // @Search Commands
    local SearchEngine = CommandInput:GetPropertyChangedSignal('Text'):Connect(function()
	    if Library.IgnoreNextInput then
		    CommandInput.Text = ""
		    Library.IgnoreNextInput = false
		    return
	    end

	    local OriginalText = CommandInput.Text
	
	    if OriginalText == '' then
		    for _, Instance in next, CommandsHolderScrolling:GetChildren() do
			    if not Instance:IsA('UIListLayout') and Instance.Name ~= 'UnclipTop' then
				    Instance.Visible = true
				    UpdateFrameSizes()
			    end
		    end
		else
		    local Split = {}
		    for word in OriginalText:gmatch("%S+") do
			    table_insert(Split, word)
		    end

		    local Full = ''
		    local PrefixChar = Library:KeyCodeToString(Library.Prefix)

		    for Index, Word in ipairs(Split) do
			    if Index == 1 then
				    local CleanWord = Word:gsub(PrefixChar, '')
				    Full = Full .. CleanWord
			    else
				    Full = Full .. ' ' .. Word
			    end
		    end

		    local CleanSearch = Full:lower()
		
		    if CleanSearch == '' or CleanSearch == ' ' then
			    for _, Instance in next, CommandsHolderScrolling:GetChildren() do
				    if not Instance:IsA('UIListLayout') and Instance.Name ~= 'UnclipTop' then
					    Instance.Visible = true
				    end
			    end
			    UpdateFrameSizes()
			    return
		    end
		
		    local Commands = GetCorrectedCommand(CleanSearch)

		    for _, Instance in next, CommandsHolderScrolling:GetChildren() do
			    if not Instance:IsA('UIListLayout') and Instance.Name ~= 'UnclipTop' then
				    local CommandName = Instance.Name:gsub('CommandHolder', '')

				    local FoundString = false
				    for _, cmd in ipairs(Commands) do
					    if cmd.name == CommandName then
						    FoundString = true
						    break
					    end
				    end

				    if not FoundString and #Commands == 0 then
					    if string_find(CommandName:lower(), CleanSearch) then
						    FoundString = true
					    end
				    end

				    Instance.Visible = FoundString
				    UpdateFrameSizes()
			    end
		    end
	    end
    end)
    table_insert(Library.Connections, SearchEngine)

	-- // @Execute Command
    local function Execute(String)
        local Split = String:split(' ')
		local Arguments = {}
		local First = Split[1]:lower():gsub(Library:KeyCodeToString(Library.Prefix), '')
		
		CommandInput.Text = ''
		local Correction = GetCorrectedCommand(First)
		
		if #Correction == 0 then
			Library:CreateNotification("Validator.exe", 'Command Not Found: ' .. First)
			CloseList()
		    return
		end
    
        if #Correction > 1 then
			local Suggestions = {}
			for i, match in ipairs(Correction) do
				local cmdData = Commands[match.name]
				local argString = ""
				if cmdData and cmdData.Arguments and #cmdData.Arguments > 0 then
					argString = " {" .. table.concat(cmdData.Arguments, "} {") .. "}"
				end
				table_insert(Suggestions, string_format("%s%s - %s", match.name, argString, cmdData.Description))
			end
			
			Library:CreateNotification("What Did you mean?",  table.concat(Suggestions, "\n"), 5)
			CloseList()
			return
		end

	    local Command = Commands[Correction[1].name]
	    local NumberOfArguments = #Command.Arguments

		for Index, Argument in next, Split do
			if Index > 1 then
				table_insert(Arguments, Argument)
			end
		end
    
        if NumberOfArguments > #Arguments then
			local Missing = {}
			for Index = 1, NumberOfArguments do
				if not Arguments[Index] then
					table_insert(Missing, Command.Arguments[Index])
				end
			end

		    Library:CreateNotification("Validator.exe", 'Missing Arguments: ' .. table.concat(Missing, ', ') .. ' | Command: ' .. Correction[1].name)
			CloseList()
		else
            task_spawn(Command.Callback, Arguments, LocalPlayer)
            CloseList()
		end
	end

    -- // @Command Entered
    Library.ExecuteQueued = false

	local LostFocus = CommandInput.FocusLost:Connect(function()
		task_wait(0.05)

		if not IsInCommandsHolder then
			if Main.Position.Y == UDim_new(1, 0) or Main.Position.Y == UDim_new(0, -36) then
				if CommandInput.Text ~= '' and not Library.ExecuteQueued then
					task_spawn(function()
						pcall(Execute, CommandInput.Text)
					end)
				end

				CloseList()
			end
		end
	end)
	table_insert(Library.Connections, LostFocus)

	-- // @Tool Tips
	function CreateToolTip(Text, Clone, Enabled)
		local ToolTip = Container.ToolTip
		if not ToolTip then return end

		if Enabled then
			local Size = TextService:GetTextSize(Clone, ToolTip.TextSize, ToolTip.Font, Vector2_new(300, math_huge))
			Library:Tween(ToolTip, {Size = UDim2_new(0, Size.X + 5, 0, Size.Y + 5)}, 0.25)

			if ToolTip.Visible then
				RunService:UnbindFromRenderStep('ToolTip')
				ToolTip.Visible = false
			end

			RunService:BindToRenderStep('ToolTip', 1, function()
				local MouseLocation = UserInputService:GetMouseLocation()
				local ViewportSize = Workspace.CurrentCamera.ViewportSize
				local NewPosition = UDim2_new(MouseLocation.X / ViewportSize.X, 0, MouseLocation.Y / ViewportSize.Y, 0)
				Library:Tween(ToolTip, {Position = NewPosition}, 0.25)
			end)

			ToolTip.Text = Text
			ToolTip.Visible = true

		else
			if ToolTip.Visible then
				ToolTip.Visible = false
				RunService:UnbindFromRenderStep('ToolTip')
			end
		end
	end

	local WindowFunctions = {}

	function WindowFunctions:ChangePrefix(Prefix)
		Library.Prefix = Library:StringToKeyCode(Prefix)
	end

	function WindowFunctions:AddTheme(Name, Theme)
		if not Library.Themes[Name] then
			Library.Themes[Name:lower()] = Theme
		end
	end

	function WindowFunctions:GetThemes(Names)
		if Names then
			local Table = {}
			for Index, Theme in next, Library.Themes do
				table_insert(Table, Index)
			end
			return Table
		else
			return Library.Themes
		end
	end

	function WindowFunctions:ChangeTheme(NewTheme)
		if type(NewTheme) == 'table' then
			Library.Theme = NewTheme
			Library.Themes['custom'] = NewTheme
			Theme = Library.Theme
			
			Main.BackgroundColor3 = Library.Theme.BackgroundColor
			Main.MainStroke.Color = Library.Theme.AccentColor
			Main.Filler1.BackgroundColor3 = Library.Theme.BackgroundColor
			Main.Filler2.BackgroundColor3 = Library.Theme.BackgroundColor
			Main.Line1.BackgroundColor3 = Library.Theme.AccentColor
			Main.Line2.BackgroundColor3 = Library.Theme.AccentColor
			
			Main.CommandInput.BackgroundColor3 = Library.Theme.SecondaryColor
			Main.CommandInput.TextColor3 = Library.Theme.PrimaryTextColor
			Main.CommandInput.PlaceholderColor3 = Library.Theme.SecondaryTextColor
			Main.CommandInput.CommandInputStroke.Color = Library.Theme.AccentColor
			
			Main.Title.BackgroundColor3 = Library.Theme.BackgroundColor
			Main.Title.TextColor3 = Library.Theme.PrimaryTextColor
			Main.CloseButton.BackgroundColor3 = Library.Theme.BackgroundColor
			Main.CloseButton.TextColor3 = Library.Theme.PrimaryTextColor			
			Main.CommandsHolder.BackgroundColor3 = Library.Theme.BackgroundColor
			Main.CommandsHolder.CommandsHolderScrolling.BackgroundColor3 = Library.Theme.BackgroundColor
			Main.CommandsHolder.CommandsHolderScrolling.ScrollBarImageColor3 = Library.Theme.AccentColor
			Main.CommandsHolder.CommandsHolderStroke.Color = Library.Theme.AccentColor
			
			Container.ToolTip.BackgroundColor3 = Library.Theme.BackgroundColor
			Container.ToolTip.TextColor3 = Library.Theme.PrimaryTextColor
			Container.ToolTip.ToolTipStroke.Color = Library.Theme.AccentColor
			
			for _, child in pairs(CommandsHolderScrolling:GetChildren()) do
				if child:IsA("Frame") and child.Name and string_find(child.Name, 'CommandHolder') then
					child.BackgroundColor3 = Library.Theme.BackgroundColor
					local textLabel = child:FindFirstChild(child.Name:gsub('CommandHolder', 'Text'))
					if textLabel then
						textLabel.BackgroundColor3 = Library.Theme.BackgroundColor
						textLabel.TextColor3 = Library.Theme.PrimaryTextColor
						
						local cmdName = child.Name:gsub('CommandHolder', '')
						local cmdData = Commands[cmdName:lower()]
						if cmdData then
							local function Highlight(str, col)
								return string_format('<font color="rgb(%d, %d, %d)">%s</font>', col.r*255, col.g*255, col.b*255, str)
							end
							local newText = Highlight(cmdName, Library.Theme.PrimaryTextColor) .. ' '
							for _, arg in next, cmdData.Arguments do
								newText = newText .. Highlight('{' .. arg .. '}', Library.Theme.SecondaryTextColor) .. ' '
							end
							newText = newText .. Highlight('| ', Library.Theme.AccentColor) .. Highlight(cmdData.Description, Library.Theme.SecondaryTextColor)
							textLabel.Text = newText
						end
					end
				end
			end
			
			for _, child in pairs(CommandsHolderScrolling:GetChildren()) do
				if child:IsA("Frame") and child.Name == 'Seperation' then
					for _, textChild in pairs(child:GetChildren()) do
						if textChild:IsA("TextLabel") then
							textChild.TextColor3 = Library.Theme.PrimaryTextColor
						end
					end
				end
			end
			
			UpdateNotifications()
		elseif type(NewTheme) == 'string' then
			if Library.Themes[NewTheme] then
				Library.Theme = Library.Themes[NewTheme]
				Theme = Library.Theme

				Main.BackgroundColor3 = Library.Theme.BackgroundColor
				Main.MainStroke.Color = Library.Theme.AccentColor
				Main.Filler1.BackgroundColor3 = Library.Theme.BackgroundColor
				Main.Filler2.BackgroundColor3 = Library.Theme.BackgroundColor
				Main.Line1.BackgroundColor3 = Library.Theme.AccentColor
				Main.Line2.BackgroundColor3 = Library.Theme.AccentColor
				
				Main.CommandInput.BackgroundColor3 = Library.Theme.SecondaryColor
				Main.CommandInput.TextColor3 = Library.Theme.PrimaryTextColor
				Main.CommandInput.PlaceholderColor3 = Library.Theme.SecondaryTextColor
				Main.CommandInput.CommandInputStroke.Color = Library.Theme.AccentColor
				
				Main.Title.BackgroundColor3 = Library.Theme.BackgroundColor
				Main.Title.TextColor3 = Library.Theme.PrimaryTextColor
				Main.CloseButton.BackgroundColor3 = Library.Theme.BackgroundColor
				Main.CloseButton.TextColor3 = Library.Theme.PrimaryTextColor
				
				Main.CommandsHolder.BackgroundColor3 = Library.Theme.BackgroundColor
				Main.CommandsHolder.CommandsHolderScrolling.BackgroundColor3 = Library.Theme.BackgroundColor
				Main.CommandsHolder.CommandsHolderScrolling.ScrollBarImageColor3 = Library.Theme.AccentColor
				Main.CommandsHolder.CommandsHolderStroke.Color = Library.Theme.AccentColor
				
				Container.ToolTip.BackgroundColor3 = Library.Theme.BackgroundColor
				Container.ToolTip.TextColor3 = Library.Theme.PrimaryTextColor
				Container.ToolTip.ToolTipStroke.Color = Library.Theme.AccentColor
				
				for _, child in pairs(CommandsHolderScrolling:GetChildren()) do
					if child:IsA("Frame") and child.Name and string_find(child.Name, 'CommandHolder') then
						child.BackgroundColor3 = Library.Theme.BackgroundColor
						local textLabel = child:FindFirstChild(child.Name:gsub('CommandHolder', 'Text'))
						if textLabel then
							textLabel.BackgroundColor3 = Library.Theme.BackgroundColor
							textLabel.TextColor3 = Library.Theme.PrimaryTextColor
	
							local cmdName = child.Name:gsub('CommandHolder', '')
							local cmdData = Commands[cmdName]
							if cmdData then
								local function Highlight(str, col)
									return string_format('<font color="rgb(%d, %d, %d)">%s</font>', col.r*255, col.g*255, col.b*255, str)
								end
								local newText = Highlight(cmdName, Library.Theme.PrimaryTextColor) .. ' '
								for _, arg in next, cmdData.Arguments do
									newText = newText .. Highlight('{' .. arg .. '}', Library.Theme.SecondaryTextColor) .. ' '
								end
								newText = newText .. Highlight('| ', Library.Theme.AccentColor) .. Highlight(cmdData.Description, Library.Theme.SecondaryTextColor)
								textLabel.Text = newText
							end
						end
					end
				end
				
				for _, child in pairs(CommandsHolderScrolling:GetChildren()) do
					if child:IsA("Frame") and child.Name == 'Seperation' then
						for _, textChild in pairs(child:GetChildren()) do
							if textChild:IsA("TextLabel") then
								textChild.TextColor3 = Library.Theme.PrimaryTextColor
							end
						end
					end
				end

				UpdateNotifications()
			end
		end
	end

    function WindowFunctions:SavePrefix(Prefix)
        local Config = LoadConfig(Library.Configuration) or {}
        Config.Prefix = Prefix
        SaveConfig(Library.Configuration, Config)
	end

    function WindowFunctions:SaveTheme(Theme)
        local Config = LoadConfig(Library.Configuration) or {}
        Config.Theme = Theme
        SaveConfig(Library.Configuration, Config)
	end

	function WindowFunctions:Unload()
	    RunService:UnbindFromRenderStep('ToolTip')

		if Library.Connections then
			for _, Conn in pairs(Library.Connections) do
				pcall(function() Conn:Disconnect() end)
			end
		end

		Library:Destroy()
	    for cmd in pairs(Commands) do
	        Commands[cmd] = nil
	    end

		for Instance, _ in pairs(Library) do
			Library[Instance] = nil
		end

		for Functions, _ in pairs(WindowFunctions) do
			WindowFunctions[Functions] = nil
		end

		table_clear(Commands) table_clear(Library) table_clear(WindowFunctions)
	end

	function WindowFunctions:CreateNotification(Title, Text, Duration)
	    return Library:CreateNotification(Title, Text, Duration)
	end

	function WindowFunctions:AddCommand(Name, Arguments, Description, Callback)
		Commands[Name] = {
			Name = Name,
			Arguments = Arguments,
			Description = Description,
			Callback = Callback
		}

		local function Highlight(String, Color)
			return string_format('<font color = "rgb(%d, %d, %d)">%s</font>', Color.r * 255, Color.g * 255, Color.b * 255, String)
		end

		local function ConstructString(Highlighted)
			if Highlighted then
				local String = '' .. Highlight(Name, Library.Theme.PrimaryTextColor) .. ' '
				for _, Argument in next, Arguments do
					String = String .. Highlight('{' .. Argument .. '}', Library.Theme.SecondaryTextColor) .. ' '
				end
				String = String .. Highlight('| ', Library.Theme.AccentColor) .. Highlight(Description, Library.Theme.SecondaryTextColor)
				return String
			else
				local String = Name .. ' '
				for _, Argument in next, Arguments do
					String = String .. '{' .. Argument .. '}' .. ' '
				end
				String = String .. '| ' .. Description
				return String
			end
		end

		Library:Create('Frame', {
			Parent = CommandsHolderScrolling,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.25,
			Name = Name .. 'CommandHolder',
			Size = UDim2_new(0, 490, 0, 30)
		}, {
			Library:Create('UICorner', {
				CornerRadius = UDim_new(0, 5),
				Name = Name .. 'CommandsHolderCorner'
			}),
			Library:Create('TextLabel', {
				Name = Name .. 'Text',
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 1,
				TextTransparency = 0,
				BorderSizePixel = 0,
				RichText = true,
				Size = UDim2_new(0, 490, 0, 30),
				Font = FontFace,
				Text = ConstructString(true),
				TextColor3 = Theme.PrimaryTextColor,
				TextSize = 15,
				ZIndex = 2,
				TextXAlignment = Enum_TextXAlignment_Left
			}, {
				Library:Create('UIPadding', {
					PaddingLeft = UDim_new(0, 5),
					Name = Name .. 'Padding'
				})
			}),
			Library:Create('TextButton', {
				Name = Name .. 'Button',
				Size = UDim2_new(0, 490, 0, 30),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				ZIndex = 100,
				Text = ''
			}, {
				Library:Create('UICorner', {
					CornerRadius = UDim_new(0, 5),
					Name = Name .. 'ButtonCorner'
				})
			})
		})

		local CommandHolder = CommandsHolderScrolling[Name .. 'CommandHolder']
		local Button = CommandHolder[Name .. 'Button']

		local ButtonClicked = Button.MouseButton1Down:Connect(function()
			Library.ExecuteQueued = true
			Library:Tween(CommandHolder, {BackgroundColor3 = Library:Lighten(Theme.BackgroundColor)}, 0.25)

			task_wait(0.25)
			pcall(Execute, Name)
			Library:Tween(CommandHolder, {BackgroundColor3 = Theme.BackgroundColor}, 0.25)
		    
			Library.ExecuteQueued = false
		end)
		table_insert(Library.Connections, ButtonClicked)

		local MouseEntered = CommandHolder.MouseEnter:Connect(function()
			Library:Tween(CommandHolder, {BackgroundColor3 = Library:Lighten(Theme.BackgroundColor)}, 0.25)
			CreateToolTip(ConstructString(true), ConstructString(false), true)
		end)
		table_insert(Library.Connections, MouseEntered)

		local MouseLeft = CommandHolder.MouseLeave:Connect(function()
			Library:Tween(CommandHolder, {BackgroundColor3 = Theme.BackgroundColor}, 0.25)
			CreateToolTip(nil, nil, false)
		end)
		table_insert(Library.Connections, MouseLeft)
	end
	
	function WindowFunctions:NewSection(Name)
		Library:Create('Frame', {
			Parent = CommandsHolderScrolling,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Name = 'Seperation',
			Size = UDim2_new(0, 490, 0, 30)
		}, {
			Library:Create('TextLabel', {
				Name = Name .. 'Text',
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 1,
				TextTransparency = 0,
				BorderSizePixel = 0,
				RichText = true,
				Size = UDim2_new(0, 490, 0, 18),
				Position = UDim2_new(0 ,0, 0.28, 0),
				Font = FontFace,
				Text = Name,
				TextColor3 = Theme.PrimaryTextColor,
				TextSize = 15,
				ZIndex = 2,
				TextXAlignment = Enum_TextXAlignment_Left
			}, {
				Library:Create('UIPadding', {
					PaddingLeft = UDim_new(0, 5),
					Name = Name .. 'Padding'
				})
			}),
		})
	end

	return WindowFunctions
end

local game = game;

if not game:IsLoaded() then
    game.Loaded:Wait();
end

local Project = "Example Usage";

local Window = Library:CreateWindow({
    Name = Project,
    Theme =  Library.Themes.Dark,
	--Config = "Luarmor/yeah/ModuleCommand.json",
    Position = 'bottom',
    Prefix = ";";
})

Window:NewSection('Main');

Window:AddCommand('Theme', {'Theme'}, 'Dark, Light, Red, Orange, Purple, Blue, Nordic, Krnl', function(Arguments, Speaker)
    local Theme = Arguments[1]

    if Theme then
        local Name = Theme:sub(1,1):upper() .. Theme:sub(2):lower()

        if Library.Themes[Name] then
            Window:ChangeTheme(Name); Window:SaveTheme(Name)
        else
            Window:CreateNotification(Project, "Theme not found")
        end
    end
end)

Window:AddCommand('Prefix', {'Key'}, 'Changes the Prefix.', function(Arguments, Speaker)
    local NewPrefix = Arguments[1]

    if not NewPrefix or #NewPrefix ~= 1 then
        Window:CreateNotification(Project, 'Prefix must be a single character!')
        return
    end

    local byte = string.byte(NewPrefix)

    if (byte >= 97 and byte <= 122) or (byte >= 65 and byte <= 90) or (byte >= 48 and byte <= 57) or byte == 39 or byte == 34 or byte == 92 or byte == 59 or byte == 91 or byte == 93 or byte == 46 or byte == 44 or byte == 47 or byte == 96 or byte == 45 or byte == 61 then
        Window:ChangePrefix(NewPrefix)
		Window:SavePrefix(NewPrefix)

        Window:CreateNotification(Project, 'Your new Prefix is ' .. NewPrefix)
    else
        Window:CreateNotification(Project, 'Invalid prefix!')
    end
end)

Window:AddCommand('Serverhop', {}, 'Serverhops for you.', function(Arguments, Speaker)
    Window:CreateNotification(Project, 'Attempts to serverhop you...')
	loadstring(game:HttpGet("https://pastebin.com/raw/UTDqLRxP"))();
end)

Window:AddCommand('Unload', {}, 'Unloads the Framework', function(Arguments, Speaker)
    Window:Unload()
end)

Window:AddCommand('Ungee', {}, 'Unloads the Framework', function(Arguments, Speaker)
    warn("a")
end)

return Library
