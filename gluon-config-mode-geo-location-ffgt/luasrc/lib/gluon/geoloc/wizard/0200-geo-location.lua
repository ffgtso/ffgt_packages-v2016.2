local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()
local sys = luci.sys
local fs = require "nixio.fs"

local M = {}

function M.section(form)
  if not fs.access("/tmp/is_online") then
    -- (re-)try ...
    os.execute('/lib/gluon/config-mode/check4online.sh')
  end
  if not fs.access("/tmp/is_online") then
    local s = form:section(cbi.SimpleSection, nil, [[<b>Keine Internetverbindung!</b>
       Bitte schlie&szlig;e den Knoten &uuml;ber den <i>blauen</i> Port an Deinen
       Internetrouter an, damit die Konfiguration korrekt vorgenommen werden kann. Ohne
       Internetzugang (freier Zugang via HTTP (Port 80, 443) und zum DNS (Port 53)) ist
       die Konfiguration derzeit NICHT m&ouml;glich.]])
  end

  local lat = uci:get_first("gluon-node-info", 'location', "latitude")
  local lon = uci:get_first("gluon-node-info", 'location', "longitude")
  if not lat then lat=0 end
  if not lon then lon=0 end
  lat=tonumber(lat)
  lon=tonumber(lon)
  local maplat = lat
  local maplon = lon
  if ((lat == 51.0) and (lon == 9.0)) then
    local s = form:section(cbi.SimpleSection, nil,
    [[<b>Die Adressaufl&ouml;sung ist fehlgeschlagen.</b> Bitte &uuml;berpr&uuml;fe Deine
    Koordinaten, sie konnten keinem Ort zugeordnet werden. Bitte beachte, da&szlig; Dein
    Knoten Internet-Zugang haben mu&szlig;, damit die Daten validiert werden k&ouml;nnen.]])
    maplat = "51.908624626589585"
    maplon = "8.380953669548035"
    lat=0
    lon=0
  end
  -- At this point, lat/lon are numbers.

  local s = form:section(cbi.SimpleSection, nil, [[]])
  local sname = uci:get_first("gluon-node-info", "location")
  local o

  o = s:option(cbi.Value, "_latitude", "Breitengrad")
  if lat ~= 0 then
    o.default = lat
  end
  o.rmempty = false
  o.datatype = "float"
  o.description = "z.B. 53.873621"
  o.optional = false

  o = s:option(cbi.Value, "_longitude", "Längengrad")
  if lon ~= 0 then
    o.default = lon
  end
  o.rmempty = false
  o.datatype = "float"
  o.description = "z.B. 10.689901"
  o.optional = false

 if ((lat ~= 51.0 and lat ~= 0) and (lon ~= 9.0 and lon ~= 0)) then
    local unlocode = uci:get_first("gluon-node-info", 'location', 'locode') or "none"
    local addr = uci:get_first("gluon-node-info", 'location', "addr") or "FEHLER_ADDR"
    local city = uci:get_first("gluon-node-info", 'location', "city") or "FEHLER_ORT"
    local zip = uci:get_first("gluon-node-info", 'location', "zip") or "00000"
    local community = uci:get_first('siteselect', unlocode, 'sitename') or "zzz"
    local mystr
    community=string.gsub(sys.exec(string.format('/sbin/uci get siteselect.%s.sitename', unlocode)), "\n", "")
    mystr = string.format("Lokalisierung des Knotens erfolgreich; bitte Daten &uuml;berpr&uuml;fen:<br></br><b>Adresse:</b> %s, %s %s<br></br><b>Koordinaten:</b> %f %f<br></br><b>Community:</b> %s", addr, zip, city, lat, lon, community)
    local s = form:section(cbi.SimpleSection, nil, mystr)
  end

  local mystr
  if lat == 0 and lon == 0 then
    mystr = string.format("Hier sollte unsere &Uuml;bersichtskarte zu sehen sein, sofern Dein Computer Internet-Zugang hat. Einfach die Karte auf Deinen Standort ziehen/zoomen, den Button zur Koordinatenanzeige klicken und nach dem Klick in die Karte dann die Daten in die Felder oben kopieren:<p><iframe src=\"http://map.4830.org/geomap.html\" width=\"100%%\" height=\"700\">Unsere Knotenkarte</iframe></p>")
  else
    mystr = string.format("Hier sollte unsere Karte zu sehen sein, sofern Dein Computer Internet-Zugang hat. Einfach die Karte auf Deinen Standort ziehen/zoomen, den Button zur Koordinatenanzeige klicken und nach dem Klick in die Karte dann die Daten in die Felder oben kopieren:<p><iframe src=\"http://map.4830.org/geomap.html#lat=%f&amp;lon=%f\" width=\"100%%\" height=\"700\">Unsere Knotenkarte</iframe></p>", lat, lon)
  end
  local s = form:section(cbi.SimpleSection, nil, mystr)
end

function M.handle(data)
  function trim(s)
    return s:match "^%s*(.-)%s*$"
  end

  if not fs.access("/tmp/is_online") then
    luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
  end

  local sname = uci:get_first("gluon-node-info", "location")
  if data._latitude ~= nil and data._longitude ~= nil then
    data._latitude=trim(data._latitude)
    data._longitude=trim(data._longitude)
    local lat = tonumber(sys.exec("uci get gluon-node-info.@location[0].latitude 2>/dev/null")) or 0
    local lon = tonumber(sys.exec("uci get gluon-node-info.@location[0].longitude 2>/dev/null")) or 0
    local unlocode = sys.exec("uci get gluon-node-info.@location[0].locode 2>/dev/null")
    if unlocode then
      unlocode = string.gsub(unlocode, "\n", "")
    else
      os.execute('/lib/gluon/ffgt-geolocate/rgeo.sh')
      unlocode = sys.exec("uci get gluon-node-info.@location[0].locode 2>/dev/null")
      if not unlocode then
        luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
      end
    end
    local newlat = tonumber(data._latitude) or 51
    local newlon = tonumber(data._longitude) or 9
    if lat ~= newlat or lon ~= newlon then
      uci:set("gluon-node-info", sname, "latitude", data._latitude)
      uci:set("gluon-node-info", sname, "longitude", data._longitude)
      uci:save("gluon-node-info")
      uci:commit("gluon-node-info")
      os.execute('/lib/gluon/ffgt-geolocate/rgeo.sh')
      -- Hrmpft. This isn't working due to ... caching? Darn, LuCI!
      --local ucinew = luci.model.uci.cursor()
      --local lat = ucinew:get_first("gluon-node-info", sname, "latitude")
      --local lon = ucinew:get_first("gluon-node-info", sname, "longitude")
      --local locode = ucinew:get_first("gluon-node-info", sname, "locode")
      --if not locode or (lat == "51" and lon == "9") then
      --if verifylocation() == 0 then
      --  luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
      --end
      lat = tonumber(sys.exec("uci get gluon-node-info.@location[0].latitude 2>/dev/null")) or 0
      lon = tonumber(sys.exec("uci get gluon-node-info.@location[0].longitude 2>/dev/null")) or 0
      if ((lat == 0) or (lat == 51)) and ((lon == 0) or (lon == 9)) then
        luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
      end
    end
  end
  os.execute('/lib/gluon/upgrade/020-site-select &')
end

return M
