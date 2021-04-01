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

public class Philips.Hue.Controller : Controllers.DeviceController {
    private Philips.Hue.BridgeController controller;

    public Controller (Models.Device device) {
        Object (
            device : device
        );

        controller = new Philips.Hue.BridgeController (((Philips.Hue.Lamp) device).bridge);
    }

    public override void switch_hue (uint16 hue) {
        var lamp = device as Philips.Hue.Lamp;
        Actions.set_hue (device.id, hue);
        controller.switch_light_hue (lamp, hue);

        lamp.hue = hue;
    }

    public override void switch_saturation (uint16 saturation) {
        var lamp = device as Philips.Hue.Lamp;
        Actions.set_saturation (device.id, saturation);
        controller.switch_light_saturation (lamp, saturation);

        lamp.saturation = saturation;
    }

    public override void switch_brightness (uint16 brightness) {
        var lamp = device as Philips.Hue.Lamp;
        Actions.set_brightness (device.id, brightness);
        controller.switch_light_brightness (lamp, brightness);

        lamp.brightness = brightness;
    }

    public override void switch_hsb (uint16 hue, uint16 saturation, uint16 brightness) {
        var lamp = device as Philips.Hue.Lamp;
        Actions.set_hsb (device.id, hue, saturation, brightness);
        controller.switch_light_hsb (lamp, hue, saturation, brightness);

        lamp.hue = hue;
        lamp.saturation = saturation;
        lamp.brightness = brightness;
    }

    public override void switch_color_temperature (uint16 color_temperature) {
        var lamp = device as Philips.Hue.Lamp;
        Actions.set_color_temperature (device.id, color_temperature);
        controller.switch_light_color_temperature (lamp, color_temperature);

        lamp.color_temperature = color_temperature;
    }

    public override void switch_power (bool on) {
        Actions.set_power (device.id, on);
        controller.switch_light_power (device as Philips.Hue.Lamp, on);

        _device.power = on ? Types.Power.ON : Types.Power.OFF;
    }
}
