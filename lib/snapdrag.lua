-------------------------------------------------------------------
--Hammerspoon config to replace Cinch & Size-up (Microsoft Windows style) window management for free
--By Jayden Pearse (spartanatreyu)
--Sort of messy, forgive me. Never scripted in lua before
-------------------------------------------------------------------


-------------------------------------------------------------------
--Options, feel free to edit these
-------------------------------------------------------------------

--Set this to true to snap windows by dragging them to the edge of your screen
enable_window_snapping_with_mouse = true

--Set this to true to snap windows using keyboard shortcuts (eg. Ctrl + Option + Right Arrow)
enable_window_snapping_with_keyboard = false

--Will say the name of the window and its position for (in seconds)
--Set to 0 to disable
show_window_notification_duration = 0

--the height of the window's title area (in pixels), can change if you have different sized windows (might happen one day)
--or need a different window grabbing sensitivity. Chrome is a little weird since its title area's height is non-standard
window_titlebar_height = 50

--the amount (in pixels) around the edge of the screen in which the mouse has to be let go for the drag window to count
monitor_edge_sensitivity = 1

--The time (in seconds) it takes for a window to transition to its new position and size
hs.window.animationDuration = 0

-------------------------------------------------------------------
--Don't edit this section
--Boilerplate init code, don't edit this section
-------------------------------------------------------------------

--required to be non zero for dragging windows to work some weird timing issue with hammerspoon fighting against osx events
if hs.window.animationDuration <= 0 then
	hs.window.animationDuration = 0.00000001	
end

--flag for dragging, 0 means no drag, 1 means dragging a window, -1 means dragging but not dragging the window
dragging = 0

--the window being dragged
dragging_window = nil

-- Exists because lua doesn't have a round function. WAT?!
function round(num)
	return math.floor(num + 0.5)
end

--based on kizzx2's hammerspoon-move-resize.lua
function get_window_under_mouse()
	-- Invoke `hs.application` because `hs.window.orderedWindows()` doesn't do it
	-- and breaks itself
	local _ = hs.application

	local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
	local my_screen = hs.mouse.getCurrentScreen()

	return hs.fnutils.find(hs.window.orderedWindows(), function(w)
		return my_screen == w:screen() and my_pos:inside(w:frame())
	end)
end


-------------------------------------------------------------------
--Window snapping with mouse, Windows style (Cinch Alternative)
-------------------------------------------------------------------

--Setup drag start and dragging
click_event = hs.eventtap.new({hs.eventtap.event.types.leftMouseDragged}, function(e)

	--if drag is just starting...
	if dragging == 0 then
		dragging_window = get_window_under_mouse()
		--if mouse over a window...
		if dragging_window ~= nil then

			local m = hs.mouse.absolutePosition()
			local mx = round(m.x)
			local my = round(m.y)
			--print('mx: ' .. mx .. ', my: ' .. my)

			local f = dragging_window:frame()
			local screen = dragging_window:screen()
			local max = screen:frame()
			--print('fx: ' .. f.x .. ', fy: ' .. f.y .. ', fw: ' .. f.w .. ', fh: ' .. f.h)

			--if mouse inside titlebar horizontally
			if mx > f.x and mx < (f.x + f.w) then
				--print('mouse is inside titlebar horizontally')

				--if mouse inside titlebar vertically
				if my > f.y and my < (f.y + window_titlebar_height) then
					--print('mouse is inside titlebar')
			
					dragging = 1
					--print(' - start dragging - window: ' .. dragging_window:id())

				else
					--print('mouse is not inside titlebar')
					dragging = -1
					dragging_window = nil
				end
			else
				--print('mouse is not inside titlebar horizontally')
				dragging = -1
				dragging_window = nil
			end

		end
	--else if drag is already going
	--[[
	else
		if dragging_window ~= nil then
			local dx = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
			local dy = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)

			local m = hs.mouse.absolutePosition()
			local mx = round(m.x)
			local my = round(m.y)

			print(' - dragging: ' .. mx .. "," .. my .. ". window id: " .. dragging_window:id())
		end
	]]--
	end
end)

--Setup drag end
unclick_event = hs.eventtap.new({hs.eventtap.event.types.leftMouseUp}, function(e)
	
	--print('unclick, dragging: ' .. dragging)

	--if dragging the mouse
	if dragging == 1 then

		--if the mouse is dragging a window
		if dragging_window ~= nil then

			--print('letting go of window: ' .. dragging_window:id())

			local m = hs.mouse.absolutePosition()
			local mx = round(m.x)
			local my = round(m.y)

			--print('mx: ' .. mx .. ', my: ' .. my)

			local win = dragging_window
			local f = win:frame()
			local screen = win:screen()
			local max = screen:frame()

			if mx < monitor_edge_sensitivity and my < monitor_edge_sensitivity then
				hs.alert.show(hs.application.frontmostApplication():title() .. " Top Left", show_window_notification_duration)
				f.x = max.x
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			elseif mx > monitor_edge_sensitivity and mx < (max.w - monitor_edge_sensitivity) and my < monitor_edge_sensitivity then
				hs.alert.show(hs.application.frontmostApplication():title() .. " Full", show_window_notification_duration)
				f.x = max.x
				f.y = max.y
				f.w = max.w
				f.h = max.h
				win:setFrame(f)
			elseif mx > (max.w - monitor_edge_sensitivity) and my < monitor_edge_sensitivity then
				hs.alert.show(hs.application.frontmostApplication():title() .. " Top Right", show_window_notification_duration)
				f.x = max.x + (max.w / 2)
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			elseif mx < monitor_edge_sensitivity and my < (max.h - monitor_edge_sensitivity) and my > monitor_edge_sensitivity then
				hs.alert.show(hs.application.frontmostApplication():title() .. " Left", show_window_notification_duration)
				f.x = max.x
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h
				win:setFrame(f)
			elseif mx > (max.w - monitor_edge_sensitivity) and my > monitor_edge_sensitivity and my < (max.h - monitor_edge_sensitivity) then
				hs.alert.show(hs.application.frontmostApplication():title() .. " Right", show_window_notification_duration)
				f.x = max.x + (max.w / 2)
				f.y = max.y
				f.w = max.w / 2
				f.h = max.h
				win:setFrame(f)
			elseif mx < monitor_edge_sensitivity and my > (max.h - monitor_edge_sensitivity) then
				hs.alert.show(hs.application.frontmostApplication():title() .. " Bottom Left", show_window_notification_duration)
				f.x = max.x 
				f.y = max.y + (max.h / 2)
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			elseif mx > (max.w - monitor_edge_sensitivity) and my > (max.h - monitor_edge_sensitivity) then
				hs.alert.show(hs.application.frontmostApplication():title() .. " Bottom Right", show_window_notification_duration)
				f.x = max.x + (max.w / 2)
				f.y = max.y + (max.h / 2)
				f.w = max.w / 2
				f.h = max.h / 2
				win:setFrame(f)
			end

		end
		--print("end dragging")
	end
	
	dragging = 0
	dragging_window = nil
end)

--Start watching for dragging (AKA: turn dragging on)
if enable_window_snapping_with_mouse == true then
	click_event:start()
	unclick_event:start()
end
