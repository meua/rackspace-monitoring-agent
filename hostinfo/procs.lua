--[[
Copyright 2015 Rackspace

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--]]
local HostInfo = require('./base').HostInfo
local sigar = require('sigar')

--[[ Process Info ]]--
local Info = HostInfo:extend()

function Info:initialize()
  HostInfo.initialize(self)
end
function Info:_run(callback)
  local ctx, procs
  ctx = sigar:new()
  procs = ctx:procs()
  for i=1, #procs do
    local pid = procs[i]
    local proc = ctx:proc(pid)
    local obj = {}
    obj.pid = pid

    local t = proc:exe()
    if t then
      local exe_fields = {
        'name',
        'cwd',
        'root'
      }
      for _, v in pairs(exe_fields) do
        obj['exe_' .. v] = t[v]
      end
    end

    t = proc:time()
    if t then
      local time_fields = {
        'start_time',
        'user',
        'sys',
        'total'
      }
      for _, v in pairs(time_fields) do
        obj['time_' .. v] = t[v]
      end
    end

    t = proc:state()
    if t then
      local proc_fields = {
        'name',
        'ppid',
        'priority',
        'nice',
        'threads'
      }
      for _, v in pairs(proc_fields) do
        obj['state_' .. v] = t[v]
      end
    end

    t = proc:mem()
    if t then
      local memory_fields = {
        'size',
        'resident',
        'share',
        'major_faults',
        'minor_faults',
        'page_faults'
      }
      for _, v in pairs(memory_fields) do
        obj['memory_' .. v] = t[v]
      end
    end

    table.insert(self._params, obj)
  end
  callback()
end

function Info:getType()
  return 'PROCS'
end

return Info
