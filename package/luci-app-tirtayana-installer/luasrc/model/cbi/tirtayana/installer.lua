-- LuCI CBI model: Install OpenWrt to eMMC
-- Tirtayana Service - tab 1: Install

local m, s, o

m = Map("tirtayana", translate("Install OpenWrt to eMMC"),
	translate("Flash OpenWrt permanently to the device eMMC storage. " ..
	"Requires the ophub amlogic packaging scripts. " ..
	"<strong>This operation will overwrite your current eMMC contents.</strong>"))

s = m:section(NamedSection, "tirtayana", "tirtayana", translate("Install Settings"))
s.addremove = false

o = s:option(ListValue, "board", translate("Target Board"))
o:value("B860H",   "STB B860H (Amlogic S905X)")
o:value("HG680P",  "STB HG680-P (Amlogic S905X)")
o:value("s905x3",  "Generic S905X3")
o:value("s905x2",  "Generic S905X2")
o:value("s905x",   "Generic S905X")
o.default = "B860H"

o = s:option(Value, "rootfs_size", translate("RootFS Partition Size (MB)"))
o.default = "1024"
o.datatype = "range(512, 4096)"

-- Action button section
s2 = m:section(TypedSection, "_dummy_install", translate("Run Installation"))
s2.anonymous = true
s2.addremove = false

o2 = s2:option(Button, "_install", translate("Install OpenWrt to eMMC"))
o2.inputtitle = translate("Install to eMMC")
o2.inputstyle = "apply"
o2.write = function(self, section)
	local board = m:get("tirtayana", "board") or "B860H"
	luci.http.redirect(luci.dispatcher.build_url(
		"admin", "system", "tirtayana", "run") ..
		"?action=install&board=" .. board)
end

o3 = s2:option(DummyValue, "_info", translate(""))
o3.rawhtml = true
o3.value = [[
<div style="background:#fff3cd;border-left:4px solid #cc8800;padding:12px 16px;border-radius:4px;margin-top:10px;">
  <strong>Before Installing:</strong><br>
  <ul style="margin:8px 0 0 16px;">
    <li>Back up your Android ROM first: run <code>openwrt-ddbr</code> in the Backup tab</li>
    <li>Make sure the device is running from USB/SD, not eMMC</li>
    <li>The process takes 5–15 minutes and the device will reboot</li>
  </ul>
</div>
]]

return m
