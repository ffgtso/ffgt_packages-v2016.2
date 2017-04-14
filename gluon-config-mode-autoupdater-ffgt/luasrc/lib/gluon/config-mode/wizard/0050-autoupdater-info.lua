local cbi = require "luci.cbi"
local i18n = require "luci.i18n"
local uci = luci.model.uci.cursor()

local M = {}

function M.section(form)
  local enabled = uci:get_bool("autoupdater", "settings", "enabled")
  if enabled then
    local s = form:section(cbi.SimpleSection, nil,
      i18n.translate('This node will automatically update its firmware when a new version is available.'))
  else
    local s = form:section(cbi.SimpleSection, nil,
      [[Dieser Knoten aktualisiert seine Firmware <b>nicht automatisch</b>.
      Bitte reaktiviere diese Funktion in den
      <i><a href="/cgi-bin/luci/admin/autoupdater/">Erweiterten Einstellungen</a></i>.]])
  end
end

function M.handle(data)
  return
end

return M
