if not main then os.loadAPI('APIS/main')end
REQUIRE_PATH='packages/luasched/?;packages/luasched/?.lua;packages/luasched/?/init.lua'local n=require'sched'local r=require'checker'.check
local e=setmetatable
local o=tostring
local o=string
local a=error
local o=assert
local l=table
local l=next
local t=n.proc
local c=pairs
local i=type
local s=unpack
local u=require'utils.table'.pack
env=getfenv()e(env,nil)LOCK={hooks={},objlocks=e({},{__mode="k"})}LOCK.__index=LOCK
function new()return e({waiting={}},LOCK)end
function LOCK:destroy()self.owner="destroyed"for o,e in c(self.waiting)do
n.signal(self,o)self.waiting[o]=nil
end
end
local function e(o)for n,e in c(LOCK.hooks[o])do
if n.owner==o then n:release(o)elseif n.waiting then n.waiting[o]=nil end
end
LOCK.hooks[o]=nil
end
local function d(l,o)if not LOCK.hooks[o]then
local n=n.sigonce(o,"die",function()e(o)end)LOCK.hooks[o]={sighook=n}end(LOCK.hooks[o])[l]=true
end
local function c(e,o)(LOCK.hooks[o])[e]=nil
if not l(LOCK.hooks[o],l(LOCK.hooks[o]))then
n.kill(LOCK.hooks[o].sighook)LOCK.hooks[o]=nil
end
end
function LOCK:acquire()local e=t.tasks.running
o(self.owner~=e,"a lock cannot be acquired twice by the same thread")o(self.owner~="destroyed","cannot acquire a destroyed lock")d(self,e)while self.owner do
self.waiting[e]=true
n.wait(self,{e})if self.owner=="destroyed"then a("lock destroyed while waiting")end
end
self.waiting[e]=nil
self.owner=e
end
function LOCK:release(e)e=e or t.tasks.running
o(self.owner~="destroyed","cannot release a destroyed lock")o(self.owner==e,"unlock must be done by the thread that locked")c(self,e)self.owner=nil
local o=l(self.waiting)if o then
n.signal(self,o)end
end
function lock(n)o(n,"you must provide an object to lock on")o(i(n)~="string"and i(n)~="number","the object to lock on must be a collectable object (no string or number)")if not LOCK.objlocks[n]then LOCK.objlocks[n]=new()end
LOCK.objlocks[n]:acquire()end
function unlock(n,e)o(n,"you must provide an object to unlock on")o(LOCK.objlocks[n],"this object was not locked")LOCK.objlocks[n]:release()end
function synchronized(o)r(o,'function')local function e(...)local n=lock(o)local n=u(o(...))unlock(o)return s(n,1,n.n)end
return e
end
return env