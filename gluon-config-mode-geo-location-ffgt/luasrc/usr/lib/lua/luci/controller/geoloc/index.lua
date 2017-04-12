--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>
Copyright 2008 Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

module("luci.controller.geoloc.index", package.seeall)

function index()
	local uci_state = luci.model.uci.cursor_state()

	-- Disable gluon-luci-admin when setup mode is not enabled
	if uci_state:get_first('gluon-setup-mode', 'setup_mode', 'running', '0') ~= '1' then
		return
	end

	local root = node()
	if not root.lock then
		root.target = alias("geoloc")
		root.index = true
	end

	local page = entry({"geoloc"}, alias("geoloc", "index"), _("Geolocate"), 10)
	page.sysauth = "root"
	page.sysauth_authenticator = function() return "root" end
	page.index = true

	entry({"geoloc", "index"}, cbi("geoloc/info"), _("Information"), 1).ignoreindex = true
    entry({"geoloc", "locate"}, call("geolocate"))
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
  luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard"))
end
