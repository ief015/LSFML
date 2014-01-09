require '../ffi/sfml-graphics';
require '../ffi/sfml-audio';

print("SFML " .. sf.Version.Major .. "." .. sf.Version.Minor .. " - Pong");


math.randomseed(os.time());

-- Define some constants
local gameWidth = 800;
local gameHeight = 600;
local paddleSize = sf.Vector2f(25., 100.);
local ballRadius = 10.;

-- Create the window of the application
local window = sf.RenderWindow(sf.VideoMode(gameWidth, gameHeight, 32), "SFML Pong");
window:setVerticalSyncEnabled(true);

-- Load the sounds used in the game
local ballSoundBuffer = sf.SoundBuffer("examples/resources/ball.wav");
if ballSoundBuffer == nil then
	return;
end
local ballSound = sf.Sound(ballSoundBuffer);

-- Create the left paddle
local leftPaddle = sf.RectangleShape();
leftPaddle:setSize(paddleSize - sf.Vector2f(3, 3));
leftPaddle:setOutlineThickness(3);
leftPaddle:setOutlineColor(sf.Color.Black);
leftPaddle:setFillColor(sf.Color(100, 100, 200));
leftPaddle:setOrigin(paddleSize / 2);

-- Create the right paddle
local rightPaddle = sf.RectangleShape();
rightPaddle:setSize(paddleSize - sf.Vector2f(3, 3));
rightPaddle:setOutlineThickness(3);
rightPaddle:setOutlineColor(sf.Color.Black);
rightPaddle:setFillColor(sf.Color(200, 100, 100));
rightPaddle:setOrigin(paddleSize / 2);

-- Create the ball
local ball = sf.CircleShape();
ball:setRadius(ballRadius - 3);
ball:setOutlineThickness(3);
ball:setOutlineColor(sf.Color.Black);
ball:setFillColor(sf.Color.White);
ball:setOrigin(ballRadius / 2, ballRadius / 2);

-- Load the text font
local font = sf.Font("examples/resources/sansation.ttf");
if font == nil then
	return;
end

-- Initialize the pause message
local pauseMessage = sf.Text();
pauseMessage:setFont(font);
pauseMessage:setCharacterSize(40);
pauseMessage:setPosition(172., 150.);
pauseMessage:setColor(sf.Color.White);
pauseMessage:setString("Welcome to SFML pong!\nPress space to start the game");

-- Define the paddles properties
local AITimer          = sf.Clock();
local AITime           = sf.seconds(0.1);
local paddleSpeed      = 400.;
local rightPaddleSpeed = 0.; -- to be changed later
local ballSpeed        = 400.;
local ballAngle        = 0.; -- to be changed later

local clock = sf.Clock()
local isPlaying = false;

while window:isOpen() do
	
	--Handle events
	local event = sf.Event()
	while window:pollEvent(event) do
		
		-- Window closed or escape key pressed: exit
		if  (event.type == sf.Event.Closed) or
		   ((event.type == sf.Event.KeyPressed) and (event.key.code == sf.Keyboard.Escape)) then
			
			window:close();
			break;
			
		end
		
		-- Space key pressed: play
		if ((event.type == sf.Event.KeyPressed) and (event.key.code == sf.Keyboard.Space)) then
			
			if not isPlaying then
				
				-- (re)start the game
				isPlaying = true;
				clock:restart();
				
				-- Reset the position of the paddles and ball
				leftPaddle:setPosition(10 + paddleSize.x / 2, gameHeight / 2);
				rightPaddle:setPosition(gameWidth - 10 - paddleSize.x / 2, gameHeight / 2);
				ball:setPosition(gameWidth / 2, gameHeight / 2);
				
				-- Reset the ball angle
				repeat
					-- Make sure the ball initial angle is not too much vertical
					ballAngle = (math.random() * 360) * 2 * math.pi / 360;
				until (math.abs(math.cos(ballAngle)) >= 0.7);
				
			end
			
		end
		
	end
	
	if isPlaying then
		
		local deltaTime = clock:restart():asSeconds();
		
		-- Move the player's paddle
		if (sf.Keyboard.isKeyPressed(sf.Keyboard.Up)) and
		   (leftPaddle:getPosition().y - paddleSize.y / 2 > 5.) then
			leftPaddle:move(0., -paddleSpeed * deltaTime);
		end
		if (sf.Keyboard.isKeyPressed(sf.Keyboard.Down)) and
		   (leftPaddle:getPosition().y + paddleSize.y / 2 < gameHeight - 5.) then
			leftPaddle:move(0., paddleSpeed * deltaTime);
		end
		
		-- Move the computer's paddle
		if ((rightPaddleSpeed < 0.) and (rightPaddle:getPosition().y - paddleSize.y / 2 > 5)) or
		   ((rightPaddleSpeed > 0.) and (rightPaddle:getPosition().y + paddleSize.y / 2 < gameHeight - 5)) then
			rightPaddle:move(0., rightPaddleSpeed * deltaTime);
		end
		
		-- Update the computer's paddle direction according to the ball position
		if AITimer:getElapsedTime() > AITime then
			AITimer:restart();
			if ball:getPosition().y + ballRadius > rightPaddle:getPosition().y + paddleSize.y / 2 then
				rightPaddleSpeed = paddleSpeed;
			elseif ball:getPosition().y - ballRadius < rightPaddle:getPosition().y - paddleSize.y / 2 then
				rightPaddleSpeed = -paddleSpeed;
			else
				rightPaddleSpeed = 0.;
			end
		end
		
		-- Move the ball
		local factor = ballSpeed * deltaTime;
		ball:move(math.cos(ballAngle) * factor, math.sin(ballAngle) * factor);
		
		-- Check collisions between the ball and the screen
		if ball:getPosition().x - ballRadius < 0 then
			isPlaying = false;
			pauseMessage:setString("You lost !\nPress space to restart or\nescape to exit");
		end
		if ball:getPosition().x + ballRadius > gameWidth then
			isPlaying = false;
			pauseMessage:setString("You won !\nPress space to restart or\nescape to exit");
		end
		if ball:getPosition().y - ballRadius < 0 then
			ballSound:play();
			ballAngle = -ballAngle;
			ball:setPosition(ball:getPosition().x, ballRadius + 0.1);
		end
		if ball:getPosition().y + ballRadius > gameHeight then
			ballSound:play();
			ballAngle = -ballAngle;
			ball:setPosition(ball:getPosition().x, gameHeight - ballRadius - 0.1);
		end
		
		-- Check the collisions between the ball and the paddles
		-- Left Paddle
		if ball:getPosition().x - ballRadius < leftPaddle:getPosition().x + paddleSize.x / 2 and
		   ball:getPosition().x - ballRadius > leftPaddle:getPosition().x and
		   ball:getPosition().y + ballRadius >= leftPaddle:getPosition().y - paddleSize.y / 2 and
		   ball:getPosition().y - ballRadius <= leftPaddle:getPosition().y + paddleSize.y / 2 then
			
			if ball:getPosition().y > leftPaddle:getPosition().y then
				ballAngle = math.pi - ballAngle + (math.random() * 20) * math.pi / 180;
			else
				ballAngle = math.pi - ballAngle - (math.random() * 20) * math.pi / 180;
			end
			
			ballSound:play();
			ball:setPosition(leftPaddle:getPosition().x + ballRadius + paddleSize.x / 2 + 0.1, ball:getPosition().y)
		end
		
		-- Right Paddle
		if ball:getPosition().x + ballRadius > rightPaddle:getPosition().x - paddleSize.x / 2 and
		   ball:getPosition().x + ballRadius < rightPaddle:getPosition().x and
		   ball:getPosition().y + ballRadius >= rightPaddle:getPosition().y - paddleSize.y / 2 and
		   ball:getPosition().y - ballRadius <= rightPaddle:getPosition().y + paddleSize.y / 2 then
			
			if ball:getPosition().y > rightPaddle:getPosition().y then
				ballAngle = math.pi - ballAngle + (math.random() * 20) * math.pi / 180;
			else
				ballAngle = math.pi - ballAngle - (math.random() * 20) * math.pi / 180;
			end
			
			ballSound:play();
			ball:setPosition(rightPaddle:getPosition().x - ballRadius - paddleSize.x / 2 - 0.1, ball:getPosition().y)
		end
		
	end
	
	-- Clear the window
	window:clear(sf.Color(50, 200, 50));
	
	if isPlaying then
		-- Draw the paddles and the ball
		window:draw(leftPaddle);
		window:draw(rightPaddle);
		window:draw(ball);
	else
		--Draw the pause message
		window:draw(pauseMessage);
	end
	
	-- Display things on screen
	window:display();
	
end