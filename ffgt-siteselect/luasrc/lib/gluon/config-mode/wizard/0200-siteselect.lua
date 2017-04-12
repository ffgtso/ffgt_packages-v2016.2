local cbi = require "luci.cbi"
local uci = luci.model.uci.cursor()
local site = require 'gluon.site_config'
local fs = require "nixio.fs"
local sys = luci.sys

local sites = {}
local M = {}

-- FIXME: this should use embdded lua-uci, but uci will be dropped in Gluon anyway, so why bother?
function M.section(form)
    local lat = uci:get_first("gluon-node-info", 'location', "latitude")
    local lon = uci:get_first("gluon-node-info", 'location', "longitude")
    local unlocode = uci:get_first("gluon-node-info", "location", "locode")
    if not lat then lat=0 end
    if not lon then lon=0 end
    if not unlocode or (lat == "51" and lon == "9") then
      luci.http.redirect(luci.dispatcher.build_url("geoloc/wizard"))
    end
    if ((lat == 0) or (lat == "51")) and ((lon == 0) or (lon == "9")) then
	    local s = form:section(cbi.SimpleSection, nil, [[
	    Geo-Lokalisierung schlug fehl :( Hier hast Du die Möglichkeit,
	    die Community, mit der sich Dein Knoten verbindet, auszuwählen.
	    Bitte denke daran, dass Dein Router sich dann nur mit dem Netz
	    der ausgewählten Community verbindet und ggf. lokales Meshing nicht
	    funktioniert bei falscher Auswahl. Vorzugsweise schließt Du
	    Deinen Freifunk-Knoten jetzt an Deinen Internet-Router an und
	    startest noch mal von vorn.
	    ]])
	
    	uci:foreach('siteselect', 'site',
    	function(s)
    		table.insert(sites, s['.name'])
    	end
    	)

	    local o = s:option(cbi.ListValue, "community", "Community")
    	o.rmempty = false
	    o.optional = false

	    if uci:get_first("gluon-setup-mode", "setup_mode", "configured") == "0" then
	    	o:value(unlocode, uci:get_first('siteselect', unlocode, 'sitename'))
	    else
		    o:value(site.site_code, site.site_name)
	    end

	    for index, site in ipairs(sites) do
	    	o:value(site, uci:get('siteselect', site, 'sitename'))
        end
    end
end

function M.handle(data)
    if data.community then
        --if data.community ~= site.site_code then
            uci:set('gluon-node-info', 'location', 'debug1a', data.community)
            uci:set('gluon-node-info', 'location', 'debug1b', 'done')
            uci:save('gluon-node-info')
            uci:commit('gluon-node-info')

            -- Deleting this unconditionally would leave the node without a secret in case the
            -- check fails later on. Moving the delete down into the if-clauses.
            -- uci:delete('fastd', 'mesh_vpn', 'secret')

            local secret = uci:get_first('siteselect', data.community, 'secret')

            if not secret or not secret:match(("%x"):rep(64)) then
                uci:delete('siteselect', data.community, 'secret')
            else
                -- uci:delete('fastd', 'mesh_vpn', 'secret')
                uci:set('fastd', 'mesh_vpn', "secret", secret)
            end

            uci:save('fastd')
            uci:commit('fastd')

            -- We need to store the selection somewhere. To make this simple,
            -- put it into gluon-node-info:location.siteselect ...
            uci:delete('gluon-node-info', 'location', 'siteselect')
            uci:set('gluon-node-info', 'location', 'siteselect', data.community)
            uci:save('gluon-node-info')
            uci:commit('gluon-node-info')

            fs.copy(uci:get('siteselect', data.community , 'path'), '/lib/gluon/site.json')
            os.execute('sh "/lib/gluon/site-upgrade"')
        --end
    else
        -- The UN/LOCODE is the relevant information. No user servicable parts in the UI ;)
        local unlocode = uci:get_first("gluon-node-info", 'location', "locode")
        local current = uci:get_first('gluon-node-info', 'location', 'siteselect')

        local secret = uci:get_first('siteselect', unlocode, 'secret')

        if not secret or not secret:match(("%x"):rep(64)) then
            uci:delete('siteselect', unlocode, 'secret')
            uci:save('siteselect')
            uci:commit('siteselect')
        else
            uci:delete('fastd', 'mesh_vpn', 'secret')
            uci:set('fastd', 'mesh_vpn', "secret", secret)
            uci:save('fastd')
            uci:commit('fastd')
        end

        -- We need to store the selection somewhere. To make this simple,
        -- put it into gluon-node-info.location.siteselect ...
        --uci:delete('gluon-node-info', 'location', 'siteselect')
        uci:set('gluon-node-info', 'location', 'siteselect', unlocode)
        uci:save('gluon-node-info')
        uci:commit('gluon-node-info')
        sys.exec(string.format("/sbin/uci set gluon-node-info.@location[0].siteselect=%c%s%c 2>/dev/null", 39, unlocode, 39))
        sys.exec(string.format("/sbin/uci commit gluon-node-info 2>/dev/null"))

        fs.copy(uci:get('siteselect', unlocode, 'path'), '/lib/gluon/site.json')
        -- os.execute("/bin/touch /tmp/need-to-run-site-upgrade")
        -- os.execute('sh "/lib/gluon/site-upgrade"')
        os.execute('/lib/gluon/upgrade/400-mesh-vpn-fastd')
        os.execute('/lib/gluon/upgrade/320-gluon-mesh-batman-adv-core-wireless')
    end
end

return M
