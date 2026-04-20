-- LuCI CBI model: Update Kernel
-- Tirtayana Service - tab 2: Kernel Update

local m, s, o

m = Map("tirtayana", translate("Update Kernel"),
	translate("Download and apply a new kernel for your Amlogic device. " ..
	"The selected kernel series will be fetched automatically from the ophub kernel repository."))

s = m:section(NamedSection, "tirtayana", "tirtayana", translate("Kernel Settings"))
s.addremove = false

o = s:option(ListValue, "kernel", translate("Kernel Series"))
o:value("5.15.y", "Linux 5.15.y (LTS - Minimal)")
o:value("6.1.y",  "Linux 6.1.y  (LTS - Standard)")
o:value("6.6.y",  "Linux 6.6.y  (LTS - Education / Latest)")
o.default = "6.1.y"

s2 = m:section(TypedSection, "_dummy_kernel", translate("Apply Kernel Update"))
s2.anonymous = true
s2.addremove = false

o2 = s2:option(Button, "_update", translate("Update Kernel"))
o2.inputtitle = translate("Update Kernel Now")
o2.inputstyle = "apply"
o2.write = function(self, section)
	local kernel = m:get("tirtayana", "kernel") or "6.1.y"
	luci.http.redirect(luci.dispatcher.build_url(
		"admin", "system", "tirtayana", "run") ..
		"?action=kernel&kernel=" .. kernel)
end

o3 = s2:option(DummyValue, "_info2", translate(""))
o3.rawhtml = true
o3.value = [[
<div style="background:#d1ecf1;border-left:4px solid #17a2b8;padding:12px 16px;border-radius:4px;margin-top:10px;">
  <strong>Kernel Update Notes:</strong><br>
  <ul style="margin:8px 0 0 16px;">
    <li>Your configuration and packages are preserved during a kernel update</li>
    <li>Use <strong>5.15.y</strong> for maximum stability on S905X devices</li>
    <li>Use <strong>6.6.y</strong> for the latest features (may be less tested on S905X)</li>
    <li>The device will reboot after the update completes</li>
  </ul>
</div>
]]

return m
