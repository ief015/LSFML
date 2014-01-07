require '../ffi/sfml-window';

print("SFML " .. sf.Version.Major .. "." .. sf.Version.Minor .. " - Window");


local window = sf.Window(sf.VideoMode(800, 600), "Hello, SFML", sf.Style.Default);
window:setKeyRepeatEnabled(true);
window:setVerticalSyncEnabled(true);

while window:isOpen() do
	
	local event = sf.Event();
	
	while window:pollEvent(event) do
		
		if event.type == sf.Event.Closed then
			print("Closing");
			window:close();
		end
		
		if event.type == sf.Event.Resized then
			print("Resizing", event.size.width, event.size.height);
		end
		
		if event.type == sf.Event.LostFocus then
			print("Lost focus");
		end
		
		if event.type == sf.Event.GainedFocus then
			print("Gained focus");
		end
		
		if event.type == sf.Event.TextEntered then
			print("Text entered", string.char(event.text.unicode));
		end
		
		if event.type == sf.Event.KeyPressed then
			print("Key pressed", event.key.code, "Alt " .. event.key.alt, "Ctrl " .. event.key.control, "Shift " .. event.key.shift, "System " .. event.key.system);
		end
		
		if event.type == sf.Event.KeyReleased then
			print("Key released", event.key.code, "Alt " .. event.key.alt, "Ctrl " .. event.key.control, "Shift " .. event.key.shift, "System " .. event.key.system);
		end
		
		if event.type == sf.Event.MouseWheelMoved then
			print("Mouse wheel", event.mouseWheel.x, event.mouseWheel.y, event.mouseWheel.delta);
		end
		
		if event.type == sf.Event.MouseButtonPressed then
			print("Mouse pressed", event.mouseButton.x, event.mouseButton.y, event.mouseButton.button);
		end
		
		if event.type == sf.Event.MouseButtonPressed then
			print("Mouse released", event.mouseButton.x, event.mouseButton.y, event.mouseButton.button);
		end
		
		if event.type == sf.Event.MouseMoved then
			print("Mouse moved", event.mouseMove.x, event.mouseMove.y);
		end
		
		if event.type == sf.Event.MouseEntered then
			print("Mouse entered");
		end
		
		if event.type == sf.Event.MouseLeft then
			print("Mouse left");
		end
		
		if event.type == sf.Event.JoystickButtonPressed then
			print("Joystick pressed", event.joystickButton.joystickId, event.joystickButton.button);
		end
		
		if event.type == sf.Event.JoystickButtonReleased then
			print("Joystick released", event.joystickButton.joystickId, event.joystickButton.button);
		end
		
		if event.type == sf.Event.JoystickMoved then
			print("Joystick moved", event.joystickMove.joystickId, event.joystickMove.axis, event.joystickMove.position);
		end
		
		if event.type == sf.Event.JoystickConnected then
			print("Joystick connected", event.joystickConnect.joystickId);
		end
		
		if event.type == sf.Event.JoystickDisconnected then
			print("Joystick disconnected", event.joystickConnect.joystickId);
		end
		
	end
	
	window:display();
	
	--sf.sleep(sf.seconds(1/60));
	
end