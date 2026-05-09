local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

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

-- // @Modules
local Library, Commands = {}, {}

Library.ThemeManager = "Example_Theme.txt"

local function LoadTheme()
    if readfile and isfile and isfile(Library.ThemeManager) then
        local SavedTheme = HttpService:JSONDecode(readfile(Library.ThemeManager))
        return SavedTheme
    end
    return nil
end

local function SaveTheme(ThemeName)
    if writefile then
        local json = HttpService:JSONEncode(ThemeName)
        writefile(Library.ThemeManager, json)
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
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
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
	function Library:Log(Type, Message)
		Type = Type:lower()

		if Type == 'error' then
			error('[ @Visual ] Error: ' .. Message)
		elseif Type == 'log' then
			print('[ @Visual ] ' .. Message)
		elseif Type == 'warn' then
			warn('[ @Visual ] Warning: ' .. Message)
		end
	end

	function Library:RandomString(Length)
		local Length = Length or 15
		local Characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
		local RandomString = ""
		
		for i = 1, Length do
			local RandomIndex = math.random(1, #Characters)
			RandomString = RandomString .. string.sub(Characters, RandomIndex, RandomIndex)
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
		local Object = Instance.new(InstanceName)
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

		V = math.clamp(V + 0.03, 0, 1)

		return Color3.fromHSV(H, S, V)
	end

	function Library:Darken(Color)
		local H, S, V = Color:ToHSV()

		V = math.clamp(V - 0.35, 0, 1)

		return Color3.fromHSV(H, S, V)
	end

	function Library:StringToKeyCode(String)
		local Byte = string.byte(String)

		for _, KeyCode in next, Enum.KeyCode:GetEnumItems() do
			if KeyCode.Value == Byte then
				return KeyCode
			end
		end
	end

	function Library:KeyCodeToString(KeyCode)
		if KeyCode.Value < 127 and KeyCode.Value > 33 then
			return string.char(KeyCode.Value)
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
                    Library:Tween(Main, { Size = UDim2.new(0, 500, 0, 0) }, 0.25)
                end
            end

            local ToolTip = UI:FindFirstChild("ToolTip")

            if ToolTip and type(Library.Tween) == "function" then
                Library:Tween(ToolTip, { BackgroundTransparency = 1 }, 0.25)
            end

            task.wait(0.25)
            UI:Destroy()
            return
        end
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
            if string.find(Notification.Name, 'Notification') then
                Amount += 1
            end
        end
        return Amount
    end

    task.spawn(function()
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
            Position = UDim2.new(1, 300, 1, -30),
            Size = UDim2.new(0, 300, 0, 50),
            BackgroundTransparency = 0,
            AnchorPoint = Vector2.new(1, 1)
        }, {
            Library:Create('UICorner', {
                CornerRadius = UDim.new(0, 5),
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
                Position = UDim2.new(0, 0, 0, -1),
                Size = UDim2.new(0, 300, 0, 30),
                Font = Enum.Font.Gotham,
                Text = TitleText,
                TextColor3 = Library.Theme.PrimaryTextColor,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            }, {
                Library:Create('UIPadding', {
                    Name = 'NotificationTitlePadding',
                    PaddingLeft = UDim.new(0, 7)
                })
            }),
            Library:Create('TextLabel', {
                Name = 'NotificationText',
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(0, 300, 0, 30),
                Font = Enum.Font.Gotham,
                Text = MessageText,
                TextWrapped = true,
                TextColor3 = Library.Theme.SecondaryTextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            }, {
                Library:Create('UIPadding', {
                    Name = 'NotificationTextPadding',
                    PaddingLeft = UDim.new(0, 7)
                })
            })
        })

        table.insert(Library.ActiveNotifications, Notification)

        local TitleLabel = Notification.NotificationTitle
        local MessageLabel = Notification.NotificationText
        local TextSize = TextService:GetTextSize(MessageText, 14, Enum.Font.Gotham, Vector2.new(300, math.huge))

        Notification.Size = UDim2.new(0, 300, 0, TextSize.Y + 30)
        MessageLabel.Size = UDim2.new(0, 300, 0, TextSize.Y)

        local NotifCount = NotificationCount()

        if NotifCount > 1 then
            local PreviousSizes = 0
            for _, ExistingNotif in next, Container:GetChildren() do
                if string.find(ExistingNotif.Name, 'Notification') and ExistingNotif ~= Notification and ExistingNotif.Position.X == UDim.new(1, -30) then
                    PreviousSizes = PreviousSizes + ExistingNotif.AbsoluteSize.Y + 5
                end
            end
            Notification.Position = UDim2.new(1, 300, 1, -30 - PreviousSizes)
            if type(Library.Tween) == "function" then
                Library:Tween(Notification, { Position = UDim2.new(1, -30, 1, -30 - PreviousSizes) }, 0.25)
            end
        else
            if type(Library.Tween) == "function" then
                Library:Tween(Notification, { Position = UDim2.new(1, -30, 1, -30) }, 0.25)
            end
        end

        task.wait(Timeout - 0.5)

        if type(Library.Tween) == "function" then
            Library:Tween(Notification, { BackgroundTransparency = 0.8 }, 0.25)
            Library:Tween(TitleLabel, { TextTransparency = 0.5 }, 0.25)
            Library:Tween(MessageLabel, { TextTransparency = 0.5 }, 0.25)
        end

        task.wait(0.25)

        if type(Library.Tween) == "function" then
            Library:Tween(Notification, { Position = UDim2.new(1, 300, 1, Notification.Position.Y.Offset) }, 0.25)
        end

        task.wait(0.25)

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
            if string.find(ExistingNotif.Name, 'Notification') and ExistingNotif ~= Notification then
                table.insert(RemainingNotifs, ExistingNotif)
            end
        end

        for i, Notif in ipairs(RemainingNotifs) do
            local NewY = -30 - ((i - 1) * (Notif.AbsoluteSize.Y + 5))
            if type(Library.Tween) == "function" then
                Library:Tween(Notif, { Position = UDim2.new(1, -30, 1, NewY) }, 0.25)
            end
        end
    end)
end

-- // @Library Themes
Library.Transparency = 0

Library.Themes = {
	['dark'] = {
		BackgroundColor = Color3.fromRGB(40, 40, 40),
		SecondaryColor = Color3.fromRGB(50, 50, 50),
		AccentColor = Color3.fromRGB(100, 100, 100),
		PrimaryTextColor = Color3.fromRGB(255, 255, 255),
		SecondaryTextColor = Color3.fromRGB(175, 175, 175)
	},
	['light'] = {
		BackgroundColor = Color3.fromRGB(255, 255, 255),
		SecondaryColor = Color3.fromRGB(225, 225, 225),
		AccentColor = Color3.fromRGB(125, 125, 125),
		PrimaryTextColor = Color3.fromRGB(0, 0, 0),
		SecondaryTextColor = Color3.fromRGB(75, 75, 75)
	},
	['red'] = {
		BackgroundColor = Color3.fromRGB(0, 0, 0),
		PrimaryTextColor = Color3.fromRGB(255, 255, 255),
		SecondaryTextColor = Color3.fromRGB(135, 135, 135),
		AccentColor = Color3.fromRGB(255, 0, 0),
		SecondaryColor = Color3.fromRGB(50, 50, 50)
	},
	['nordic'] = {
		BackgroundColor = Color3.fromRGB(25, 30, 35),
		PrimaryTextColor = Color3.fromRGB(255, 255, 255),
		SecondaryTextColor = Color3.fromRGB(135, 135, 135),
		AccentColor = Color3.fromRGB(50, 60, 70),
		SecondaryColor = Color3.fromRGB(50, 55, 60)
	},
	['purple'] = {
		BackgroundColor = Color3.fromRGB(30, 30, 45),
		PrimaryTextColor = Color3.fromRGB(255, 255, 255),
		SecondaryTextColor = Color3.fromRGB(135, 135, 135),
		AccentColor = Color3.fromRGB(60, 60, 80),
		SecondaryColor = Color3.fromRGB(60, 60, 80)
	},
	['krnl'] = {
		BackgroundColor = Color3.fromRGB(40, 40, 40),
		PrimaryTextColor = Color3.fromRGB(255, 255, 255),
		SecondaryTextColor = Color3.fromRGB(125, 125, 125),
		AccentColor = Color3.fromRGB(60, 60, 60),
		SecondaryColor = Color3.fromRGB(40, 40, 40)
	},
	['blue'] = {
		BackgroundColor = Color3.fromRGB(30, 30, 30),
		PrimaryTextColor = Color3.fromRGB(0, 125, 255),
		SecondaryTextColor = Color3.fromRGB(255, 255, 255),
		AccentColor = Color3.fromRGB(0, 125, 255),
		SecondaryColor = Color3.fromRGB(45, 45, 45)
	},
	['orange'] = {
		BackgroundColor = Color3.fromRGB(35, 35, 35),
		PrimaryTextColor = Color3.fromRGB(255, 255, 255),
		SecondaryTextColor = Color3.fromRGB(135, 135, 135),
		AccentColor = Color3.fromRGB(255, 170, 60),
		SecondaryColor = Color3.fromRGB(50, 50, 50)
	}
}

Library.Prefix = Library:StringToKeyCode(';')
Library.Theme = nil

function Library:CreateWindow(Properties)
	-- // @Properties
	local Name = Library:GetProperty('Window', 'Name', Properties) or Library:RandomString(15)
	local Theme = Library:GetProperty('Window', 'Theme', Properties) or Library.Themes.dark
	local Position = string.lower(Library:GetProperty('Window', 'Position', Properties)) or 'top'
	local Prefix = Library:StringToKeyCode(Library:GetProperty('Window', 'Prefix', Properties)) or Library:StringToKeyCode(';')

	Library.Prefix = Prefix
	Library.Instance = Library:RandomString(15)

	local Load = LoadTheme()

	if Load and Library.Themes[Load] then
		Library.Theme = Library.Themes[Load]
		Theme = Library.Theme
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
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 0, 0, 0)
		}, {
			Library:Create('UIStroke', {
				Name = 'MainStroke',
				ApplyStrokeMode = 'Contextual',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 1
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim.new(0, 5),
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

	Library:Tween(Main, {Size = UDim2.new(0, 500, 0, 65)}, 0.25)
	Library:Tween(Main, {BackgroundTransparency = 0}, 0.25)
	MainStroke.Thickness = 1

	task.wait(0.5)

	if Position == 'top' then
		Main.AnchorPoint = Vector2.new(0.5, 0)
		Library:Tween(Main, {Position = UDim2.new(0.5, 0, 0, -72)}, 0.25)
	elseif Position == 'topleft' then
		Main.AnchorPoint = Vector2.new(0, 0)
		Library:Tween(Main, {Position = UDim2.new(0, 0, 0, -72)}, 0.25)
	elseif Position == 'topright' then
		Main.AnchorPoint = Vector2.new(1, 0)
		Library:Tween(Main, {Position = UDim2.new(1, 0, 0, -72)}, 0.25)
	elseif Position == 'bottomleft' then
		Main.AnchorPoint = Vector2.new(0, 1)
		Library:Tween(Main, {Position = UDim2.new(0, 0, 1, 36)}, 0.25)
	elseif Position == 'bottom' then
		Main.AnchorPoint = Vector2.new(0.5, 1)
		Library:Tween(Main, {Position = UDim2.new(0.5, 0, 1, 36)}, 0.25)
	elseif Position == 'bottomright' then
		Main.AnchorPoint = Vector2.new(1, 1)
		Library:Tween(Main, {Position = UDim2.new(1, 0, 1, 36)}, 0.25)
	end

	if string.find(Position, 'top') then
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			Name = 'Filler1',
			BackgroundTransparency = 0,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			Name = 'Filler2',
			BackgroundTransparency = 0,
			Position = UDim2.new(0, 495, 0, 0),
			Size = UDim2.new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			Name = 'Line1',
			BackgroundTransparency = 0,
			Position = UDim2.new(0, -1, 0, 0),
			Size = UDim2.new(0, 1, 0, 10)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			Name = 'Line2',
			BackgroundTransparency = 0,
			Position = UDim2.new(0, 500, 0, 0),
			Size = UDim2.new(0, 1, 0, 10)
		})
	else
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Filler1',
			Position = UDim2.new(0, 0, 0, 60),
			Size = UDim2.new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Filler2',
			Position = UDim2.new(0, 495, 0, 60),
			Size = UDim2.new(0, 5, 0, 5)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Line1',
			Position = UDim2.new(0, -1, 0, 60),
			Size = UDim2.new(0, 1, 0, 10)
		})
		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.AccentColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			Name = 'Line2',
			Position = UDim2.new(0, 500, 0, 60),
			Size = UDim2.new(0, 1, 0, 10)
		})
	end

	if string.find(Position, 'bottom') then
		Library:Create('TextBox', {
			Font = Enum.Font.Gotham,
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
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = false,
			Name = 'CommandInput',
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -5),
			Size = UDim2.new(0, 490, 0, 30)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandInputStroke',
				ApplyStrokeMode = 'Border',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 0
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim.new(0, 5),
				Name = 'CommandInputCorner'
			}),
			Library:Create('UIPadding', {
				PaddingLeft = UDim.new(0, 5),
				Name = 'CommandInputPadding'
			}),
		})

		Library:Create('TextLabel', {
			Name = 'Title',
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Position = UDim2.new(0, 0, 0, 4),
			Size = UDim2.new(0, 250, 0, 20),
			Font = Enum.Font.Gotham,
			BorderSizePixel = 0, 
			Text = Name,
			TextColor3 = Theme.PrimaryTextColor,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			Library:Create('UIPadding', {
				Name = 'TitlePadding',
				PaddingLeft = UDim.new(0, 7)
			})
		})

		Library:Create('TextButton', {
			Name = 'CloseButton',
			Position = UDim2.new(0, 475, 0, 4),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundColor3 = Theme.BackgroundColor,
			TextColor3 = Theme.PrimaryTextColor,
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Parent = Main,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSizePixel = 0,
			TextSize = 30,
			Text = '≡'
		}, {
			Library:Create('UICorner', {
				Name = 'CloseButtonCorner',
				CornerRadius = UDim.new(0, 5)
			})
		})

		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.5,
			Name = 'CommandsHolder',
			Visible = false,
			Position = UDim2.new(0, 0, 0, -305),
			Size = UDim2.new(0, 500, 0, 300)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandsHolderStroke',
				ApplyStrokeMode = 'Contextual',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 1
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim.new(0, 5),
				Name = 'CommandsHolderCorner'
			}),
			Library:Create('ScrollingFrame', {
				BackgroundColor3 = Theme.BackgroundColor,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ScrollBarThickness = 1,
				ScrollBarImageColor3 = Theme.AccentColor,
				Name = 'CommandsHolderScrolling',
				Position = UDim2.new(0, 0, 0, 5),
				Size = UDim2.new(0, 500, 0, 290)
			}, {
				Library:Create('UIListLayout', {
					Name = 'CommandsHolderScrollingListLayout',
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 3)
				}),
				Library:Create('Frame', {
					Name = 'UnclipTop',
					BorderSizePixel = 0,
					LayoutOrder = -999999999,
					Size = UDim2.new(0, 0, 0, -7),
					BackgroundTransparency = 1
				})
			})
		})
	else
		Library:Create('TextBox', {
			Font = Enum.Font.Gotham,
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
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = false,
			Name = 'CommandInput',
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 5),
			Size = UDim2.new(0, 490, 0, 30)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandInputStroke',
				ApplyStrokeMode = 'Border',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 0
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim.new(0, 5),
				Name = 'CommandInputCorner'
			}),
			Library:Create('UIPadding', {
				PaddingLeft = UDim.new(0, 5),
				Name = 'CommandInputPadding'
			}),
		})

		Library:Create('TextLabel', {
			Name = 'Title',
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Position = UDim2.new(0, 0, 0, 40),
			Size = UDim2.new(0, 250, 0, 20),
			Font = Enum.Font.Gotham,
			BorderSizePixel = 0, 
			Text = Name,
			TextColor3 = Theme.PrimaryTextColor,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			Library:Create('UIPadding', {
				Name = 'TitlePadding',
				PaddingLeft = UDim.new(0, 7)
			})
		})

		Library:Create('TextButton', {
			Name = 'CloseButton',
			Position = UDim2.new(0, 475, 0, 40),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundColor3 = Theme.BackgroundColor,
			TextColor3 = Theme.PrimaryTextColor,
			AutoButtonColor = false,
			Font = Enum.Font.Gotham,
			Parent = Main,
			TextYAlignment = Enum.TextYAlignment.Center,
			BorderSizePixel = 0,
			TextSize = 30,
			Text = '≡'
		}, {
			Library:Create('UICorner', {
				Name = 'CloseButtonCorner',
				CornerRadius = UDim.new(0, 5)
			}),
		})

		local IsInCommandsHolder = false
		local HoverDebounce = false
		
		local CommandEntered = CommandsHolder.MouseEnter:Connect(function()
		    IsInCommandsHolder = true
		end)
		table.insert(Library.Connections, CommandEntered)

		local CommandLeft = CommandsHolder.MouseLeave:Connect(function()
		    IsInCommandsHolder = false
		end)
		table.insert(Library.Connections, CommandLeft)

		Library:Create('Frame', {
			Parent = Main,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
			Visible = false,
			BackgroundTransparency = 1,
			Name = 'CommandsHolder',
			Position = UDim2.new(0, 0, 0, 70),
			Size = UDim2.new(0, 500, 0, 300)
		}, {
			Library:Create('UIStroke', {
				Name = 'CommandsHolderStroke',
				ApplyStrokeMode = 'Contextual',
				Color = Theme.AccentColor,
				LineJoinMode = 'Round',
				Thickness = 1
			}),
			Library:Create('UICorner', {
				CornerRadius = UDim.new(0, 5),
				Name = 'CommandsHolderCorner'
			}),
			Library:Create('ScrollingFrame', {
				BackgroundColor3 = Theme.BackgroundColor,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				ScrollBarThickness = 1,
				ScrollBarImageColor3 = Theme.AccentColor,
				Name = 'CommandsHolderScrolling',
				Position = UDim2.new(0, 0, 0, 5),
				Size = UDim2.new(0, 500, 0, 290)
			}, {
				Library:Create('UIListLayout', {
					Name = 'CommandsHolderScrollingListLayout',
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 3)
				}),
				Library:Create('Frame', {
					Name = 'UnclipTop',
					BorderSizePixel = 0,
					LayoutOrder = -999999999,
					Size = UDim2.new(0, 0, 0, -7),
					BackgroundTransparency = 1
				})
			})
		})
	end

	Library:Create('TextLabel', {
		Name = 'ToolTip',
		Parent = Container,
		BackgroundColor3 = Theme.BackgroundColor,
		BackgroundTransparency = 0,
		TextTransparency = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		RichText = true,
		ZIndex = 100,
		Text = '',
		Font = Enum.Font.Gotham,
		BorderSizePixel = 0, 
		TextColor3 = Theme.PrimaryTextColor,
		TextSize = 15
	}, {
		Library:Create('UICorner', {
			Name = 'ToolTipCorner',
			CornerRadius = UDim.new(0, 5)
		}),
		Library:Create('UIPadding', {
			Name = 'ToolTipPadding',
			PaddingLeft = UDim.new(0, 3),
			PaddingTop = UDim.new(0, 3)
		}),
		Library:Create('UIStroke', {
			Name = 'ToolTipStroke',
			ApplyStrokeMode = 'Border',
			Color = Theme.AccentColor,
			LineJoinMode = 'Round',
			Thickness = 1
		})
	})

	task.wait(0.25)

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
	table.insert(Library.Connections, Entered)

	local Left = CloseButton.MouseLeave:Connect(function()
		Library:Tween(CloseButton, {TextColor3 = Theme.PrimaryTextColor}, 0.25)
	end)
	table.insert(Library.Connections, Left)
	
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
			Library:Tween(CommandsHolder, {Size = UDim2.new(0, 500, 0, 0)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {Size = UDim2.new(0, 500, 0, Size)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {CanvasSize = UDim2.new(0, 500, 0, Size)}, 0.25)

		elseif Count < 9 then
			Library:Tween(CommandsHolder, {Size = UDim2.new(0, 500, 0, Size + 10)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {Size = UDim2.new(0, 500, 0, Size)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {CanvasSize = UDim2.new(0, 500, 0, Size)}, 0.25)

			if string.find(Position, 'bottom') then
				if Main.Position.Y == UDim.new(1, 1) or Main.Position.Y == UDim.new(1, 0) or Main.Position.Y == UDim.new(1, 2) or Main.Position.Y == UDim.new(0, -37) then
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset - Size - 13)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset - Size + 22)}, 0.25)
				end
			else
				if Main.Position.Y == UDim.new(1, 36) or Main.Position.Y == UDim.new(0, -72) then
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset - 3)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset + 33)}, 0.25)
				end
			end
		else
			Library:Tween(CommandsHolder, {Size = UDim2.new(0, 500, 0, 270)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {Size = UDim2.new(0, 500, 0, 260)}, 0.25)
			Library:Tween(CommandsHolderScrolling, {CanvasSize = UDim2.new(0, 500, 0, Size)}, 0.25)

			if string.find(Position, 'bottom') then
				if Main.Position.Y == UDim.new(1, 1) or Main.Position.Y == UDim.new(1, 0) or Main.Position.Y == UDim.new(1, 2) or Main.Position.Y == UDim.new(0, -37) then
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset - 273)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset - 237)}, 0.25)
				end
			else
				if Main.Position.Y == UDim.new(1, 36) or Main.Position.Y == UDim.new(0, -72) then
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset - 3)}, 0.25)
				else
					Library:Tween(CommandsHolder, {Position = UDim2.new(0, 0, 0, -Main.Position.Y.Offset + 33)}, 0.25)
				end
			end
		end
	end
	
	local function UpdateNotifications()
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

	local function OpenList()
		if Main.Position.Y == UDim.new(1, 37) or Main.Position.Y == UDim.new(1, 36) or Main.Position.Y == UDim.new(0, -72) then
			UpdateFrameSizes()
			CommandInput:CaptureFocus()
			
			local moveOffset = string.find(Position, 'bottom') and -36 or 36
			Library:Tween(Main, {Position = Main.Position + UDim2.new(0, 0, 0, moveOffset)}, 0.25)
			
			task.wait(0.1)

			CommandsHolder.Visible = true
			Library:Tween(CommandsHolder, {BackgroundTransparency = 0.25}, 0.2)
			
			task.wait(0.1)
			
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
		if not HoverDebounce then
			task.spawn(function()
				HoverDebounce = true
				task.wait(0.5)
				HoverDebounce = false 
			end)

			if Main.Position.Y == UDim.new(1, 0) or Main.Position.Y == UDim.new(0, -36) then
				local isBottom = string.find(Position, 'bottom')
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

				task.wait(0.1)

				if type(Library.Tween) == "function" then
					Library:Tween(CommandsHolder, {BackgroundTransparency = 1}, 0.25)
					Library:Tween(Main, {Position = Main.Position + UDim2.new(0, 0, 0, isBottom and 36 or -36)}, 0.3)
				end
				task.wait(0.1)
				CommandsHolder.Visible = false
			end
		end
	end

	local Added = CommandsHolderScrolling.ChildAdded:Connect(UpdateFrameSizes)
	local Removed = CommandsHolderScrolling.ChildRemoved:Connect(UpdateFrameSizes)

	table.insert(Library.Connections, Added)
	table.insert(Library.Connections, Removed)

    local Clicked = CloseButton.MouseButton1Down:Connect(OpenList)
	table.insert(Library.Connections, Clicked)

	-- // @Prefix
	local Pressed = UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
		if not GameProcessedEvent and Input.KeyCode.Name == Library.Prefix.Name then
			OpenList()
		end
	end)
	table.insert(Library.Connections, Pressed)

	-- // @Execute Command
	local function Execute(String)
		local Split = String:split(' ')
		local Arguments = {}
		local First = Split[1]:lower():gsub(Library:KeyCodeToString(Library.Prefix), '')

		CommandInput.Text = ''
		
		local Command = Commands[First]
		if not Command then 
			Library:CreateNotification("Validator.exe", 'Command Not Found: ' .. First)
			CloseList()
			Library:Log('Error', 'Command Not Found: ' .. First)
			return
		end

		local NumberOfArguments = #Command.Arguments

		for Index, Argument in next, Split do
			if Index > 1 then
				table.insert(Arguments, Argument)
			end
		end

		if NumberOfArguments > #Arguments then
			local Missing = ''
			for Index = 1, NumberOfArguments do
				if not Arguments[Index] then
					Missing = Missing .. tostring(Command.Arguments[Index])
				end
			end

			Library:CreateNotification("Validator.exe", 'Missing Arguments: ' .. Missing .. ' | Command: ' .. First)
			CloseList()

			Library:Log('Error', 'Missing Arguments: ' .. Missing .. ' | Command: ' .. First)
		else
			task.spawn(Command.Callback, Arguments, LocalPlayer)
			CloseList()
		end
	end

	-- // @Search Commands
	local Changed = CommandInput:GetPropertyChangedSignal('Text'):Connect(function()
		if CommandInput.Text == '' then
			for _, Instance in next, CommandsHolderScrolling:GetChildren() do
				if not Instance:IsA('UIListLayout') then
					Instance.Visible = true
					UpdateFrameSizes()
				end
			end
		else
			local Split = CommandInput.Text:split()
			local Full = ''

			for Index, String in next, Split do
				if Index == 1 then
					Full = Full .. Split[1]:gsub(Library:KeyCodeToString(Library.Prefix), '')
				else
					Full = Full .. Split[Index]
				end
			end

			CommandInput.Text = Full

			for _, Instance in next, CommandsHolderScrolling:GetChildren() do
				if not Instance:IsA('UIListLayout') then
					if string.find(Instance.Name:gsub('CommandHolder', ''):lower(), CommandInput.Text:lower()) then
						Instance.Visible = true
					else
						Instance.Visible = false
					end
					UpdateFrameSizes()
				end
			end
		end
	end)
	table.insert(Library.Connections, Changed)

	-- // @Command Entered
	local LostFocus = CommandInput.FocusLost:Connect(function()
		if not IsInCommandsHolder then
			if Main.Position.Y == UDim.new(1, 0) or Main.Position.Y == UDim.new(0, -36) then
				if CommandInput.Text ~= '' then
					task.spawn(function()
					    if Library and Library.Prefix then
						    Execute(CommandInput.Text)
						end
					end)
				end

				CloseList()
			end
		end
	end)
	table.insert(Library.Connections, LostFocus)

	-- // @Tool Tips
	function CreateToolTip(Text, Clone, Enabled)
		local ToolTip = Container.ToolTip
		if not ToolTip then return end

		if Enabled then
			local Size = TextService:GetTextSize(Clone, ToolTip.TextSize, ToolTip.Font, Vector2.new(300, math.huge))
			Library:Tween(ToolTip, {Size = UDim2.new(0, Size.X + 5, 0, Size.Y + 5)}, 0.25)

			if ToolTip.Visible then
				RunService:UnbindFromRenderStep('ToolTip')
				ToolTip.Visible = false
			end

			RunService:BindToRenderStep('ToolTip', 1, function()
				local MouseLocation = UserInputService:GetMouseLocation()
				local ViewportSize = Workspace.CurrentCamera.ViewportSize
				local NewPosition = UDim2.new(MouseLocation.X / ViewportSize.X, 0, MouseLocation.Y / ViewportSize.Y, 0)
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

	-- function WindowFunctions:IsLoaded()
		-- return Library.ScreenGui ~= nil and Library.ScreenGui.Parent ~= nil
	-- end

	function WindowFunctions:ChangePrefix(Prefix)
		Library.Prefix = Library:StringToKeyCode(Prefix)
	end

	function WindowFunctions:AddTheme(Name, Theme)
		if Library.Themes[Name] then
			Library:Log('Error', 'A Theme Already Exists With The Name' .. Name)
		else
			Library.Themes[Name:lower()] = Theme
		end
	end

	function WindowFunctions:GetThemes(Names)
		if Names then
			local Table = {}
			for Index, Theme in next, Library.Themes do
				table.insert(Table, Index)
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
				if child:IsA("Frame") and child.Name and string.find(child.Name, 'CommandHolder') then
					child.BackgroundColor3 = Library.Theme.BackgroundColor
					local textLabel = child:FindFirstChild(child.Name:gsub('CommandHolder', 'Text'))
					if textLabel then
						textLabel.BackgroundColor3 = Library.Theme.BackgroundColor
						textLabel.TextColor3 = Library.Theme.PrimaryTextColor
						
						local cmdName = child.Name:gsub('CommandHolder', '')
						local cmdData = Commands[cmdName:lower()]
						if cmdData then
							local function Highlight(str, col)
								return string.format('<font color="rgb(%d, %d, %d)">%s</font>', col.r*255, col.g*255, col.b*255, str)
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
					if child:IsA("Frame") and child.Name and string.find(child.Name, 'CommandHolder') then
						child.BackgroundColor3 = Library.Theme.BackgroundColor
						local textLabel = child:FindFirstChild(child.Name:gsub('CommandHolder', 'Text'))
						if textLabel then
							textLabel.BackgroundColor3 = Library.Theme.BackgroundColor
							textLabel.TextColor3 = Library.Theme.PrimaryTextColor
							
							local cmdName = child.Name:gsub('CommandHolder', '')
							local cmdData = Commands[cmdName:lower()]
							if cmdData then
								local function Highlight(str, col)
									return string.format('<font color="rgb(%d, %d, %d)">%s</font>', col.r*255, col.g*255, col.b*255, str)
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
			else
				Library:Log('Error', 'Theme Doesn\'t exist: ' .. NewTheme)
			end
		end
	end

	function WindowFunctions:SaveTheme(ThemeName)
	    SaveTheme(ThemeName)
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

		table.clear(Commands) table.clear(Library) table.clear(WindowFunctions)
	end

	function WindowFunctions:CreateNotification(Title, Text, Duration)
	    return Library:CreateNotification(Title, Text, Duration)
	end

	function WindowFunctions:AddCommand(Name, Arguments, Description, Callback)
		Commands[Name:lower()] = {
			Name = Name:lower(),
			Arguments = Arguments,
			Description = Description,
			Callback = Callback
		}

		local function Highlight(String, Color)
			return string.format('<font color = "rgb(%d, %d, %d)">%s</font>', Color.r * 255, Color.g * 255, Color.b * 255, String)
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
			Size = UDim2.new(0, 490, 0, 30)
		}, {
			Library:Create('UICorner', {
				CornerRadius = UDim.new(0, 5),
				Name = Name .. 'CommandsHolderCorner'
			}),
			Library:Create('TextLabel', {
				Name = Name .. 'Text',
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 1,
				TextTransparency = 0,
				BorderSizePixel = 0,
				RichText = true,
				Size = UDim2.new(0, 490, 0, 30),
				Font = Enum.Font.Gotham,
				Text = ConstructString(true),
				TextColor3 = Theme.PrimaryTextColor,
				TextSize = 15,
				ZIndex = 2,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				Library:Create('UIPadding', {
					PaddingLeft = UDim.new(0, 5),
					Name = Name .. 'Padding'
				})
			}),
			Library:Create('TextButton', {
				Name = Name .. 'Button',
				Size = UDim2.new(0, 490, 0, 30),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				ZIndex = 100,
				Text = ''
			}, {
				Library:Create('UICorner', {
					CornerRadius = UDim.new(0, 5),
					Name = Name .. 'ButtonCorner'
				})
			})
		})

		local CommandHolder = CommandsHolderScrolling[Name .. 'CommandHolder']
		local Button = CommandHolder[Name .. 'Button']

		local ButtonClicked = Button.MouseButton1Down:Connect(function()
			Library:Tween(CommandHolder, {BackgroundColor3 = Library:Lighten(Theme.BackgroundColor)}, 0.25)

			task.wait(0.25)
			pcall(Execute, Name)
			Library:Tween(CommandHolder, {BackgroundColor3 = Theme.BackgroundColor}, 0.25)
		end)
		table.insert(Library.Connections, ButtonClicked)

		local MouseEntered = CommandHolder.MouseEnter:Connect(function()
			Library:Tween(CommandHolder, {BackgroundColor3 = Library:Lighten(Theme.BackgroundColor)}, 0.25)
			CreateToolTip(ConstructString(true), ConstructString(false), true)
		end)
		table.insert(Library.Connections, MouseEntered)

		local MouseLeft = CommandHolder.MouseLeave:Connect(function()
			Library:Tween(CommandHolder, {BackgroundColor3 = Theme.BackgroundColor}, 0.25)
			CreateToolTip(nil, nil, false)
		end)
		table.insert(Library.Connections, MouseLeft)
	end
	
	function WindowFunctions:NewSection(Name)
		Library:Create('Frame', {
			Parent = CommandsHolderScrolling,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Name = 'Seperation',
			Size = UDim2.new(0, 490, 0, 30)
		}, {
			Library:Create('TextLabel', {
				Name = Name .. 'Text',
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 1,
				TextTransparency = 0,
				BorderSizePixel = 0,
				RichText = true,
				Size = UDim2.new(0, 490, 0, 18),
				Position = UDim2.new(0 ,0, 0.28, 0),
				Font = Enum.Font.Gotham,
				Text = Name,
				TextColor3 = Theme.PrimaryTextColor,
				TextSize = 15,
				ZIndex = 2,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				Library:Create('UIPadding', {
					PaddingLeft = UDim.new(0, 5),
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
    Theme =  Library.Themes.dark,
    Position = 'bottom',
    Prefix = ";";
})

Window:NewSection('Main');

Window:AddCommand('Theme', {'Theme'}, 'Dark, Light, Red, Orange, Purple, Blue, Nordic, Krnl', function(Arguments, Speaker)
    local Theme = string.lower(Arguments[1])
    if Library.Themes[Theme] then
        Window:ChangeTheme(Theme); Window:SaveTheme(Theme)
    else
        Window:CreateNotification(Project, "Theme not found")
    end
end)

Window:AddCommand('Prefix', {'Key'}, 'Changes the Prefix.', function(Arguments, Speaker)
    local NewPrefix = Arguments[1]

    if not NewPrefix or #NewPrefix ~= 1 then
        Window:CreateNotification(Project, 'Prefix must be a single character!')
        return
    end

    local byte = string.byte(NewPrefix)

    if (byte >= 97 and byte <= 122) or (byte >= 48 and byte <= 57) or byte == 59 or byte == 47 or byte == 44 or byte == 46 then
        Window:ChangePrefix(NewPrefix)
        Window:CreateNotification(Project, 'Your new Prefix is ' .. NewPrefix)
    else
        Window:CreateNotification(Project, 'Invalid prefix!')
    end
end)

Window:AddCommand('Serverhop', {}, 'Serverhops for you.',function(Arguments, Speaker)
    Window:CreateNotification(Project, 'Attempts to serverhop you...')
	loadstring(game:HttpGet("https://pastebin.com/raw/UTDqLRxP"))();
end)


Window:AddCommand('Unload', {}, 'Unloads the Framework', function(Arguments, Speaker)
    Window:Unload()
end)

return Library
