-- by Thomas Wiegand (Minetest.one)
-- source https://github.com/Minetest-One/free_lj_mem

-----------------------------------------------------------------------------------------------
local title	= "test_lj_max"
local date	= "04.04.2019"
local version	= "1.00"
local mname	= "test_lj_max"
-----------------------------------------------------------------------------------------------

local oldluamem = nil
local newluamem = nil
local maxmem = 0 -- ever registered maximun (guess needed)
local minmem = 0 -- seen minimum (try out also)
local log = 0
local warning = 0
local loaded = 0


-- following settings can be changed by admin as wanted, needed - useful
-- some parameter set in minetest.conf
looptime = 10 -- set repeat time in sec, 60 min = 3600
if minetest.setting_get("looptime") ~= nil then
	looptime = tonumber(minetest.setting_get("looptime")) -- calue out of .conf
end
local terminal = 1 -- set 0 if no print in terminal wanted
local message = 0 -- set to 1 if want chatmessage to player set after
local player_name = minetest.setting_get("name") -- admin out of .conf
maxluamem = 2000000 -- set to value 10% ? less then lowest known OOM
if minetest.setting_get("maxluamem") ~= nil then
	maxluamem = tonumber(minetest.setting_get("maxluamem")) -- value out of .conf
end
-- END of settings to change mostly


-- detecting lua or luajit and version -- for later usage
local luajit = 0
if type(jit) == 'table' then
  print("[Mod] free_lj_mem detected: "..jit.version)
	luajit = 1
--	maxluamem = 1000000 -- set to value less then known OOM with JIT
else
 	luajit = 0
-- 	maxluamem = 2000000 -- set to value less then known OOM with lua only
end


local function riseluamem()
	oldluamem = math.floor(collectgarbage("count"))
	if oldluamem > maxmem then maxmem = oldluamem end
	collectgarbage()
	newluamem = math.floor(collectgarbage("count"))

-- raising mem by some more variable / global via local
print("before: "..math.floor(collectgarbage("count")))
local i = 0
local j = 0

local one = 10000000
local two = 10000000
-- start with ~ 2.100 KB
-- 1.000.000 leads to 10.251 KB
-- 10.000.000 leads to  KB

print("go in with: "..one.." "..two)
local function rehash1(el, loops)
    local table = {}
    for i = 1, loops do
        for j = 1, el do
            table[j] = j
        end
--        for k in ipairs(table) do table[k] = nil end
    end
end

rehash1(one, two)
print("after: "..math.floor(collectgarbage("count")))


-- set of minimal memory usage registered
	if newluamem < minmem or minmem == 0 then minmem = newluamem end

-- prepare logtext with report collectgarbage() result
	local logtext = "[MOD] "..mname..": cleaned "..oldluamem.." to "..newluamem.." (max: "..maxmem.." / min: "..minmem..") KB"
	if log then
		minetest.log("action", logtext)
	end

	if terminal then
		print(logtext)
	end

	if  message then
		minetest.chat_send_player(player_name, logtext)
	end

	-- recall itself- yes!
	minetest.after(looptime, riseluamem)
end

minetest.after(looptime, riseluamem)


if loaded then
	print ("[Mod] "..title.." ("..version.." "..date..") - loaded - end mem : "..math.floor(collectgarbage("count")).." KB")
end