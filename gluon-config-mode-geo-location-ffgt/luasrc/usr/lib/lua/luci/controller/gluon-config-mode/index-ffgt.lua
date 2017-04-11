--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--
local uci = luci.model.uci.cursor()

module("luci.controller.gluon-config-mode.index", package.seeall)

function index()
  local uci_state = luci.model.uci.cursor_state()

  if uci_state:get_first("gluon-setup-mode", "setup_mode", "running", "0") == "1" then
    local root = node()
    if not root.target then
      root.target = alias("gluon-config-mode")
      root.index = true
    end

    page          = node()
    page.lock     = true
    page.target   = alias("gluon-config-mode")
    page.subindex = true
    page.index    = false

    page          = node("gluon-config-mode")
    page.title    = _("Wizard")
    page.target   = alias("gluon-config-mode", "wizard-prepare")
    page.order    = 5
    page.setuser  = "root"
    page.setgroup = "root"
    page.index    = true

    entry({"gluon-config-mode", "wizard-prepare"}, call("prepare"))
    entry({"gluon-config-mode", "wizard-pre"}, form("gluon-config-mode/wizard-pre")).index = true
    entry({"gluon-config-mode", "wizard"}, form("gluon-config-mode/wizard"))
    entry({"gluon-config-mode", "geolocate"}, call("geolocate"))
    entry({"gluon-config-mode", "reboot"}, call("action_reboot"))
  end
end

function prepare()
  if uci:get_first("gluon-setup-mode", "setup_mode", "configured") == "0" then
    -- FIXME! Does this belong here?
    -- This code sets some presets for our Firmwares.
    local uci = luci.model.uci.cursor()
    local secret = uci:get("fastd", "mesh_vpn", "secret")

    if not secret or not secret:match("%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x") then
      local f = io.popen("fastd --generate-key --machine-readable", "r")
      local secret = f:read("*a")
      f:close()

      uci:set("fastd", "mesh_vpn", "secret", secret)
      uci:save("fastd")
      uci:commit("fastd")

      uci:set("autoupdater", "settings", "enabled", "1")
      uci:save("autoupdater")
      uci:commit("autoupdater")

      uci:set("fastd", "mesh_vpn", "enabled", "1")
      uci:save("fastd")
      uci:commit("fastd")

      uci:set("gluon-simple-tc", "mesh_vpn", "interface")
      uci:set("gluon-simple-tc", "mesh_vpn", "ifname", "mesh-vpn")
      uci:set("gluon-simple-tc", "mesh_vpn", "enabled", "0")
      uci:save("gluon-simple-tc")
      uci:commit("gluon-simple-tc")

      local sname = uci:get_first("gluon-node-info", "location")
      uci:set("gluon-node-info", sname, "share_location", "1")
      uci:save("gluon-node-info")
      uci:commit("gluon-node-info")
    end
  end
  luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard-pre"))
end

function geolocate()
  -- If there's no location set, try to get something via callback, as we need this for
  -- selecting the proper settings.
  -- Actually, just allow to have this runninig once anyway -- e. g. on a relocated node.
  -- local lat = uci:get_first("gluon-node-info", 'location', "latitude")
  -- local lon = uci:get_first("gluon-node-info", 'location', "longitude")
  -- if not lat or not lon then
    os.execute('/lib/gluon/ffgt-geolocate/senddata.sh force')
    os.execute('sleep 2')
  -- end
  luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard-pre"))
end

function action_reboot()
  local util = require "luci.util"
  local uci = luci.model.uci.cursor()
  local sysconfig = require 'gluon.sysconfig'
  local lat = uci:get_first("gluon-node-info", "location", "latitude")
  local lon = uci:get_first("gluon-node-info", "location", "longitude")
  local pubkey = util.exec("/etc/init.d/fastd show_key " .. "mesh_vpn")

  if lat and lon then
     location = lat .. "%20" .. lon
  else
     location = ""
  end

  uci:set("gluon-setup-mode", uci:get_first("gluon-setup-mode", "setup_mode"), "configured", "1")
  uci:save("gluon-setup-mode")
  uci:commit("gluon-setup-mode")

  if nixio.fork() ~= 0 then
    local fs = require "nixio.fs"
    local util = require "nixio.util"

    local parts_dir = "/lib/gluon/config-mode/reboot/"
    local files = util.consume(fs.dir(parts_dir))

    table.sort(files)

    local parts = {}

    for _, entry in ipairs(files) do
      if entry:sub(1, 1) ~= '.' then
        local f = dofile(parts_dir .. '/' .. entry)
        if f ~= nil then
          table.insert(parts, f)
        end
      end
    end

    local hostname = uci:get_first("system", "system", "hostname")

    luci.template.render("gluon/config-mode/reboot", { parts=parts
                                                     , hostname=hostname
                                                     , sysconfig=sysconfig
                                                     , location=location
                                                     , pubkey=pubkey
                                                   })
  else
    debug.setfenv(io.stdout, debug.getfenv(io.open '/dev/null'))
    io.stdout:close()

    -- Sleep a little so the browser can fetch everything required to
    -- display the reboot page, then reboot the device.
    nixio.nanosleep(2)

    -- Run reboot with popen so it gets its own std filehandles.
    io.popen("reboot")

    -- Prevent any further execution in this child.
    os.exit()
  end
end
