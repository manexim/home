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

public class Colors.RGB {
    public uint8 red;
    public uint8 green;
    public uint8 blue;

    public RGB () {}

    public RGB.from_hex (string hex) {
        hex.scanf ("%02x%02x%02x", &red, &green, &blue);
    }

    public RGB.from_hsb (HSB hsb) {
        int i;
        double f, p, q, t;
        double r, g, b;

        double hue, saturation, brightness;
        hue = (double) hsb.hue;
        saturation = (double) (hsb.saturation / 100.0);
        brightness = (double) (hsb.brightness / 100.0);

        if (saturation == 0) {
            r = brightness;
            g = brightness;
            b = brightness;

            red = (uint8) (r * 255 + 0.5);
            green = (uint8) (g * 255 + 0.5);
            blue = (uint8) (b * 255 + 0.5);

            return;
        }

        hue /= 60;
        i = (int) hue;
        f = hue - i;
        p = brightness * (1 - saturation);
        q = brightness * (1 - saturation * f);
        t = brightness * (1 - saturation * (1 - f));

        switch (i) {
            case 0:
                r = brightness;
                g = t;
                b = p;
                break;
            case 1:
                r = q;
                g = brightness;
                b = p;
                break;
            case 2:
                r = p;
                g = brightness;
                b = t;
                break;
            case 3:
                r = p;
                g = q;
                b = brightness;
                break;
            case 4:
                r = t;
                g = p;
                b = brightness;
                break;
            default:
                r = brightness;
                g = p;
                b = q;
                break;
        }

        red = (uint8) (r * 255 + 0.5);
        green = (uint8) (g * 255 + 0.5);
        blue = (uint8) (b * 255 + 0.5);
    }

    public string to_hex () {
        return "#%02x%02x%02x".printf (red, green, blue);
    }
}
