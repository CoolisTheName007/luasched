---test for luasched
--requirements:
--	luasched and loadreq directory as from github in packages/

if not loadreq then os.loadAPI('packages/loadreq/loadreq') end
require=loadreq.require

globals={
--some goodies I ported and may distribute if people want
--deepcopy= require 'packages.deepcopy',
--stringify= require'packages.stringify',
--pprint=function (v) print(stringify(v)) end,
--moses=require 'packages.moses',
--checker=require 'packages.checker.checker',
require=require
}

for i,v in pairs(globals) do
	rawset(_G,i,v)
end

---Fixes

--due to Lua implementation
local old_find=string.find
string.find=function(s,...)
	return old_find(s..'',...)
end



sched=require 'packages.luasched.sched'
log=require 'packages.luasched.log'
log.setlevel('ALL','fd')
sched.run (function()
	print(1)
	sched.wait(2)
	print(1)
end)

sched.run(function()
	print(1)
	sched.wait(1)
	print(1)
end)

sched.run(function()
	sched.wait(sched,'terminate')
	print('Terminated')
	sched.stop()
end)
sched.loop()