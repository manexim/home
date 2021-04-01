/*
 * Copyright (c) 2021 Manexim (https://github.com/manexim)
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

public class Actions {
    public static void set_color (string id, uint16 hue, uint16 saturation, uint16 brightness, uint16 kelvin, uint32 duration=0) {
        var type = ActionType.SET_COLOR;
        var payload = new SetColorPayload () {
            id = id,
            hue = hue,
            saturation = saturation,
            brightness = brightness,
            kelvin = kelvin,
            duration = duration
        };
        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    public static void set_hue (string id, uint16 hue) {
        var type = ActionType.SET_HUE;
        var payload = new SetHuePayload () {
            id = id,
            hue = hue
        };
        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    public static void set_saturation (string id, uint16 saturation) {
        var type = ActionType.SET_SATURATION;
        var payload = new SetSaturationPayload () {
            id = id,
            saturation = saturation
        };
        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    public static void set_brightness (string id, uint16 brightness) {
        var type = ActionType.SET_BRIGHTNESS;
        var payload = new SetBrightnessPayload () {
            id = id,
            brightness = brightness
        };
        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    public static void set_hsb (string id, uint16 hue, uint16 saturation, uint16 brightness) {
        var type = ActionType.SET_HSB;
        var payload = new SetHsbPayload () {
            id = id,
            hue = hue,
            saturation = saturation,
            brightness = brightness
        };
        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    public static void set_color_temperature (string id, uint16 color_temperature) {
        var type = ActionType.SET_COLOR_TEMPERATURE;
        var payload = new SetColorTemperaturePayload () {
            id = id,
            color_temperature = color_temperature
        };
        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }

    public static void set_power (string id, bool on) {
        var type = ActionType.SET_POWER;
        var payload = new SetPowerPayload () {
            id = id,
            on = on
        };
        var action = new Flux.Action (type, payload);
        Flux.Dispatcher.get_instance ().dispatch (action);
    }
}
