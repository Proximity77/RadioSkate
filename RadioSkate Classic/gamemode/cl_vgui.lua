RS.Theme = {
		
	Log = {

		Color = Color( 142, 68, 173 )

	},
	Frame = {

		Head = {

			DrawText = {

				Color = Color( 236, 240, 241 )

			},
			Tall = 32,
			Color = Color( 32, 40, 48 )

		},
		Body = {

			Color = Color( 236, 240, 241 )

		},
		Panel = {

			Body = {

				Color = Color( 41, 128, 185 )

			}

		}

	},
	Panel = {

		Body = {

			Color = Color( 236, 240, 241 )

		}

	},
	List = {

		Head = {

			Tall = 32

		},
		Body = {

			Color = Color( 189, 195, 199 )

		}

	},
	Button = {

		Body = {

			Color = Color( 149, 165, 166 ),
			WarmColor0 = Color( 243, 156, 18 ),
			WarmColor1 = Color( 241, 196, 15 ),
			ColdColor0 = Color( 41, 128, 185 ),
			ColdColor1 = Color( 52, 152, 219 )

		}

	},
	Label = {

		DrawText = {

			Size = 4,
			Color = Color( 235, 240, 245 )

		}

	}

}

function CreateFrame( Structure, Parent )

	local Table = { }

	for Key, Value in pairs( Structure ) do

		Table[ Key ] = Value

	end

	Table.Frame = vgui.Create( "DFrame", Parent )
	Table.Frame:SetSize( Table.Wide, Table.Tall )
	Table.Frame:SetPos( Table.x, Table.y )
	Table.Frame:SetTitle( "" )
	Table.Frame:ShowCloseButton( false )
	Table.Frame:SetScreenLock( true )
	Table.Frame:SetDraggable( Table.Draggable ~= nil and Table.Draggable or true )
	Table.Frame:MakePopup()

	function Table.Frame:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Theme.Frame.Body.Color )

		DrawRectangle( 0, 0, Wide, RS.Theme.Frame.Head.Tall, RS.Theme.Frame.Head.Color )
		DrawText( Table.Title, RS.Theme.Label.DrawText.Size, Wide / 2, RS.Theme.Frame.Head.Tall / 2 + 1, RS.Theme.Frame.Head.DrawText.Color, 1, 1 )

	end

	if ( Table.Panel ) then

		Table.Panel = CreatePanel( {

			x = RS.InnerPadding,
			y = RS.Theme.Frame.Head.Tall + RS.InnerPadding,
			Wide = Table.Frame:GetWide() - RS.InnerPadding * 2,
			Tall = Table.Frame:GetTall() - RS.InnerPadding * 2 - RS.Theme.Frame.Head.Tall,
			Draw = true,
			BodyColor = RS.Theme.Frame.Panel.Body.Color

		}, Table.Frame )

	end

	Table.Button = CreateButton( {

		x = Table.Frame:GetWide() - RS.Theme.Frame.Head.Tall + RS.InnerPadding,
		y = RS.InnerPadding,
		Wide = RS.Theme.Frame.Head.Tall - RS.InnerPadding * 2,
		Tall = RS.Theme.Frame.Head.Tall - RS.InnerPadding * 2,
		DrawText = "=",
		CallBack = function()

			if ( Table.CallBack ) then

				Table.CallBack()

			end

			Table.Frame:Close()

		end

	}, Table.Frame )

	if ( Table.Extra ) then

		CreateButton( {

			x = RS.InnerPadding,
			y = RS.InnerPadding,
			Wide = Table.Button.Button:GetWide(),
			Tall = Table.Button.Button:GetTall(),
			DrawText = Table.Extra.DrawText,
			CallBack = function()

				Table.Extra.CallBack()

			end

		}, Table.Frame )

	end

	return Table

end

function CreatePanel( Structure, Parent )

	local Table = { }

	for Key, Value in pairs( Structure ) do

		Table[ Key ] = Value

	end

	Table.Panel = vgui.Create( "DPanel", Parent )
	Table.Panel:SetSize( Table.Wide, Table.Tall )
	Table.Panel:SetPos( Table.x, Table.y )

	Table.Draw = Table.Draw == nil and true or Table.Draw

	function Table.Panel:Paint( Wide, Tall )

		local Color = Table.BodyColor and Table.BodyColor or RS.Theme.Panel.Body.Color

		if ( Table.Draw ) then

			DrawRectangle( 0, 0, Wide, Tall, Color, Table.Gradient )

		end

	end

	return Table

end

function CreatePanelList( Structure, Parent )

	local Table = { }

	for Key, Value in pairs( Structure ) do

		Table[ Key ] = Value

	end

	Table.Panel = vgui.Create( "DPanelList", Parent )
	Table.Panel:SetSize( Table.Wide, Table.Tall )
	Table.Panel:SetPos( Table.x, Table.y )
	Table.Panel:SetPadding( RS.InnerPadding )
	Table.Panel:SetSpacing( RS.InnerPadding )
	Table.Panel:EnableVerticalScrollbar( true )

	Table.Draw = Table.Draw == nil and true or Table.Draw

	function Table.Panel:Paint( Wide, Tall )

		local Color = Table.BodyColor and Table.BodyColor or RS.Theme.Panel.Body.Color

		if ( Table.Draw ) then

			DrawRectangle( 0, 0, Wide, Tall, Color, Table.Gradient )

		end

	end

	return Table

end

function CreateList( Structure, Parent )

	local Table = { }

	for Key, Value in pairs( Structure ) do

		Table[ Key ] = Value

	end

	Table.List = vgui.Create( "DListView", Parent )
	Table.List:SetSize( Table.Wide, Table.Tall )
	Table.List:SetPos( Table.x, Table.y )
	Table.List:SetHeaderHeight( RS.Theme.List.Head.Tall )
	Table.List:SetDataHeight( RS.Theme.List.Head.Tall * 0.75 )
	Table.List:SetMultiSelect( Table.MultiSelect ~= nil and Table.MultiSelect or false )

	function Table.List:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Theme.List.Body.Color )

	end

	function Table:AddColumn( Name )

		local Column = Table.List:AddColumn( Name )

		local Header = Column.Header
		Header:SetText( "" )

		function Header:Paint( Wide, Tall )

			local WarmCold = Table.Warm and "WarmColor" or "ColdColor"
			local Index = self.Hovered and 1 or 0
			local Color = RS.Theme.Button.Body[ WarmCold .. Index ]

			DrawRectangle( 0, 0, Wide, Tall, RS.Theme.Button.Body.Color )
			DrawRectangle( 0, Tall - 4, Wide, 4, Color )

			DrawText( Name, 2, Wide / 2, ( Tall - 2 ) / 2, RS.Theme.Label.DrawText.Color, 1, 1 )

		end

		return Column

	end

	function Table:AddLine( ... )

		local Argument = { ... }

		for k = 1, #Argument do

			if ( type( tonumber( Argument[ k ] ) ) == "number" ) then

				Argument[ k ] = FormatNumber( Argument[ k ] )

			end

		end

		local Line = Table.List:AddLine( unpack( Argument ) )

		return Line

	end

	return Table

end

function CreateButton( Structure, Parent )

	local Table = { }

	for Key, Value in pairs( Structure ) do

		Table[ Key ] = Value

	end

	Table.Button = vgui.Create( "DButton", Parent )
	Table.Button:SetSize( Table.Wide, Table.Tall )
	Table.Button:SetPos( Table.x, Table.y )
	Table.Button:SetText( "" )

	function Table.Button:Paint( Wide, Tall )

		local WarmCold = Table.Warm and "WarmColor" or "ColdColor"
		local Index = self.Hovered and 1 or 0
		local Color = RS.Theme.Button.Body[ WarmCold .. Index ]

		DrawRectangle( 0, 0, Wide, Tall, RS.Theme.Button.Body.Color )
		DrawRectangle( 0, Tall - 4, Wide, 4, Color )

		local Size = Table.Size and Table.Size or RS.Theme.Label.DrawText.Size

		DrawText( Table.DrawText, Size, Wide / 2, ( Tall - 2 ) / 2, RS.Theme.Label.DrawText.Color, 1, 1 )

	end

	function Table.Button:DoClick()

		Table.CallBack()

	end

	return Table

end

function CreateLabel( Structure, Parent )

	local Table = { }

	for Key, Value in pairs( Structure ) do

		Table[ Key ] = Value

	end

	Table.Label = vgui.Create( "DPanel", Parent )
	Table.Label:SetSize( Table.Wide, Table.Tall )
	Table.Label:SetPos( Table.x, Table. y )

	function Table.Label:Paint( Wide, Tall )

		if ( Table.BodyColor ) then

			DrawRectangle( 0, 0, Wide, Tall, Table.BodyColor )

		end

		local Size = Table.Size and Table.Size or RS.Theme.Label.DrawText.Size
		local Color = Table.TextColor and Table.TextColor or RS.Theme.Label.DrawText.Color

		local TextAlignX = Table.TextAlignX and Table.TextAlignX or 1
		local TextAlignY = Table.TextAlignY and Table.TextAlignY or 1

		local x = TextAlignX == 1 and Wide / 2 or TextAlignX == 2 and Wide - Tall / 3 or TextAlignX == 0 and Tall / 3 or 0
		local y = TextAlignY == 1 and Tall / 2 or TextAlignY == 2 and Tall - Tall / 3 or TextAlignY == 0 and Tall / 3 or 0

		DrawText( Table.DrawText, Size, x, y - 1, Color, TextAlignX, TextAlignY )

	end

	return Table

end