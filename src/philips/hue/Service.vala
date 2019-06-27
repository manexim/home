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
    private Gee.HashMap<string, Bridge> bridge_map;
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
            return bridge_map.values.to_array ();
        }
    }

    private Service () {
        bridge_map = new Gee.HashMap<string, Bridge> ();

        load_bridges ();
        setup_socket ();
        listen ();
        discover_bridges ();
    }

    private void load_bridges () {
        string[] philips_hue_bridges = Settings.get_default ().philips_hue_bridges;
        foreach (var bridge_str in philips_hue_bridges) {
            var parser = new Json.Parser();
            parser.load_from_data (bridge_str, -1);
            var object = parser.get_root ().get_object ();

            var bridge = new Philips.Hue.Bridge.from_object (object);
            bridge.power = Types.Power.UNKNOWN;

            found_bridge (bridge);
        }
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

                        GLib.Regex r_hue_bridgeid = /.*hue-bridgeid:\s*([^\s]*).*/;
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
        GLib.Regex r_location = /.*LOCATION:\s*((http:\/\/)(.*):(\d*)([^\s]*)).*/;
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
    }

    private void found_bridge (Philips.Hue.Bridge bridge) {
        var controller = new Philips.Hue.BridgeController (bridge);
        controller.get_description ();
        bridge = controller.bridge;

        if (!bridge_map.has_key (bridge.id)) {
            bridge_map.set (bridge.id, bridge);
            discover_bridge_devices (bridge);
            on_new_bridge (bridge);
        } else {
            bridge_map.set (bridge.id, bridge);
            on_updated_bridge (bridge);
        }
    }
}
