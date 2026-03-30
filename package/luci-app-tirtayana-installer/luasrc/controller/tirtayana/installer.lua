module("luci.controller.tirtayana.installer", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/tirtayana") then
		return
	end

	local page = entry({"admin", "system", "tirtayana"}, firstchild(), _("TIrtayana Service"), 60)
	page.dependent = false
	page.acl_depends = { "luci-app-tirtayana-installer" }

	entry({"admin", "system", "tirtayana", "installer"},
		cbi("tirtayana/installer"), _("Install OpenWrt"), 10)

	entry({"admin", "system", "tirtayana", "kernel"},
		cbi("tirtayana/kernel"), _("Update Kernel"), 20)

	entry({"admin", "system", "tirtayana", "backup"},
		cbi("tirtayana/backup"), _("Backup / Restore ROM"), 30)

	entry({"admin", "system", "tirtayana", "run"},
		call("action_run"), nil)
end

function action_run()
	local http = require("luci.http")
	local action = http.formvalue("action") or ""
	local board  = http.formvalue("board")  or "B860H"
	local kernel = http.formvalue("kernel") or "6.1.y"

	local cmd_map = {
		install = string.format("openwrt-install-amlogic 2>&1"),
		kernel  = string.format("openwrt-kernel %s 2>&1", kernel),
		backup  = "openwrt-ddbr 2>&1",
	}

	local cmd = cmd_map[action]
	if not cmd then
		http.prepare_content("text/plain")
		http.write("ERROR: unknown action: " .. action)
		return
	end

	http.prepare_content("text/plain")
	local f = io.popen(cmd)
	if f then
		for line in f:lines() do
			http.write(line .. "\n")
		end
		f:close()
	else
		http.write("ERROR: could not execute command")
	end
end
