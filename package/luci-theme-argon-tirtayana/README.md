# LuCI Theme Argon - Tirtayana Edition

Custom LuCI theme for OpenWrt with Tirtayana branding and color palette inspired by OpenWrt 2020.

## Features

- **Modern Argon-style Design**: Clean and contemporary interface with gradient effects
- **Tirtayana Branding**: Custom logo and brand identity
- **OpenWrt 2020 Color Palette**: 
  - Primary Color: `#0b0b0b` (Dark Black)
  - Secondary Color: `#8a6800` (Golden Brown)
  - Accent Color: `#cc8800` (Orange)
  - Background: `#ffffff` (White)
  - Success: `#5cb85c` (Green)
  - Warning: `#cc8800` (Orange)
  - Danger: `#cc1111` (Red)
- **Responsive Design**: Mobile-friendly interface
- **Smooth Animations**: Modern transitions and hover effects
- **Custom Scrollbar**: Themed scrollbar matching the color palette
- **Professional Typography**: Clean, readable fonts

## Installation

### Building from Source

1. Copy this package to your OpenWrt buildroot:
   ```bash
   cp -r luci-theme-argon-tirtayana openwrt/package/
   ```

2. Select the theme in menuconfig:
   ```bash
   make menuconfig
   # Navigate to: LuCI > Themes
   # Select: luci-theme-argon-tirtayana
   ```

3. Build the package:
   ```bash
   make package/luci-theme-argon-tirtayana/compile V=s
   ```

4. Install on your router:
   ```bash
   scp bin/packages/*/base/luci-theme-argon-tirtayana*.ipk root@192.168.1.1:/tmp/
   ssh root@192.168.1.1
   opkg install /tmp/luci-theme-argon-tirtayana*.ipk
   ```

### Post-Installation

The theme will be automatically set as default after installation. To manually switch themes:

1. Go to System > System > Language and Style
2. Select "Argon Tirtayana" from the Design dropdown
3. Click Save & Apply

## Customization

### Changing Logo

Replace the logo file at:
```
htdocs/luci-static/argon-tirtayana/logo.svg
```

### Modifying Colors

Edit the CSS variables in `cascade.css`:
```css
:root {
  --primary-color: #0b0b0b;
  --secondary-color: #8a6800;
  --accent-color: #cc8800;
  /* ... modify as needed */
}
```

### Custom Backgrounds

You can add custom background images or patterns by modifying:
```css
body {
  background-color: var(--background-dark);
  /* Add background-image here if desired */
}
```

## File Structure

```
luci-theme-argon-tirtayana/
├── Makefile                          # OpenWrt package Makefile
├── README.md                         # This file
├── htdocs/
│   └── luci-static/
│       └── argon-tirtayana/
│           ├── cascade.css           # Main stylesheet
│           └── logo.svg              # Tirtayana logo
└── ucode/
    └── template/
        └── themes/
            └── argon-tirtayana/
                ├── header.ut         # Header template
                └── footer.ut         # Footer template
```

## Color Palette Reference

| Color Name       | Hex Code  | Usage                          |
|------------------|-----------|--------------------------------|
| Primary Dark     | `#0b0b0b` | Headers, main navigation       |
| Secondary Gold   | `#8a6800` | Buttons, accents, links        |
| Accent Orange    | `#cc8800` | Warnings, highlights           |
| Success Green    | `#5cb85c` | Success messages, confirmations|
| Danger Red       | `#cc1111` | Errors, delete actions         |
| Text Dark        | `#5d5d5d` | Body text                      |
| Background White | `#ffffff` | Main background                |

## Browser Compatibility

- Chrome/Chromium 60+
- Firefox 60+
- Safari 12+
- Edge 79+
- Mobile browsers (iOS Safari, Chrome Mobile)

## Development

### Testing Changes

After modifying CSS or templates:

1. Rebuild the package:
   ```bash
   make package/luci-theme-argon-tirtayana/compile V=s
   ```

2. Update on router:
   ```bash
   scp bin/packages/*/base/luci-theme-argon-tirtayana*.ipk root@router:/tmp/
   ssh root@router "opkg remove luci-theme-argon-tirtayana && opkg install /tmp/luci-theme-argon-tirtayana*.ipk"
   ```

3. Clear browser cache and reload

### CSS Class Reference

Common classes used in the theme:
- `.cbi-map` - Main configuration container
- `.cbi-section` - Configuration section
- `.cbi-value` - Form field row
- `.cbi-button` - Action buttons
- `.alert` - Alert/notification boxes
- `.table` - Data tables

## Credits

- Based on [LuCI Argon Theme](https://github.com/jerrykuku/luci-theme-argon) by jerrykuku
- Color palette inspired by OpenWrt 2020 theme
- Customized for Tirtayana by Tirtayana Development Team

## License

MIT License

Copyright (c) 2024 Tirtayana

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Support

For issues, questions, or contributions, please contact the Tirtayana development team.

## Changelog

### Version 1.0.0 (Initial Release)
- Custom Argon-style theme for Tirtayana
- OpenWrt 2020 color palette integration
- Tirtayana logo and branding
- Responsive design for mobile devices
- Modern UI with smooth animations
- Full LuCI compatibility