require '../sfml';
print("SFML " .. sf.Version.Major .. "." .. sf.Version.Minor .. " - System");

local clk = sf.Clock();

print("Sleeping for 1 second...");
sf.sleep(sf.seconds(1));

print("Time + 1 second:", (clk:getElapsedTime() + sf.seconds(1)):asSeconds())