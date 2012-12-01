if not main then os.loadAPI('APIS/main')end
REQUIRE_PATH='packages/luasched/?;packages/luasched/?.lua;packages/luasched/?/init.lua'local t=require'checker'.check
local e={__type='pipe'};e.__index=e
local n,n,l=table.insert,table.remove,os.clock
function pipe(n)t('?number',n)local n={sndidx=1;rcvidx=1;content={};maxlength=n;state='empty';wasteabs=32;wasteprop=2}if proc.pipes then
proc.pipes[tonumber(tostring(n):match'0x%x+')]=n
end
setmetatable(n,e)return n
end
local function n(e)local n=e.sndidx-e.rcvidx
local t=e.state
local n=n==0 and'empty'or e.maxlength==n and'full'or'ready'if t~=n then
e.state=n
sched.signal(e,'state',n)end
end
local function o(e)local l=e.rcvidx
local t=l-1
if t<=e.wasteabs then return end
local a=e.sndidx
local i=a-l
if t<=e.wasteprop*i then return end
local n
if a<2e3 then n={select(l,unpack(e.content))}else
local l
l,n=e.content,{}for e=1,i do n[e]=l[e+t]end
end
e.content,e.rcvidx,e.sndidx=n,1,i+1
end
function e:receive(i)t('pipe,?number',self,i)local e
while true do
if self.rcvidx==self.sndidx then
log('pipe','DEBUG',"Pipe %s empty, :receive() waits for data",tostring(self))e=e or i and l()+i
local e=e and e-l()if e and e<=0 or sched.wait(self,{'state',e})=='timeout'then
return nil,'timeout'end
else
local t,e=self.content,self.rcvidx
local l=t[e]t[e]=false
self.rcvidx=e+1
o(self)n(self)return l
end
end
end
function e:send(a,i)t('pipe,?,?number',self,a,i)assert(a~=nil,"Don't :send(nil) in a pipe")local e=self.maxlength
local e
while self.state=='full'do
log('pipe','DEBUG',"Pipe %s full, :send() blocks until some data is pulled from pipe",tostring(self))e=e or i and l()+i
local e=e and e-l()if e and e<=0 or wait(self,{'state',e})=='timeout'then
log('pipe','DEBUG',"Pipe %s :send() timeout",tostring(self))return nil,'timeout'else
log('pipe','DEBUG',"Pipe %s state changed, retrying to :send()",tostring(self))end
end
local e=self.sndidx
self.content[e]=a
self.sndidx=e+1
n(self)return self
end
function e:pushback(t)assert(t~=nil,"Don't :pushback(nil) in a pipe")if self.state=='full'then
return nil,'length would exceed maxlength'end
local e=self.rcvidx-1
if e==0 then
table.insert(self.content,1,t)self.sndidx=self.sndidx+1
else
self.content[e]=t
self.rcvidx=e
end
n(self)return self
end
function e:reset()local e=self.content
self.content={}n(self)return e
end
function e:peek()return self.content[self.rcvidx]end
function e:length()return self.sndidx-self.rcvidx
end
function e:setmaxlength(e)t('pipe,?number',self,e)if self:length()>e then return nil,'length exceeds new maxlength'end
if e and e<1 then return nil,'invalid maxlength'end
self.maxlength=e
n(self)return self
end
function e:setwaste(n,e)self.wasteabs,self.wasteprop=n,e
return self
end
return pipe