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

public class DevicePayload : Flux.Payload {
    public string id { get; set; }
    public string name { get; set; }
    public string manufacturer { get; set; }
    public string model { get; set; }
    public Types.Power power { get; set; }
    public string icon { get; set; }
    public string default_icon { get; set; }
}

public class SetColorPayload : Flux.Payload {
    public string id { get; set; }
    public bool on { get; set; }
    public uint16 hue { get; set; }
    public uint16 saturation { get; set; }
    public uint16 brightness { get; set; }
    public uint16 kelvin { get; set; }
    public uint32 duration { get; set; }
}

public class SetHuePayload : Flux.Payload {
    public string id { get; set; }
    public uint16 hue { get; set; }
}

public class SetSaturationPayload : Flux.Payload {
    public string id { get; set; }
    public uint16 saturation { get; set; }
}

public class SetBrightnessPayload : Flux.Payload {
    public string id { get; set; }
    public uint16 brightness { get; set; }
}

public class SetHsbPayload : Flux.Payload {
    public string id { get; set; }
    public uint16 hue { get; set; }
    public uint16 saturation { get; set; }
    public uint16 brightness { get; set; }
}

public class SetColorTemperaturePayload : Flux.Payload {
    public string id { get; set; }
    public uint16 color_temperature { get; set; }
}

public class SetPowerPayload : Flux.Payload {
    public string id { get; set; }
    public bool on { get; set; }
}
