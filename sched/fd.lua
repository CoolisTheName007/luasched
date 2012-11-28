if not main then os.loadAPI('APIS/main') end
REQUIRE_PATH='packages/luasched/?;packages/luasched/?.lua;packages/luasched/?/init.lua'

local print	=print
--local pack	=require 'utils.table'.pack
local log	=require 'log'
local os=os
local proc =sched.proc



local fdt = {
    wait_read  = { },
    read_func = { },
    wait_write = { },
    write_func = { }
}
proc.fd = fdt

------------------------------------------------------------------------------
-- File descriptor handling functions go in this sub-module;
-- they're used, among others, to make luasocket sched-compatible.
------------------------------------------------------------------------------
sched.fd = { }

local os_time = os.clock
local math_min = math.min

------------------------------------------------------------------------------
-- Add a file descriptor to a watch list (wait_read or wait_write)
------------------------------------------------------------------------------
local function add_watch(rw, fd, func)
  local t = fdt["wait_"..rw]
  if t[fd] then return nil, "file descriptor already registered" end
  local i = #t+1
  t[i] = fd
  t[fd] = i
  fdt[rw.."_func"][fd] = func
  return true
end

------------------------------------------------------------------------------
-- Remove a file descriptor from a watch list (wait_read or wait_write)
------------------------------------------------------------------------------
local function remove_watch(rw, fd)
  local t = fdt["wait_"..rw]
  if not t[fd] then return nil, "file descriptor unknown (not registered)" end
  local lasti = #t
  local i = t[fd]

  if lasti ~= i then -- swap fd that are at index i and lasti
    local last = t[lasti]
    t[i] = last
    t[last] = i
  end

  t[lasti] = nil
  t[fd] = nil
  fdt[rw.."_func"][fd] = nil

  return true
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function sched.fd.close(fd)
  remove_watch("read", fd) -- need to keep those remove_watch because some may have been added with when_fd function
  remove_watch("write", fd)
  sched.signal(fd, "closed")
end

------------------------------------------------------------------------------
-- local helper function
-- Wait for a file descriptor to be readable / writable
-- Block until the readable/writable condition is met or the timeout expires
-- Return true when readable/writable or nil followed by the error message
-- which is "timeout" when the given timeout expired
------------------------------------------------------------------------------
local function wait_fd(rw, fd, timelimit, timedelay)
  local stat, msg = add_watch(rw, fd)
  if not stat then return nil, msg end

  local timeout -- compute the first due date: either timeout per operation (timedelay) or global timeout (time limit)
  timelimit = timelimit and timelimit-os_time()
  timeout = timedelay and (timelimit and math_min(timelimit, timedelay) or timedelay) or timelimit

  local event, msg = sched.wait(fd, {rw, "error", "closed", timeout})
  if event == rw then stat, msg = true, nil
  elseif event == "timeout" then stat, msg =  nil, "timeout"
  elseif event == "closed" then stat, msg =  nil, "closed"
  else stat, msg =  nil, string.format("Channel error: %s", msg or 'unknown')
  end

  remove_watch(rw, fd)
  return stat, msg
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function sched.fd.wait_readable(fd, timelimit, timedelay)
  return wait_fd("read", fd, timelimit, timedelay)
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function sched.fd.wait_writable(fd, timelimit, timedelay)
  return wait_fd("write", fd, timelimit, timedelay)
end


------------------------------------------------------------------------------
-- local helper function
-- Register func to be called whenever the file descriptor fd is
-- readable/writable func is a function that can return "again" (or
-- something equivalent to true) in order to be called again if the
-- file descriptor is readable/writable again If func return false or
-- nil then the file descriptor is de-registered automatically Calling
-- this function with func=nil de-register the given file descriptor
------------------------------------------------------------------------------
local function when_fd(rw, fd, func)
  if func then
    return add_watch(rw, fd, func)
  else
    return remove_watch(rw, fd)
  end
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function sched.fd.when_readable(fd, func)
  return when_fd("read", fd, func)
end

------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
function sched.fd.when_writable(fd, func)
  return when_fd("write", fd, func)
end



------------------------------------------------------------------------------
-- Block on file descriptors until some are readable or the other are writable
--    see wait_read/wait_write list
-- wait until timeout is reached.
------------------------------------------------------------------------------
local function notify_fd(rw, notified)
  local t = fdt[rw.."_func"]
  for _, fd in ipairs(notified) do
    if t[fd] then
      local r = t[fd](fd)
      if not r then remove_watch(rw, fd) end
    end
    sched.signal(fd, rw)
  end
end


------------------------------------------------------------------------------
-- This may seems very hacky, but it there to ensure no require-time dependency
--  of sched over socket. At first call this function require socket and retreive
--  socket.select function
------------------------------------------------------------------------------
local socket_select

sched.is_running=function()
	return proc and proc.__tasks and proc.__tasks.running
end

sched.out_os={os.pullEvent,os.pullEventRaw,os.pullEvent,os.sleep}

sched.in_os={
pullEventRaw= function (event)
	return select(2,sched.wait(nil,event))
end,
pullEvent = function (event)
	event,p1,p1,p3,p4,p5=select(2,sched.wait(nil,event))
	if event=='terminate' then
		sched.kill(proc.__tasks.running)
	else
		return event,p1,p1,p3,p4,p5
	end
end,
sleep = function (n)
	sched.sleep(n)
end
}

sched.all_os={}
for i,v in pairs(sched.out_os) do
	sched.all_os[i]=function(...)
		if proc and proc.__tasks and proc.__tasks.running then
			return sched.in_os[i](...)
		else
			return v(...)
		end
	end
end

sched.replace_os_with=function(t)
	for i,v in pairs(t) do
		os[i]=v
	end
end
local os_pullEventRaw=os.pullEventRaw
function sched.fd.step(timeout)
  --not ported until needed
  --if not socket_select then local psignal = require 'sched.posixsignal'; socket_select = psignal.select; end -- executed once at first call only !

  --local can_read, can_write, msg = socket_select(fdt.wait_read, fdt.wait_write, timeout)
	
  -- if msg=='timeout' then return 'timeout' end

  -- notify_fd("read", can_read)
  -- notify_fd("write", can_write)
	if timeout then
		log("fd", "INFO", "timeout is "..timeout)
		local id=os.startTimer(timeout)
		local event, p1,p2,p3,p4,p5
		repeat
			event, p1,p2,p3,p4,p5 = os_pullEventRaw()
			log("fd", "INFO", "got event "..event)
			sched.signal(sched,event,p1,p2,p3,p4,p5)
		until event=='timer' and p1==id
	else
		log("fd", "INFO", "no timeout")
		sched.signal(sched,os_pullEventRaw())
	end
	log("fd", "INFO", "leaving fd.step")
end

return sched.fd
