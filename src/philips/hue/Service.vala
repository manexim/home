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

public class Philips.Hue.Service {
    private static Service? _instance;
    private Array<Bridge> bridge_loaded_array;
    private Array<Bridge> bridge_array;
    private Socket socket;

    public signal void on_new_bridge (Bridge bridge);
    public signal void on_updated_bridge (Bridge bridge);
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

    public Bridge[] bridges {
        owned get {
            return bridge_array.data;
        }
    }

    private Service () {
        bridge_loaded_array = new Array<Bridge> ();
        bridge_array = new Array<Bridge> ();

        #if DEMO_MODE
        new Thread<void*> (null, () => {
            Thread.usleep (2 * 1000 * 1000);

            var bridge = new Philips.Hue.Bridge ();
            bridge.name = "Philips Hue";
            bridge.id = "????????????????";
            found_bridge (bridge);

            return null;
        });
        #else
        load_bridges ();
        setup_socket ();
        listen ();
        discover_bridges ();
        #endif
    }

    private void load_bridges () {
        try {
            var configuration = Settings.get_default ().configuration_as_json ();
            Json.Object o;
            if (configuration.has_member ("com")) {
                o = configuration.get_object_member ("com");
            } else {
                return;
            }

            if (o.has_member ("philips")) {
                o = o.get_object_member ("philips");
            } else {
                return;
            }

            if (o.has_member ("hue")) {
                o = o.get_object_member ("hue");
            } else {
                return;
            }

            if (o.has_member ("bridges")) {
                o = o.get_object_member ("bridges");
            } else {
                return;
            }

            foreach (var key in o.get_members ()) {
                var obj = o.get_object_member (key);
                if (obj == null) {
                    continue;
                }

                var bridge = new Philips.Hue.Bridge.from_object (obj);
                bridge.id = key;
                bridge.power = Types.Power.UNKNOWN;

                bridge_loaded_array.append_val (bridge);
            }
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    private void setup_socket () {
        try {
            socket = new Socket (SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
            socket.broadcast = true;

            #if HAVE_SO_REUSEPORT
            int32 enable = 1;
            Posix.setsockopt (
                socket.fd, Platform.Socket.SOL_SOCKET, Platform.Socket.SO_REUSEPORT, &enable,
                (Posix.socklen_t) sizeof (int)
            );
            #endif

            var sa = new InetSocketAddress (new InetAddress.any (SocketFamily.IPV4), 1900);
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
                        uint8 buffer[4096];
                        size_t read = s.receive (buffer);
                        buffer[read] = 0; // null-terminate string

                        var r_hue_bridgeid = new GLib.Regex (".*hue-bridgeid:\\s*([^\\s]*).*");
                        string hue_bridgeid;
                        GLib.MatchInfo mi;
                        if (r_hue_bridgeid.match ((string) buffer, 0, out mi)) {
                            hue_bridgeid = mi.fetch (1);
                            found_bridge_ssdp (hue_bridgeid, (string) buffer);
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

    private void discover_bridges () {
        new Thread<void*> (null, () => {
            while (true) {
                discover_bridges_ssdp ();

                Thread.usleep (10 * 1000 * 1000);
            }
        });
    }

    private void discover_bridge_devices (Philips.Hue.Bridge bridge) {
        #if DEMO_MODE
        new Thread<void*> (null, () => {
            while (bridge.power != Types.Power.ON) {
                Thread.usleep (1 * 1000 * 1000);
            }

            {
                var lamp = new Philips.Hue.Lamp ();
                lamp.name = "Kitchen";
                lamp.id = "??:??:??:??:??:??:??:??-??";
                lamp.power = Types.Power.ON;
                lamp.manufacturer = "Philips Hue";
                lamp.model = "White";
                on_new_device (lamp);
            }

            {
                var lamp = new Philips.Hue.Lamp ();
                lamp.name = "Garage";
                lamp.id = "??:??:??:??:??:??:??:??-??";
                lamp.power = Types.Power.OFF;
                lamp.manufacturer = "Philips Hue";
                lamp.model = "White";
                on_new_device (lamp);
            }

            return null;
        });
        #else
        var controller = new Philips.Hue.BridgeController (bridge);
        controller.on_new_lamp.connect ((lamp) => {
            on_new_device (lamp);
        });

        controller.on_updated_lamp.connect ((lamp) => {
            on_updated_device (lamp);
        });

        new Thread<void*> (null, () => {
            while (true) {
                if (bridge.username != null && bridge.username != "") {
                    controller.state ();
                }

                Thread.usleep (10 * 1000 * 1000);
            }
        });
        #endif
    }

    private void discover_bridges_ssdp () {
        string message = "M-SEARCH * HTTP/1.1\r\n";
        message += "HOST: 239.255.255.250:1900\r\n";
        message += "MAN: ssdp:discover\r\n";
        message += "MX: 10\r\n";
        message += "ST: ssdp:all\r\n";

        try {
            socket.send_to (
                new InetSocketAddress (
                    new InetAddress.from_string ("255.255.255.255"), 1900),
                message.data
            );
        } catch (Error e) {
            stderr.printf (e.message);
        }
    }

    private void found_bridge_ssdp (string bridgeid, string message) {
        try {
            var r_location = new Regex (".*LOCATION:\\s*((http:\\/\\/)(.*):(\\d*)([^\\s]*)).*");
            string url, protocol, host, port, path;
            GLib.MatchInfo mi;
            if (r_location.match (message, 0, out mi)) {
                url = mi.fetch (1);
                protocol = mi.fetch (2);
                host = mi.fetch (3);
                port = mi.fetch (4);
                path = mi.fetch (5);

                var bridge = new Bridge ();
                bridge.id = bridgeid.up ();
                bridge.base_url = protocol + host + ":" + port + "/";

                found_bridge (bridge);

            }
        } catch (RegexError e) {
            stderr.printf (e.message);
        }
    }

    private void found_bridge (Philips.Hue.Bridge bridge) {
        var controller = new Philips.Hue.BridgeController (bridge);
        #if DEMO_MODE
        #else
        controller.get_description ();
        #endif

        if (!is_in_array (bridge_array, bridge.id)) {
            if (is_in_array (bridge_loaded_array, bridge.id)) {
                bridge.username = get_value_from_id (bridge_loaded_array, bridge.id).username;
                bridge.power = Types.Power.ON;
            }

            bridge_array.append_val (bridge);
            discover_bridge_devices (bridge);
            on_new_bridge (bridge);
        } else {
            on_updated_bridge (bridge);
        }
    }

    private bool is_in_array (Array<Models.Thing> array, string id) {
        for (uint i = 0; i < array.length; i++) {
            if (array.index (i).id == id) {
                return true;
            }
        }

        return false;
    }

    private Bridge? get_value_from_id (Array<Models.Thing> array, string id) {
        for (uint i = 0; i < array.length; i++) {
            if (array.index (i).id == id) {
                return array.index (i) as Philips.Hue.Bridge;
            }
        }

        return null;
    }
}
