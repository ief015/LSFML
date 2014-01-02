require '../sfml';
print("SFML " .. sf.Version.Major .. "." .. sf.Version.Minor .. " - System");

local clk = sf.Clock();

--for k,v in pairs(sf.Clock) do print(k,v) end

print("Sleeping for 1 second...");
sf.sleep(sf.seconds(1));

--print( sf.Time.asSeconds(sf.Clock.getElapsedTime(clk)) );
print("Time + 1 second:", (clk:getElapsedTime() + sf.seconds(1)):asSeconds())

local func = function()
	for i=0, 1000 do print ("other",i) end
end

local thread = sf.Thread(func);
thread:launch()

for i=0, 1000 do print ("main",i) end