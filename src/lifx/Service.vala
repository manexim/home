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

namespace Lifx {
    public class Service {
        private static Service? _instance;
        public bool debug = false;
        private uint32 source = 0;
        private Gee.HashMap<string, Thing> thing_map;
        private Socket socket;

        public signal void on_new_thing (Thing thing);
        public signal void on_updated_thing (Thing thing);

        public static Service instance {
            get {
                if (_instance == null) {
                    _instance = new Service ();
                }

                return _instance;
            }
        }

        public void set_power (Lifx.LifxLamp lamp, uint16 level) {
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

        private Service () {
            thing_map = new Gee.HashMap<string, Thing> ();

            setup_socket ();
            listen ();
            discover ();
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
                                    if (!thing_map.has_key (packet.target)) {
                                        var thing = new Lifx.LifxLamp ();
                                        thing.id = packet.target;
                                        thing.port = (uint16) packet.payload.get_int_member ("port");
                                        thing.manufacturer = "LIFX";

                                        get_version (thing);
                                        get_state (thing);

                                        thing_map.set (thing.id, thing);
                                        on_new_thing (thing);
                                    }
                                    break;
                                case 22: // StatePower
                                    if (thing_map.has_key (packet.target)) {
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).power =
                                            (Power) packet.payload.get_int_member ("level");

                                        on_updated_thing (thing_map.get (packet.target));
                                    } else {
                                        var thing = new Lifx.LifxLamp ();
                                        thing.id = packet.target;
                                        thing.power = (Power) packet.payload.get_int_member ("level");

                                        thing_map.set (thing.id, thing);
                                        on_new_thing (thing);
                                    }
                                    break;
                                case 25: // StateLabel
                                    if (thing_map.has_key (packet.target)) {
                                        thing_map.get (packet.target).name = packet.payload.get_string_member ("label");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).manufacturer = "LIFX";

                                        on_updated_thing (thing_map.get (packet.target));
                                    } else {
                                        var thing = new Lifx.LifxLamp ();
                                        thing.id = packet.target;
                                        thing.name = packet.payload.get_string_member ("label");
                                        thing.manufacturer = "LIFX";

                                        thing_map.set (thing.id, thing);
                                        on_new_thing (thing);
                                    }
                                    break;
                                case 33: // StateVersion
                                    if (thing_map.has_key (packet.target)) {
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).manufacturer =
                                            packet.payload.get_string_member ("manufacturer");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).model =
                                            packet.payload.get_string_member ("model");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).supports_color =
                                            packet.payload.get_boolean_member ("supportsColor");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).supports_infrared =
                                            packet.payload.get_boolean_member ("supportsInfrared");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).supports_multizone =
                                            packet.payload.get_boolean_member ("supportsMultizone");

                                        on_updated_thing (thing_map.get (packet.target));
                                    } else {
                                        var thing = new Lifx.LifxLamp ();
                                        thing.id = packet.target;
                                        thing.manufacturer = packet.payload.get_string_member ("manufacturer");
                                        thing.model = packet.payload.get_string_member ("model");
                                        thing.supports_color = packet.payload.get_boolean_member ("supportsColor");
                                        thing.supports_infrared =
                                            packet.payload.get_boolean_member ("supportsInfrared");
                                        thing.supports_multizone =
                                            packet.payload.get_boolean_member ("supportsMultizone");

                                        thing_map.set (thing.id, thing);
                                        on_new_thing (thing);
                                    }
                                    break;
                                case 107: // State
                                    if (thing_map.has_key (packet.target)) {
                                        thing_map.get (packet.target).name = packet.payload.get_string_member ("label");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).manufacturer = "LIFX";
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).power =
                                            (Power) packet.payload.get_int_member ("power");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).hue =
                                            (uint16) packet.payload.get_int_member ("hue");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).saturation =
                                            (uint16) packet.payload.get_int_member ("saturation");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).brightness =
                                            (uint16) packet.payload.get_int_member ("brightness");
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).kelvin =
                                            (uint16) packet.payload.get_int_member ("kelvin");

                                        on_updated_thing (thing_map.get (packet.target));
                                    } else {
                                        var thing = new Lifx.LifxLamp ();
                                        thing.id = packet.target;
                                        thing.name = packet.payload.get_string_member ("label");
                                        thing.manufacturer = "LIFX";
                                        thing.power = (Power) packet.payload.get_int_member ("power");
                                        thing.hue = (uint16) packet.payload.get_int_member ("hue");
                                        thing.saturation = (uint16) packet.payload.get_int_member ("saturation");
                                        thing.brightness = (uint16) packet.payload.get_int_member ("brightness");
                                        thing.kelvin = (uint16) packet.payload.get_int_member ("kelvin");

                                        thing_map.set (thing.id, thing);
                                        on_new_thing (thing);
                                    }
                                    break;
                                case 118: // StatePower
                                    if (thing_map.has_key (packet.target)) {
                                        ((Lifx.LifxLamp) thing_map.get (packet.target)).power =
                                            (Power) packet.payload.get_int_member ("level");

                                        on_updated_thing (thing_map.get (packet.target));
                                    } else {
                                        var thing = new Lifx.LifxLamp ();
                                        thing.id = packet.target;
                                        thing.power = (Power) packet.payload.get_int_member ("level");

                                        thing_map.set (thing.id, thing);
                                        on_new_thing (thing);
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

        private void get_version (Lifx.LifxLamp lamp) {
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

        private void get_state (Lifx.LifxLamp lamp) {
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
}
