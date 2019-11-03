/*
* Copyright (c) 2019 Manexim (https://github.com/manexim)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

public class Colors.HSB {
    public uint16 hue;
    public uint8 saturation;
    public uint8 brightness;

    public HSB () {}

    public HSB.from_rgb (RGB rgb) {
        double min, max, delta;
        double h, s, b;

        double red = rgb.red / 255.0;
        double green = rgb.green / 255.0;
        double blue = rgb.blue / 255.0;

        min = red;
        min = green < min ? green : min;
        min = blue < min ? blue : min;

        max = red;
        max = green > max ? green : max;
        max = blue > max ? blue : max;

        b = max;
        delta = max - min;

        if (max != 0) {
            s = delta / max;
        } else {
            s = 0;
            h = 0;

            hue = (uint16) (h + 0.5);
            saturation = (uint8) (s * 100 + 0.5);
            brightness = (uint8) (b * 100 + 0.5);

            return;
        }

        if (max == min) {
            h = 0;
            s = 0;

            hue = (uint16) (h + 0.5);
            saturation = (uint8) (s * 100 + 0.5);
            brightness = (uint8) (b * 100 + 0.5);

            return;
        }

        if (red == max) {
            h = (green - blue) / delta;
        } else if (green == max) {
            h = 2 + (blue - red) / delta;
        } else {
            h = 4 + (red - green) / delta;
        }

        h *= 60;

        if (h < 0) {
            h += 360;
        }

        hue = (uint16) (h + 0.5);
        saturation = (uint8) (s * 100 + 0.5);
        brightness = (uint8) (b * 100 + 0.5);
    }
}
