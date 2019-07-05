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

public class Lifx.Service {
    private static Service? _instance;
    public bool debug = false;
    private uint32 source = 0;
    private Gee.HashMap<string, Models.Device> device_map;
    private Socket socket;

    public signal void on_new_device (Models.Device device);
    public signal void on_updated_device (Models.Device device);

    public static Service instance {
        get {
            if (_instance == null) {
                _instance = new Service ();
            }

            return _instance;
        }
    }

    public void set_power (Lifx.Lamp lamp, uint16 level) {
        var packet = new Lifx.Packet ();
        packet.type = 21;
        packet.tagged = false;
        packet.addressable = true;
        packet.target = lamp.id;
        packet.ack_required = false;
        packet.res_required = false;
        packet.source = source++;
        packet.payload.set_int_member ("level", level);

        try {
            socket.send_to (
                new InetSocketAddress (
                    new InetAddress.from_string ("255.255.255.255"), lamp.port),
                packet.raw
            );
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    public void set_color (Lifx.Lamp lamp, uint16 hue, uint16 saturation, uint16 brightness, uint16 kelvin, uint32 duration=0) {
        var packet = new Lifx.Packet ();
        packet.type = 102;
        packet.tagged = false;
        packet.addressable = true;
        packet.target = lamp.id;
        packet.ack_required = false;
        packet.res_required = false;
        packet.source = source++;
        packet.payload.set_int_member ("hue", hue);
        packet.payload.set_int_member ("saturation", saturation);
        packet.payload.set_int_member ("brightness", brightness);
        packet.payload.set_int_member ("kelvin", kelvin);
        packet.payload.set_int_member ("duration", duration);

        try {
            socket.send_to (
                new InetSocketAddress (
                    new InetAddress.from_string ("255.255.255.255"), lamp.port),
                packet.raw
            );
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    private Service () {
        device_map = new Gee.HashMap<string, Models.Device> ();

        #if DEMO_MODE
        new Thread<void*> (null, () => {
            Thread.usleep (500 * 1000);

            {
                var lamp = new Lifx.Lamp ();
                lamp.name = "Backyard";
                lamp.id = "??:??:??:??:??:??:??:??";
                lamp.power = Types.Power.OFF;
                lamp.manufacturer = "LIFX";
                lamp.model = "White 800 (High Voltage)";
                on_new_device (lamp);
            }

            Thread.usleep (500 * 1000);

            {
                var lamp = new Lifx.Lamp ();
                lamp.name = "Bedroom";
                lamp.id = "??:??:??:??:??:??:??:??";
                lamp.power = Types.Power.OFF;
                lamp.model = "Color 1000";
                on_new_device (lamp as Models.Device);
            }

            Thread.usleep (500 * 1000);

            {
                var lamp = new Lifx.Lamp ();
                lamp.name = "Coffee Table";
                lamp.id = "??:??:??:??:??:??:??:??";
                lamp.power = Types.Power.ON;
                lamp.model = "Color 1000";
                on_new_device (lamp as Models.Device);
            }

            Thread.usleep (500 * 1000);

            {
                var lamp = new Lifx.Lamp ();
                lamp.name = "Desk";
                lamp.id = "??:??:??:??:??:??:??:??";
                lamp.power = Types.Power.ON;
                lamp.model = "Color 1000";
                on_new_device (lamp as Models.Device);
            }

            Thread.usleep (500 * 1000);

            {
                var lamp = new Lifx.Lamp ();
                lamp.name = "Hallway";
                lamp.id = "??:??:??:??:??:??:??:??";
                lamp.power = Types.Power.ON;
                lamp.model = "Color 1000";
                on_new_device (lamp as Models.Device);
            }

            Thread.usleep (500 * 1000);

            {
                var lamp = new Lifx.Lamp ();
                lamp.name = "Living Room";
                lamp.id = "??:??:??:??:??:??:??:??";
                lamp.power = Types.Power.OFF;
                lamp.model = "Color 1000";
                on_new_device (lamp as Models.Device);
            }

            return null;
        });
        #else
        setup_socket ();
        listen ();
        discover ();
        #endif
    }

    private void setup_socket () {
        try {
            socket = new Socket (SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
            socket.broadcast = true;

            #if HAVE_SO_REUSEPORT
            int32 enable = 1;
            Posix.setsockopt(
                socket.fd, Platform.Socket.SOL_SOCKET, Platform.Socket.SO_REUSEPORT, &enable,
                (Posix.socklen_t) sizeof(int)
            );
            #endif

            var sa = new InetSocketAddress (new InetAddress.any (SocketFamily.IPV4), 56700);
            socket.bind (sa, true);
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    private void listen () {
        new Thread<void*> (null, () => {
            while (true) {
                var source = socket.create_source (IOCondition.IN);
                source.set_callback ((s, cond) => {
                    try {
                        uint8 buffer[256];
                        s.receive (buffer);

                        uint16 size = buffer[0];
                        size += buffer[1] << 1;
                        uint8[] raw = buffer[0:size];

                        Lifx.Packet packet = new Lifx.Packet.from (raw);
                        switch (packet.type) {
                            case 3: // StateService
                                if (!device_map.has_key (packet.target)) {
                                    var device = new Lifx.Lamp ();
                                    device.id = packet.target;
                                    device.port = (uint16) packet.payload.get_int_member ("port");
                                    device.manufacturer = "LIFX";

                                    get_version (device);
                                    get_state (device);

                                    device_map.set (device.id, device);
                                    on_new_device (device);
                                }
                                break;
                            case 22: // StatePower
                                if (device_map.has_key (packet.target)) {
                                    ((Lifx.Lamp) device_map.get (packet.target)).power =
                                        (Types.Power) packet.payload.get_int_member ("level");

                                    on_updated_device (device_map.get (packet.target));
                                } else {
                                    var device = new Lifx.Lamp ();
                                    device.id = packet.target;
                                    device.power = (Types.Power) packet.payload.get_int_member ("level");

                                    device_map.set (device.id, device);
                                    on_new_device (device);
                                }
                                break;
                            case 25: // StateLabel
                                if (device_map.has_key (packet.target)) {
                                    device_map.get (packet.target).name = packet.payload.get_string_member ("label");
                                    ((Lifx.Lamp) device_map.get (packet.target)).manufacturer = "LIFX";

                                    on_updated_device (device_map.get (packet.target));
                                } else {
                                    var device = new Lifx.Lamp ();
                                    device.id = packet.target;
                                    device.name = packet.payload.get_string_member ("label");
                                    device.manufacturer = "LIFX";

                                    device_map.set (device.id, device);
                                    on_new_device (device);
                                }
                                break;
                            case 33: // StateVersion
                                if (device_map.has_key (packet.target)) {
                                    ((Lifx.Lamp) device_map.get (packet.target)).manufacturer =
                                        packet.payload.get_string_member ("manufacturer");
                                    ((Lifx.Lamp) device_map.get (packet.target)).model =
                                        packet.payload.get_string_member ("model");
                                    ((Lifx.Lamp) device_map.get (packet.target)).supports_color =
                                        packet.payload.get_boolean_member ("supportsColor");
                                    ((Lifx.Lamp) device_map.get (packet.target)).supports_infrared =
                                        packet.payload.get_boolean_member ("supportsInfrared");
                                    ((Lifx.Lamp) device_map.get (packet.target)).supports_multizone =
                                        packet.payload.get_boolean_member ("supportsMultizone");

                                    on_updated_device (device_map.get (packet.target));
                                } else {
                                    var device = new Lifx.Lamp ();
                                    device.id = packet.target;
                                    device.manufacturer = packet.payload.get_string_member ("manufacturer");
                                    device.model = packet.payload.get_string_member ("model");
                                    device.supports_color = packet.payload.get_boolean_member ("supportsColor");
                                    device.supports_infrared =
                                        packet.payload.get_boolean_member ("supportsInfrared");
                                    device.supports_multizone =
                                        packet.payload.get_boolean_member ("supportsMultizone");

                                    device_map.set (device.id, device);
                                    on_new_device (device);
                                }
                                break;
                            case 107: // State
                                if (device_map.has_key (packet.target)) {
                                    device_map.get (packet.target).name = packet.payload.get_string_member ("label");
                                    ((Lifx.Lamp) device_map.get (packet.target)).manufacturer = "LIFX";
                                    ((Lifx.Lamp) device_map.get (packet.target)).power =
                                        (Types.Power) packet.payload.get_int_member ("power");
                                    ((Lifx.Lamp) device_map.get (packet.target)).hue =
                                        (uint16) packet.payload.get_int_member ("hue");
                                    ((Lifx.Lamp) device_map.get (packet.target)).saturation =
                                        (uint16) packet.payload.get_int_member ("saturation");
                                    ((Lifx.Lamp) device_map.get (packet.target)).brightness =
                                        (uint16) packet.payload.get_int_member ("brightness");
                                    ((Lifx.Lamp) device_map.get (packet.target)).color_temperature =
                                        (uint16) packet.payload.get_int_member ("kelvin");

                                    on_updated_device (device_map.get (packet.target));
                                } else {
                                    var device = new Lifx.Lamp ();
                                    device.id = packet.target;
                                    device.name = packet.payload.get_string_member ("label");
                                    device.manufacturer = "LIFX";
                                    device.power = (Types.Power) packet.payload.get_int_member ("power");
                                    device.hue = (uint16) packet.payload.get_int_member ("hue");
                                    device.saturation = (uint16) packet.payload.get_int_member ("saturation");
                                    device.brightness = (uint16) packet.payload.get_int_member ("brightness");
                                    device.color_temperature = (uint16) packet.payload.get_int_member ("kelvin");

                                    device_map.set (device.id, device);
                                    on_new_device (device);
                                }
                                break;
                            case 118: // StatePower
                                if (device_map.has_key (packet.target)) {
                                    ((Lifx.Lamp) device_map.get (packet.target)).power =
                                        (Types.Power) packet.payload.get_int_member ("level");

                                    on_updated_device (device_map.get (packet.target));
                                } else {
                                    var device = new Lifx.Lamp ();
                                    device.id = packet.target;
                                    device.power = (Types.Power) packet.payload.get_int_member ("level");

                                    device_map.set (device.id, device);
                                    on_new_device (device);
                                }
                                break;
                            default:
                                break;
                        }

                        if (debug) {
                            print ("%s\n", packet.to_string ());
                        }
                    } catch (Error e) {
                        stderr.printf (e.message);
                    }
                    return true;
                });
                source.attach (MainContext.default ());

                new MainLoop ().run ();
            }
        });
    }

    private void discover () {
        new Thread<void*> (null, () => {
            while (true) {
                get_service ();

                Thread.usleep (30 * 1000 * 1000);
            }
        });
    }

    private void get_service () {
        var packet = new Lifx.Packet ();
        packet.type = 2;
        packet.tagged = true;

        try {
            socket.send_to (
                new InetSocketAddress (
                    new InetAddress.from_string ("255.255.255.255"), 56700),
                packet.raw
            );
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    private void get_version (Lifx.Lamp lamp) {
        var packet = new Lifx.Packet ();
        packet.type = 32;
        packet.tagged = true;
        packet.addressable = true;
        packet.source = source++;

        try {
            socket.send_to (
                new InetSocketAddress (
                    new InetAddress.from_string ("255.255.255.255"), lamp.port),
                packet.raw
            );
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    private void get_state (Lifx.Lamp lamp) {
        var packet = new Lifx.Packet ();
        packet.type = 101;
        packet.tagged = true;
        packet.addressable = true;
        packet.source = source++;

        try {
            socket.send_to (
                new InetSocketAddress (
                    new InetAddress.from_string ("255.255.255.255"), lamp.port),
                packet.raw
            );
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }
}
