if not main then os.loadAPI('APIS/main')end
REQUIRE_PATH='packages/luasched/?;packages/luasched/?.lua;packages/luasched/?/init.lua'local t=require"checker".check
local n={}local u,s,e,f,d,c,i,o
local function l(a,n,e)local r={}local t
local l=0
n=n or 1
e=e or#a
for n=n,e do
local n=a[n]if not n then break
elseif n==''then
l=l+1
else
table.insert(r,t)t=n
end
end
table.insert(r,t)return table.concat(r,'.',1,e-n+1-l)end
function i(...)return l({...})end
function s(n)t('string',n)local n=e(n)return l(n)end
function d(r,n,l)t('table,string|table',r,n)local n=type(n)=='string'and e(n)or n
local e=table.remove(n)local n=o(r,n,l~=nil)if n then n[e]=l end
end
function f(l,n)t('table,string|table',l,n)local n=type(n)=='string'and e(n)or n
local e=table.remove(n)if not e then return l end
local n=o(l,n)return n and n[e]end
function c(n)t('string',n)local e=e(n)local t=#e
local n=t
local function r()if n==-1 then return nil,nil end
local t,e=l(e,1,n),l(e,n+1,t)n=n-1
return t,e
end
return r
end
function u(r,n)t('string,number',r,n)local e=e(r)if n>#e then return r,''elseif-n>#e then return'',r
else
if n<0 then n=#e+n end
return l(e,1,n),l(e,n+1,#e)end
end
function e(e)t('string',e)local r={}local l,t,n=1
repeat
t=e:find(".",l,true)or#e+1
n=e:sub(l,t-1)n=tonumber(n)or n
if n and n~=""then table.insert(r,n)end
l=t+1
until t==#e+1
return r
end
function o(a,r,o)t('table,string|table',a,r)r=type(r)=="string"and e(r)or r
for t,e in ipairs(r)do
local n=a[e]if type(n)~="table"then
if not o or(o=="noowr"and n~=nil)then return nil,l(r,1,t)else n={}a[e]=n end
end
a=n
end
return a
end
n.split=u;n.clean=s;n.segments=e;n.get=f;n.set=d;n.gsplit=c;n.concat=i;n.find=o
return n