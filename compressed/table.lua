if not main then os.loadAPI('APIS/main')end
REQUIRE_PATH='packages/luasched/?;packages/luasched/?.lua;packages/luasched/?/init.lua'local s=coroutine
local h=require"utils.path".clean
local i=table
local n={}local p,a,f,t,u,d,o,r,c
assert(not i.pack,"This was temporary, waiting for Lua5.2. Remove table.pack from utils module!")function p(...)local e=select("#",...)local n={...}n.n=e
return n,e
end
function a(e,n,i)n=n or{}for e,l in pairs(e)do
if type(l)=='table'then
if type(n[e])=='table'then
a(l,n[e],i)elseif i or n[e]==nil then
n[e]={}a(l,n[e],i)end
elseif i or n[e]==nil then n[e]=l end
end
return n
end
function f(a,t,e)local l={}local n={}local e=e and pairs or r
for e,i in e(a)do n[e]=i end
for e,r in e(t)do
if r~=n[e]then i.insert(l,e)end
n[e]=nil
end
for n,e in pairs(n)do i.insert(l,n)end
return l
end
function t(e)local n=1
for i,i in pairs(e)do
if e[n]==nil then return false end
n=n+1
end
return true
end
function u(e)local n={}for e in pairs(e)do i.insert(n,e)end
return n
end
function d(n,l,a,r)local i=r and n or{}for n,e in pairs(n)do
if a and type(e)=='table'then i[n]=d(e,l,true,r)else i[n]=l(n,e)end
end
return i
end
function o(l)local e={}local n=i.insert
for l in pairs(l)do n(e,l)end
i.sort(e)local n=0
return function()n=n+1
return e[n],l[e[n]]end
end
function r(d,r)local function t(a,l,e)e[a]=true
local o=l==""and l or"."for n,i in pairs(a)do
n=o..tostring(n)if type(i)=='table'then
if not e[i]then t(i,l..n,e)end
else
s.yield(l..n,i)end
end
e[a]=nil
end
r=r or""return s.wrap(function()t(d,h(r),{})end)end
function c(e,...)local e={tables={e,...},i=1,k=next(e)}local function r()if not e.i then return end
local l=e.tables[e.i]local i,n=e.k,l[e.k]local n=next(l,i)while n==nil do
e.i=e.i+1
local i=e.tables[e.i]if not i then e.i=false;break
else n=next(i)end
end
e.k=n
return i,l[i]end
return r,nil,nil
end
n.pack=p;n.copy=a;n.diff=f;n.keys=u;n.map=d;n.isarray=t;n.isArray=t;n.sortedpairs=o;n.sortedPairs=o;n.recursivepairs=r;n.recursivePairs=r;n.multipairs=c;n.multiPairs=c;return n