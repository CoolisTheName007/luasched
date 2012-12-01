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

for i,v in pairs(sched.rpl_os.all_os) do
	rawset(os,i,v)
end
sched.run (function()
	print('a in')
	print(sched.n_tasks)
	print('a out')
end)

sched.run(function()
	print('b in')
	sched.wait()
	print('b out')
end)

sched.run(function()
	repeat
		event=sched.wait('*','terminate','die')
		if event=='terminate' then print('terminated') break end
	until sched.n_tasks==1
	sched.stop()
	sched.killSelf()
end)
sched.loop()