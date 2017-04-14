local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()
local site = require 'gluon.site_config'
local fs = require "nixio.fs"
local sys = luci.sys

local M = {}

local function show_altitude()
  if ((site.config_mode or {}).geo_location or {}).show_altitude ~= false then
    return true
  end
  if uci:get_first("gluon-node-info", "location", "altitude") then
    return true
  end
  return false
end

function M.section(form)
  local lat = uci:get_first("gluon-node-info", 'location', "latitude")
  local lon = uci:get_first("gluon-node-info", 'location', "longitude")
  local unlocode = uci:get_first("gluon-node-info", "location", "locode")
  if not lat then lat=0 end
  if not lon then lon=0 end
  if (lat == 0) and (lon == 0) then
    luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
  elseif (lat == "51") and (lon == "9") then
    luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
  elseif not unlocode then
    luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
  end

  local s = form:section(cbi.SimpleSection, nil,
    [[Um Deinen Knoten auf der Karte anzeigen zu k&ouml;nnen, ben&ouml;tigen
    wir Deine Zustimmung. Es w&auml;re sch&ouml;n, wenn Du uns diese hier
    geben w&uuml;rdest.]])

  local o

  o = s:option(cbi.Flag, "_location", i18n.translate("Show node on the map"))
  o.default = uci:get_first("gluon-node-info", "location", "share_location", o.disabled)
  o.rmempty = false
end

function M.handle(data)
  local sname = uci:get_first("gluon-node-info", "location")
  local unlocode = uci:get_first("gluon-node-info", "location", "locode")

  uci:set("gluon-node-info", sname, "share_location", data._location)
  uci:save("gluon-node-info")
  if not unlocode then
    luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
  end
  uci:commit("gluon-node-info")
end

return M
