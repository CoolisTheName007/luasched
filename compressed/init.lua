if not main then os.loadAPI('APIS/main')end
REQUIRE_PATH='packages/luasched/?;packages/luasched/?.lua;packages/luasched/?/init.lua'local e=require'log'local o=require'checker'.check
local n={};local t=require'sched.timer'local r=require'utils.table'.pack
local d=require'print'.sprint
local u=false
local f=true
local l=setmetatable({"<KILL-TOKEN>"},{__tostring=function()return"Killed thread"end})local s=false
__tasks={}n.proc={tasks=__tasks}__tasks.ready={}__tasks.signal_processing=false
__tasks.waiting=setmetatable({},{__mode='k'})__tasks.running=nil
function n.run(n,...)o('function',n)local t=__tasks.ready
local n=coroutine.create(n)local l={n,...}table.insert(t,l)e.trace('sched','DEBUG',"SCHEDULE %s",tostring(n))return n
end
function n.step()local t=__tasks.ready
if __tasks.running or __tasks.hook then return nil,'already running'end
while true do
local i=table.remove(t,1)if not i then break end
local t=i[1]__tasks.running=t
e.trace('sched','DEBUG',"STEP %s",tostring(t))local i,e=coroutine.resume(unpack(i))if not i and e~=l then
print("In "..tostring(t)..": error: "..tostring(e))end
if coroutine.status(t)=="dead"then
n.signal(t,"die",i,e)end
end
__tasks.running=nil
if s then n.gc();s=false end
end
local function c(t,r,d,n,o,c)local i=n.n
if t.xtrargs then
local e=t.xtrargs.n
local l={n[1],unpack(t.xtrargs,1,e)}for t=2,i do l[t+e]=n[t]end
n=l
i=i+e
end
if t.multi then s=true end
local a=t.thread
if a then
local n=t.multiwait and{a,r,unpack(n,1,i)}or{a,unpack(n,1,i)}if not o then o=__tasks.ready end
table.insert(o,n)cell={}elseif t.hook then
local function o()return t.hook(unpack(n,1,i))end
local o,n=pcall(o)local i=not t.once
if o then
elseif n==l then
i=false
else
if type(n)=='string'and n:match"^attempt to yield"then
n="Cannot block in a hook, consider sched.sigrun()\n"..(n:match"function 'yield'\n(.-)%[C%]: in function 'xpcall'"or n)end
n=string.format("In signal %s.%s: %s",tostring(r),d,tostring(n))e('sched','ERROR',n)print(n)end
if i then
if c then table.insert(c,t)end
else cell={}end
else end
end
function n.signal(t,l,...)e.trace('sched','DEBUG',"SIGNAL %s.%s",tostring(t),l)local d=r(l,...)local r=__tasks.waiting
local n=__tasks.running
local s=__tasks.ready
local n=r[t];if not n then return end
local a={}local function o(i)local o=n[i]if not o then return end
local e={}n[i]=e
for i,n in ipairs(o)do
c(n,t,l,d,a,e)end
if not next(e)then
n[i]=nil
if not next(n)then
r[t]=nil
end
end
end
local n=__tasks.signal_processing
__tasks.signal_processing=true
o('*')o(l)__tasks.signal_processing=n
for e,n in ipairs(a)do table.insert(s,n)end
end
local function a(l,t,i)if i==nil and type(t)=='number'then
t,i=nil,{t}elseif t==nil then
error'signal emitters cannot be nil'end
if#i>1 then l.multi=true end
local a=__tasks.waiting
local o=a[t]if not o then o={};a[t]=o end
local r=false
for a,i in ipairs(i)do
if type(i)=='number'then
if r then error("Several timeouts for one signal registration")end
local function a()if next(l)then
c(l,t,'timeout',{'timeout',i,n=2})l={}end
end
r=true
local r=i
local n=n.timer.set(r,t,a)local n=o.timeout
if n then table.insert(n,l)else o.timeout={l}end
e.trace('sched','DEBUG',"Registered cell for %ds timeout event",i)end
end
if t then
local n=a[t]if not n then n={};a[t]=n end
for t,e in ipairs(i)do
if type(e)~='number'then
local t=n[e]if not t then n[e]={l}else table.insert(t,l)end
end
end
end
return i
end
function n.wait(t,...)local n=__tasks.running or
error("Don't call wait() while not running!")local o={thread=n}local i=select('#',...)if t==nil and i==0 then
e('sched','DEBUG',"Rescheduling %s",tostring(n))table.insert(__tasks.ready,{n})else
local n
if i==0 then
t,n='*',{t}elseif i==1 then
n=(...)if type(n)~='table'then n={n}end
else
n={...}end
a(o,t,n)if e.musttrace('sched','DEBUG')then
local l={}for e=1,#n do l[e]=tostring(n[e])end
local n="WAIT emitter = "..tostring(t)..", events = { "..table.concat(l,", ").." } )"e.trace('sched','DEBUG',n)end
end
__tasks.running=nil
local n={coroutine.yield()}if n and n[1]==l then
o={};error(l)else return unpack(n)end
end
function n.multiWait(t,n)o('table,string|table|number',t,n)local i=__tasks.running or
error("Don't call wait() while not running!")if type(n)~='table'then n={n}end
local i={thread=i,multiwait=true,multi=true}for t,e in ipairs(t)do
a(i,e,n)end
if e.musttrace('sched','DEBUG')then
local l={}for n=1,#t do l[n]=tostring(t[n])end
local t={}for e=1,#n do t[e]=tostring(n[e])end
local n="WAIT emitters = { "..table.concat(l,", ").." }, events = { "..table.concat(t,", ").." } )"e.trace('sched','DEBUG',n)end
__tasks.running=nil
local n={coroutine.yield()}if n and n[1]==l then
i={};error(l)else return unpack(n)end
end
function n.sigHook(l,n,t,...)o('?,string|table|number,function',l,n,t)local e=r(...);if not e[1]then e=nil end
local e={hook=t,xtrargs=e}if type(n)~='table'then n={n}end
a(e,l,n)return e
end
function n.sigOnce(l,n,t,...)o('?,string|table|number,function',l,n,t)local e=r(...);if not e[1]then e=nil end
local e={hook=t,once=true,xtrargs=e}if type(n)~='table'then n={n}end
a(e,l,n)return e
end
local function c(o,s,t,c,...)local i=r(...);if not i[1]then i=nil end
local e,r
local function r(o,t,i)if not t and i==l then n.kill(e)end
end
local function l(t,...)local t=n.run(c,t,...)if not o then
n.sigonce(t,'die',r)end
end
e={hook=l,once=o,xtrargs=i}if type(t)~='table'then t={t}end
a(e,s,t)return e
end
function n.sigRun(...)o('?,string|table|number,function',...)return c(false,...)end
function n.sigRunOnce(...)o('?,string|table|number,function',...)return c(true,...)end
function n.gc()local r=coroutine.status
local i,o=not __tasks.signal_processing,__tasks.waiting
for a,t in pairs(o)do
for o,e in pairs(t)do
local n,l=1,#e
while n<=l do
local t=e[n]if not next(t)or t.thread and r(t.thread)=="dead"then table.remove(e,n);l=l-1 else n=n+1 end
end
if i and not next(e)then t[o]=nil end
end
if i and not next(t)then o[a]=nil end
end
end
function n.kill(t)local i=type(t)if i=='table'then
if t.hook then
for n in pairs(t)do t[n]=nil end
s=true
elseif not next(t)then
e('sched','DEBUG',"Attempt to kill a dead cell")else
e("sched","WARNING","Don't know how to kill %s",d(t))end
elseif t==__tasks.running then
error(l)elseif i=='thread'then
coroutine.resume(t,l)n.signal(t,"die","killed")else
e("sched","WARNING","Don't know how to kill %s",d(t))end
end
function n.killSelf()error(l)end
if f then
local e={}for t,l in pairs(n)do
local n=t:lower()if n~=t then e[n]=l end
end
for e,t in pairs(e)do n[e]=t end
end
if u then
for n,e in pairs(n)do
rawset(_G,n,e)end
end
require('sched.platform',nil,{sched=n})return n