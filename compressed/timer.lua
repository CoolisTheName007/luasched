if not main then os.loadAPI('APIS/main')end
REQUIRE_PATH='packages/luasched/?;packages/luasched/?.lua;packages/luasched/?/init.lua'local l=os
local o=math
local e=tonumber
local a=assert
local r=table
local s=pairs
local d=next
local u=type
local e=_G
local f=sched
env=getfenv()setmetatable(env,nil)events={}local function c(e)return nil end
local function i(t)local e=t.nd
if events[e]then
events[e][t]=true
else
local n=#events+1
for t=1,n-1 do
if events[t]>e then n=t break end
end
r.insert(events,n,e)events[e]={[t]=true}if update_first_timer and n==1 then
update_first_timer()end
end
end
function addtimer(e)e.nd=e:nextevent()if not e.nd then return end
return i(e)end
function removetimer(e)local n=events[e.nd]if not n or not n[e]then return nil,"not a registered timer object"end
n[e]=nil
if not d(n)then
events[e.nd]=nil
if update_first_timer then update_first_timer()end
end
e.nd=nil
return"ok"end
function step()if not events[1]then return end
local e=l.clock()while events[1]and e>=events[1]do
local n=r.remove(events,1)local e=events[n]if e then
events[n]=nil
for e,n in s(e)do
local n=e.event
if u(n)=='function'then n(e)else f.signal(e.emitter or e,n or'run')end
addtimer(e)end
end
end
if update_first_timer then update_first_timer()end
end
function set(n,t,e)n=o.ceil(n)a(n>=0,"parameter must be a positive number")local n=l.clock()+n
t=t or'timer'e=e or"@"..n
local n={nextevent=c,nd=n,emitter=t,event=e}i(n)return e
end
function nextevent()return events[1]end
return env