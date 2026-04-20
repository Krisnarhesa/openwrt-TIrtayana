-- LuCI CBI model: Backup / Restore ROM
-- Tirtayana Service - tab 3: Backup

local m, s, o

m = Map("tirtayana", translate("Backup / Restore Android ROM"),
	translate("Use <code>openwrt-ddbr</code> to back up or restore your original Android ROM. " ..
	"The backup image is stored on the current boot device (USB/SD card)."))

s = m:section(TypedSection, "_dummy_backup", translate("Actions"))
s.anonymous = true
s.addremove = false

o = s:option(Button, "_backup", translate("Backup Android ROM"))
o.inputtitle = translate("Backup Android ROM to USB/SD")
o.inputstyle = "apply"
o.write = function(self, section)
	luci.http.redirect(luci.dispatcher.build_url(
		"admin", "system", "tirtayana", "run") ..
		"?action=backup")
end

o2 = s:option(DummyValue, "_backup_info", translate(""))
o2.rawhtml = true
o2.value = [[
<div style="background:#d4edda;border-left:4px solid #28a745;padding:12px 16px;border-radius:4px;margin-top:10px;margin-bottom:20px;">
  <strong>Backup Process:</strong><br>
  <ul style="margin:8px 0 0 16px;">
    <li>Creates a full backup of your Android eMMC ROM image</li>
    <li>Backup file is saved to the current boot device (USB/SD card)</li>
    <li>Always backup before installing OpenWrt to eMMC!</li>
    <li>Backup size is typically 4–8 GB and takes 10–30 minutes</li>
  </ul>
</div>
<hr style="margin:16px 0;">
<p><strong>Restore Android ROM:</strong> To restore your original Android ROM from a backup, run the following command via SSH:</p>
<pre style="background:#f5f5f5;padding:10px;border-radius:4px;">openwrt-ddbr</pre>
<p style="color:#666;font-size:0.9em;">Then select option <strong>2</strong> (Restore) when prompted.</p>
]]

return m
