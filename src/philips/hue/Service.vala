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

namespace Philips.Hue {
    public class Service {
        private static Service? _instance;
        private Gee.HashMap<string, Bridge> bridge_map;
        private Socket socket;

        public signal void on_new_bridge (Bridge bridge);

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

        private void discover () {
            new Thread<void*> (null, () => {
                while (true) {
                    discover_ssdp ();

                    Thread.usleep (10 * 1000 * 1000);
                }
            });
        }

        private void discover_ssdp () {
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

                if (!bridge_map.has_key (bridgeid)) {
                    var bridge = new Bridge ();
                    bridge.id = bridgeid.up ();
                    bridge.base_url = protocol + host + ":" + port + "/";

                    var controller = new Philips.Hue.BridgeController (bridge);
                    controller.get_description ();
                    bridge = controller.bridge;

                    bridge_map.set (bridge.id, bridge);
                    on_new_bridge (bridge);
                }
            }
        }
    }
}
