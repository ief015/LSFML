require 'sfml-audio';

print("SFML " .. sf.Version.Major .. "." .. sf.Version.Minor .. " - Window");


function playSound()
	
	local buffer = sf.SoundBuffer('.resources/canary.wav');
	if buffer == nil then
		return;
	end
	
	print("canary.wav :");
	print(" " .. buffer:getDuration():asSeconds() .. " seconds");
	print(" " .. buffer:getSampleRate()           .. " samples / sec");
	print(" " .. buffer:getChannelCount()         .. " channels");
	
	local sound = sf.Sound(buffer);
	sound:play();
	
	while sound:getStatus() == sf.SoundStatus.Playing do
		
		sf.sleep(sf.milliseconds(100));
		
		print(string.format("\rPlaying... %.2f sec   ", sound:getPlayingOffset():asSeconds()));
		io.flush();
		
	end
	
	print('\n');
	
end

function playMusic()
	
	local music = sf.Music('resources/orchestral.ogg');
	if music == nil then
		return;
	end
	
	print("orchestral.ogg :");
	print(" " .. music:getDuration():asSeconds() .. " seconds");
	print(" " .. music:getSampleRate()           .. " samples / sec");
	print(" " .. music:getChannelCount()         .. " channels");
	
	music:play();
	
	while music:getStatus() == sf.SoundStatus.Playing do
		
		sf.sleep(sf.milliseconds(100));
		
		print(string.format("\rPlaying... %.2f sec   ", music:getPlayingOffset():asSeconds()));
		io.flush();
		
	end
	
	print();
	
end

playSound();

playMusic();

print("Press enter to exit...");
io.read();