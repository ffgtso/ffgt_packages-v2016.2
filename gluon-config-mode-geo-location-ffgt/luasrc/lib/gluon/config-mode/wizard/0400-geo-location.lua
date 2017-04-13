local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()
local site = require 'gluon.site_config'
local fs = require "nixio.fs"

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
  -- os.execute('/lib/gluon/config-mode/check4online.sh')
  -- if not fs.access("/tmp/is_online") then
  --   local s = form:section(cbi.SimpleSection, nil, [[<b>Keine Internetverbindung!</b>
  --      Bitte schlie&szlig;e den Knoten &uuml;ber den <i>blauen</i> bzw. WAN-Port an Deinen
  --      Internetrouter an, damit die Konfiguration korrekt vorgenommen werden kann. Ohne
  --      Internetzugang (freier Zugang via HTTP (Port 80, 443) und zum DNS (Port 53)) ist
  --      die Konfiguration derzeit NICHT m&ouml;glich. Die Konfiguration mu&szlig; NICHT
  --      am Aufstellort vorgenommen werden, dies kann &uuml;berall geschehen.]])
  -- end

  -- local text = i18n.translate('If you want the location of your node to '
  --  .. 'be displayed on the map, you can enter its coordinates here.')
  -- if show_altitude() then
  --   text = text .. ' ' .. i18n.translate('Specifying the altitude is '
  --     .. 'optional and should only be done if a proper value is known.')
  -- end
  --local s = form:section(cbi.SimpleSection, nil, text)


  local o

  o = s:option(cbi.Flag, "_location", i18n.translate("Show node on the map"))
  o.default = uci:get_first("gluon-node-info", "location", "share_location", o.disabled)
  o.rmempty = false

  -- o = s:option(cbi.Value, "_latitude", i18n.translate("Latitude"))
  -- o.default = uci:get_first("gluon-node-info", "location", "latitude")
  -- o:depends("_location", "1")
  -- o.rmempty = false
  -- o.datatype = "float"
  -- o.description = i18n.translatef("e.g. %s", "53.873621")

  -- o = s:option(cbi.Value, "_longitude", i18n.translate("Longitude"))
  -- o.default = uci:get_first("gluon-node-info", "location", "longitude")
  -- o:depends("_location", "1")
  -- o.rmempty = false
  -- o.datatype = "float"
  -- o.description = i18n.translatef("e.g. %s", "10.689901")

  -- local mystr
  -- --if lat == 0 and lon == 0 then
  --  mystr = string.format("Hier sollte unsere &Uuml;bersichtskarte zu sehen sein, sofern Dein Computer Internet-Zugang hat. Einfach die Karte auf Deinen Standort ziehen/zoomen, den Button zur Koordinatenanzeige klicken und nach dem Klick in die Karte dann die Daten in die Felder oben kopieren:<p><iframe src=\"http://map.4830.org/geomap.html\" width=\"100%%\" height=\"700\">Unsere Knotenkarte</iframe></p>")
  -- --else
  -- --  mystr = string.format("Hier sollte unsere Karte zu sehen sein, sofern Dein Computer Internet-Zugang hat. Einfach die Karte auf Deinen Standort ziehen/zoomen, den Button zur Koordinatenanzeige klicken und nach dem Klick in die Karte dann die Daten in die Felder oben kopieren:<p><iframe src=\"http://map.4830.org/geomap.html#lat=%f&amp;lon=%f\" width=\"100%%\" height=\"700\">Unsere Knotenkarte</iframe></p>", lat, lon)
  -- --end
  -- local s = form:section(cbi.SimpleSection, nil, mystr)

  -- if show_altitude() then
  --   o = s:option(cbi.Value, "_altitude", i18n.translate("Altitude"))
  --   o.default = uci:get_first("gluon-node-info", "location", "altitude")
  --   o:depends("_location", "1")
  --   o.rmempty = true
  --   o.datatype = "float"
  --   o.description = i18n.translatef("e.g. %s", "11.51")
  -- end

end

function M.handle(data)
  local sname = uci:get_first("gluon-node-info", "location")

  uci:set("gluon-node-info", sname, "share_location", data._location)
  -- if data._location and data._latitude ~= nil and data._longitude ~= nil then
  --   uci:set("gluon-node-info", sname, "latitude", data._latitude:trim())
  --   uci:set("gluon-node-info", sname, "longitude", data._longitude:trim())
  --   if data._altitude ~= nil then
  --     uci:set("gluon-node-info", sname, "altitude", data._altitude:trim())
  --   else
  --     uci:delete("gluon-node-info", sname, "altitude")
  --   end
  -- end
  uci:save("gluon-node-info")
  uci:commit("gluon-node-info")
end

return M
