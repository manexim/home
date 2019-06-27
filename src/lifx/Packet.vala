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

public class Lifx.Packet {
    /* frame */
    public uint16 size;
    public uint16 protocol;
    public bool addressable;
    public bool tagged;
    public uint32 source;
    /* frame address */
    public string target;
    public bool res_required;
    public bool ack_required;
    public uint8 sequence;
    /* protocol header */
    public uint16 type;
    /* payload */
    public Json.Object payload;

    public Packet () {
        target = "00:00:00:00:00:00:00:00";
        payload = new Json.Object ();
    }

    public Packet.from (uint8[] array) {
        var buffer = new Buffer.from (array);

        if (buffer.length < 36) {
            // TODO error
        }

        // frame
        size = buffer.read_uint16_le (0);
        if (size != buffer.length) {
            // TODO error
        }

        tagged = ((buffer.read_uint8 (3) & 32) == 1) ? true : false;
        addressable = ((buffer.read_uint8 (3) & 16) == 1) ? true : false;
        protocol = buffer.read_uint16_le (2) & 0xfff;
        source = buffer.read_uint32_le (4);

        // frame address
        string[] target_parts = new string[8];
        for (uint8 i = 8; i < 16; i++) {
            target_parts[i - 8] = buffer.slice (i, i + 1).to_string ("%02x").up ();
        }
        target = string.joinv (":", target_parts);
        res_required = ((buffer.read_uint8 (22) & 1) == 1) ? true : false;
        ack_required = ((buffer.read_uint8 (22) & 2) == 1) ? true : false;
        sequence = buffer.read_uint8 (23);

        // header
        type = buffer.read_uint16_le (32);

        // payload
        payload = new Json.Object ();
        const uint8 i = 36;

        switch (type) {
            case 3: // StateService
                payload.set_int_member ("service", buffer.read_uint8 (i));
                payload.set_int_member ("port", buffer.read_uint32_le (i + 1));
                break;
            case 13: // StateHostInfo
                payload.set_double_member ("signal", buffer.read_float_le (i));
                payload.set_int_member ("tx", buffer.read_uint32_le (i + 4));
                payload.set_int_member ("rx", buffer.read_uint32_le (i + 8));
                break;
            case 15: // StateHostFirmware
                payload.set_double_member ("signal", buffer.read_float_le (i));
                payload.set_int_member ("tx", buffer.read_uint32_le (i + 4));
                payload.set_int_member ("rx", buffer.read_uint32_le (i + 8));
                break;
            case 22: // StatePower
                Types.Power power = Types.Power.UNKNOWN;
                uint16 power_t = buffer.read_uint16_le (i);
                if (power_t > 0) {
                    power = Types.Power.ON;
                } else if (power_t == 0) {
                    power = Types.Power.OFF;
                }
                payload.set_int_member ("level", power);
                break;
            case 25: // StateLabel
                payload.set_string_member ("label", (string) buffer.slice (i, i + 32).raw);
                break;
            case 33: // StateVersion
                uint32 product = buffer.read_uint32_le (i + 4);
                string model = "";
                bool supports_color = false;
                bool supports_infrared = false;
                bool supports_multizone = false;

                // https://lan.developer.lifx.com/v2.0/docs/lifx-products
                switch (product) {
                    case 1:
                        model = "Original 1000";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 3:
                        model = "Color 650";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 10:
                        model = "White 800 (Low Voltage)";
                        supports_color = false;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 11:
                        model = "White 800 (High Voltage)";
                        supports_color = false;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 18:
                        model = "White 900 BR30 (Low Voltage)";
                        supports_color = false;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 20:
                        model = "Color 1000 BR30";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 22:
                        model = "Color 1000";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 27:
                    case 43:
                        model = "LIFX A19";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 28:
                    case 44:
                        model = "LIFX BR30";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 29:
                    case 45:
                        model = "LIFX+ A19";
                        supports_color = true;
                        supports_infrared = true;
                        supports_multizone = false;
                        break;
                    case 30:
                    case 46:
                        model = "LIFX+ BR30";
                        supports_color = true;
                        supports_infrared = true;
                        supports_multizone = false;
                        break;
                    case 31:
                        model = "LIFX Z";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = true;
                        break;
                    case 32:
                        model = "LIFX Z 2";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = true;
                        break;
                    case 36:
                    case 37:
                        model = "LIFX Downlight";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 38:
                        model = "LIFX Beam";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = true;
                        break;
                    case 49:
                    case 59:
                        model = "LIFX Mini";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 50:
                    case 60:
                        model = "LIFX Mini Day and Dusk";
                        supports_color = false;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 51:
                    case 61:
                        model = "LIFX Mini White";
                        supports_color = false;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 52:
                        model = "LIFX GU10";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    case 55:
                        model = "LIFX Tile";
                        supports_color = true;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                    default:
                        model = "unknown";
                        supports_color = false;
                        supports_infrared = false;
                        supports_multizone = false;
                        break;
                }
                payload.set_string_member ("manufacturer", "LIFX");
                payload.set_string_member ("model", model);
                payload.set_boolean_member ("supportsColor", supports_color);
                payload.set_boolean_member ("supportsInfrared", supports_infrared);
                payload.set_boolean_member ("supportsMultizone", supports_multizone);
                break;
            case 107: // State
                payload.set_int_member ("hue", buffer.read_uint16_le (i));
                payload.set_int_member ("saturation", buffer.read_uint16_le (i + 2));
                payload.set_int_member ("brightness", buffer.read_uint16_le (i + 4));
                payload.set_int_member ("kelvin", buffer.read_uint16_le (i + 6));

                // power
                Types.Power power = Types.Power.UNKNOWN;
                uint16 power_t = buffer.read_uint16_le (i + 10);
                if (power_t > 0) {
                    power = Types.Power.ON;
                } else if (power_t == 0) {
                    power = Types.Power.OFF;
                }
                payload.set_int_member ("power", power);

                payload.set_string_member ("label", (string) buffer.slice (i + 12, i + 44).raw);
                break;
            case 118: // StatePower
                Types.Power power = Types.Power.UNKNOWN;
                uint16 power_t = buffer.read_uint16_le (i);
                if (power_t > 0) {
                    power = Types.Power.ON;
                } else if (power_t == 0) {
                    power = Types.Power.OFF;
                }
                payload.set_int_member ("level", power);
                break;
            default:
                var a = new Json.Array ();
                var raw = buffer.slice (i, (uint8) size).raw;

                for (uint8 j = 0; j < raw.length; j++) {
                    a.add_int_element (raw[j]);
                }

                payload.set_array_member ("raw", a);
                break;
        }
    }

    public uint8[] raw {
        owned get {
            uint8 ack_required = ack_required ? 1 : 0;
            uint8 res_required = res_required ? 1 : 0;
            uint8 tagged = tagged ? 1 : 0;
            uint8[] target_parts = new uint8[8];
            target.scanf (
                "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
                &target_parts[0],
                &target_parts[1],
                &target_parts[2],
                &target_parts[3],
                &target_parts[4],
                &target_parts[5],
                &target_parts[6],
                &target_parts[7]
            );

            // frame
            uint8 origin = 0;
            uint8 addressable = 1;
            uint16 protocol = 1024;

            Buffer buf1 = new Buffer.alloc (8);
            uint16 buf1n2 = protocol | (origin << 14) | (tagged << 13) | (addressable << 12);
            buf1.write_uint16_le (buf1n2, 2);
            buf1.write_uint32_le (source, 4);

            // frame address
            Buffer buf2 = new Buffer.alloc (16);
            for (uint8 i = 0; i < 8; i++) {
                buf2.write_uint8(target_parts[i], i);
            }

            // header
            Buffer buf3 = new Buffer.alloc(12);
            buf3.write_uint16_le (type, 8);

            uint8 byte14 = (ack_required << 1) | res_required;
            buf2.write_uint8 (byte14, 14);
            buf2.write_uint8 (sequence, 15);

            // payload
            Buffer buf4 = new Buffer ();

            switch (type) {
                case 2: // GetService
                    break;
                case 21: // SetPower
                    buf4 = new Buffer.alloc (2);
                    buf4.write_uint16_le ((uint16) payload.get_int_member ("level"), 0);
                    break;
                case 117: // SetPower
                    buf4 = new Buffer.alloc (6);
                    buf4.write_uint16_le ((uint16) payload.get_int_member ("level"), 0);
                    buf4.write_uint32_le ((uint32) payload.get_int_member ("duration"), 2);
                    break;
                default:
                    break;
            }

            Buffer buffer = buf1.concat (buf2);
            buffer = buffer.concat (buf3);
            buffer = buffer.concat (buf4);

            uint16 size = (uint16) buffer.length;
            buffer.write_uint16_le (size, 0);

            return buffer.raw;
        }
    }

    public string to_string () {
        size_t length;

        var gen = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        var object = new Json.Object ();
        root.set_object (object);
        gen.set_root (root);

        // frame
        object.set_int_member ("size", size);
        object.set_boolean_member ("addressable", addressable);
        object.set_boolean_member ("tagged", tagged);
        object.set_int_member ("source", source);

        // frame address
        object.set_string_member ("target", target);
        object.set_boolean_member ("res_required", res_required);
        object.set_boolean_member ("ack_required", ack_required);
        object.set_int_member ("sequence", sequence);

        // protocol
        object.set_int_member ("type", type);

        // payload
        object.set_object_member ("payload", payload);

        return gen.to_data (out length);
    }
}
