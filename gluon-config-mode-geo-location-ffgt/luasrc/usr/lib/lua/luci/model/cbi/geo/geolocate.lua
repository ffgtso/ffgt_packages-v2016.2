--[[
LuCI - Lua Configuration Interface

Copyright 2015 Kai 'wusel' Siering <wusel+src@uu.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

os.execute('/lib/gluon/ffgt-geolocate/senddata.sh force')
local uci = luci.model.uci.cursor()

local hostname, addr, locode, city
local s
local f = SimpleForm("geolocate", "Geo-Lokalisierung")
f.template = "admin/expertmode"
f.submit = "Weiter"
-- f.reset = "Zurücksetzen"

s = f:section(SimpleSection, nil, [[Dein Knoten versucht nun im Hintergrund,
sich zu lokalisieren.
Sofern eine Internetverbindung besteht, sollte in wenigen Sekunden eine Position
ermittelt und diese abgespeichert werden. Falls dies der erste Aufruf des Setups
ist, wird der Knotennamen basierend auf der Lokalisierung vorgeschlagen.]])

-- os.execute("((/lib/gluon/ffgt-geolocate/geolocate.sh)&)")
-- os.execute('/lib/gluon/ffgt-geolocate/senddata.sh force')
os.execute('sleep 2')
luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode/wizard"))

s = f:section(SimpleSection, nil, [[Weiter mit "Weiter".]])

function f.handle(self, state, data)
  return true
end

return f
