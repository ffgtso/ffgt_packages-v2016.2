local geoloc_dir = "/lib/gluon/config-mode/geoloc/"
local i18n = luci.i18n
local uci = luci.model.uci.cursor()
local fs = require "nixio.fs"
local util = require "nixio.util"
local f, s

local geoloc = {}
local files = {}

if fs.access(geoloc_dir) then
  files = util.consume(fs.dir(geoloc_dir))
  table.sort(files)
end

for _, entry in ipairs(files) do
  if entry:sub(1, 1) ~= '.' then
    table.insert(geoloc, dofile(geoloc_dir .. '/' .. entry))
  end
end

f = SimpleForm("geoloc")
f.reset = false
f.template = "gluon/cbi/config-mode-geoloc"

for _, s in ipairs(geoloc) do
  s.section(f)
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    for _, s in ipairs(geoloc) do
      s.handle(data)
    end

    luci.http.redirect(luci.dispatcher.build_url("gluon-config-mode", "wizard"))
  end

  return true
end

return f
