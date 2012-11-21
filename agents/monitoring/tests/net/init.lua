local table = require('table')
local async = require('async')
local ConnectionStream = require('monitoring/default/client/connection_stream').ConnectionStream
local misc = require('monitoring/default/util/misc')
local helper = require('../helper')
local timer = require('timer')
local fixtures = require('../fixtures')
local constants = require('constants')
local consts = require('../../default/util/constants')
local Endpoint = require('../../default/endpoint').Endpoint
local path = require('path')

local exports = {}
local child

exports['test_reconnects'] = function(test, asserts)

  local options = {
    datacenter = 'test',
    stateDirectory = './tests',
    host = "127.0.0.1",
    port = 50061,
    tls = { rejectUnauthorized = false }
  }

  local client = ConnectionStream:new('id', 'token', 'guid', options)

  local clientEnd = 0
  local reconnect = 0

  client:on('client_end', function(err)
    clientEnd = clientEnd + 1
  end)

  client:on('reconnect', function(err)
    reconnect = reconnect + 1
  end)

  async.series({
    function(callback)
      child = helper.start_server(callback)
    end,
    function(callback)
      client:on('handshake_success', misc.nCallbacks(callback, 3))
      local endpoints = get_endpoints()
      client:createConnections(endpoints, function() end)
    end,
    function(callback)
      helper.stop_server(child)
      client:on('reconnect', counterTrigger(3, callback))
    end,
    function(callback)
      child = helper.start_server(function()
        client:on('handshake_success', counterTrigger(3, callback))
      end)
    end,
  }, function()
    helper.stop_server(child)
    asserts.ok(clientEnd > 0)
    asserts.ok(reconnect > 0)
    test.done()
  end)
end

exports['test_upgrades'] = function(test, asserts)
  local options, client, endpoints

  -- Override the default download path
  consts.DEFAULT_DOWNLOAD_PATH = path.join('.', 'tmp')

  options = {
    datacenter = 'test',
    stateDirectory = './tests',
    host = "127.0.0.1",
    port = 50061,
    tls = { rejectUnauthorized = false }
  }

  endpoints = get_endpoints()

  async.series({
    start_server,
    function(callback)
      client = ConnectionStream:new('id', 'token', 'guid', options)
      client:on('handshake_success', misc.nCallbacks(callback, 3))
      client:createConnections(endpoints, function() end)
    end,
    function(callback)
      callback = misc.nCallbacks(callback, 4)
      client:on('binary_upgrade.found', callback)
      client:on('bundle_upgrade.found', callback)
      client:on('bundle_upgrade.error', callback)
      client:on('binary_upgrade.error', callback)
      client:getUpgrade():forceUpgradeCheck()
    end
  }, function()
    client:done()
    stop_server()
    test.done()
  end)
end

return exports
