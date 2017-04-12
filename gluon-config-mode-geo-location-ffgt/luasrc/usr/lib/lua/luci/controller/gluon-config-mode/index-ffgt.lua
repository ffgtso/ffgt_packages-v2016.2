--[[
Copyright 2013 Nils Schneider <nils@nilsschneider.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--
local uci = luci.model.uci.cursor()

module("luci.controller.gluon-config-mode.index-ffgt", package.seeall)

function index()
   entry({"geolocate"}, call("geolocate"))
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
