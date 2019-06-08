namespace Lifx {
    public class Service {
        private bool debug;
        private uint32 source = 0;
        private Gee.HashMap<string, Thing> thingMap;
        private Socket socket;

        public signal void onNewThing (Thing thing);
        public signal void onUpdatedThing (Thing thing);

        public Service (bool debug = false) {
            this.debug = debug;
            this.thingMap = new Gee.HashMap<string, Thing> ();

            this.setupSocket ();
            this.discover ();
        }

        private void setupSocket () {
            try {
                this.socket = new Socket (SocketFamily.IPV4, SocketType.DATAGRAM, SocketProtocol.UDP);
                this.socket.multicast_ttl = 225;
                this.socket.multicast_loopback = true;

                #if HAVE_SO_REUSEPORT
                int32 enable = 1;
                Posix.setsockopt(this.socket.fd, Platform.Socket.SOL_SOCKET, Platform.Socket.SO_REUSEPORT, &enable, (Posix.socklen_t) sizeof(int));
                #endif

                var sa = new InetSocketAddress (new InetAddress.any (SocketFamily.IPV4), 56700);
                this.socket.bind (sa, true);
                this.socket.join_multicast_group (new InetAddress.from_string ("224.0.0.251"), false, "lo");
            } catch (Error e) {
                stderr.printf (e.message);
            }
        }

        private void discover () {
            new Thread<void*> (null, () => {
                while (true) {
                    var source = this.socket.create_source (IOCondition.IN);
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
                                if (!this.thingMap.has_key (packet.target)) {
                                    var thing = new Lifx.LifxLamp ();
                                    thing.id = packet.target;
                                    thing.port = (uint16) packet.payload.get_int_member ("port");

                                    this.getState (thing);

                                    this.thingMap.set (thing.id, thing);
                                    this.onNewThing (thing);
                                }
                                break;
                            case 22: // StatePower
                                if (this.thingMap.has_key (packet.target)) {
                                    (this.thingMap.get (packet.target) as Lifx.LifxLamp).on = (packet.payload.get_int_member ("level") == 65535);

                                    this.onUpdatedThing (this.thingMap.get (packet.target));
                                } else {
                                    var thing = new Lifx.LifxLamp ();
                                    thing.id = packet.target;
                                    thing.on = (packet.payload.get_int_member ("level") == 65535);

                                    this.getLabel (thing);

                                    this.thingMap.set (thing.id, thing);
                                    this.onNewThing (thing);
                                }
                                break;
                            case 25: // StateLabel
                                if (this.thingMap.has_key (packet.target)) {
                                    this.thingMap.get (packet.target).name = packet.payload.get_string_member ("label");

                                    this.onUpdatedThing (this.thingMap.get (packet.target));
                                } else {
                                    var thing = new Lifx.LifxLamp ();
                                    thing.id = packet.target;
                                    thing.name = packet.payload.get_string_member ("label");

                                    this.thingMap.set (thing.id, thing);
                                    this.onNewThing (thing);
                                }
                                break;
                            case 107: // State
                                if (this.thingMap.has_key (packet.target)) {
                                    this.thingMap.get (packet.target).name = packet.payload.get_string_member ("label");
                                    (this.thingMap.get (packet.target) as Lifx.LifxLamp).on = (packet.payload.get_int_member ("power") == 65535);

                                    this.onUpdatedThing (this.thingMap.get (packet.target));
                                } else {
                                    var thing = new Lifx.LifxLamp ();
                                    thing.id = packet.target;
                                    thing.name = packet.payload.get_string_member ("label");
                                    thing.on = (packet.payload.get_int_member ("power") == 65535);

                                    this.thingMap.set (thing.id, thing);
                                    this.onNewThing (thing);
                                }
                                break;
                            default:
                                break;
                            }

                            if (this.debug) {
                                print ("%s\n", packet.to_string ());
                            }
                        } catch (Error e) {
                            stderr.printf (e.message);
                        }
                        return true;
                    });
                    source.attach (MainContext.default ());

                    this.getService ();

                    new MainLoop ().run ();
                }
            });
        }

        private void getService () {
            var packet = new Lifx.Packet ();
            packet.type = 2;
            packet.tagged = true;

            try {
                this.socket.send_to (new InetSocketAddress (new InetAddress.from_string ("224.0.0.251"), 56700), packet.raw);
            } catch (Error e) {
                stderr.printf (e.message);
            }
        }

        private void getPower (Lifx.LifxLamp lamp) {
            var packet = new Lifx.Packet ();
            packet.type = 20;
            packet.tagged = true;
            packet.addressable = true;
            //  packet.target = lamp.id;
            //  packet.ack_required = true;
            //  packet.res_required = true;
            packet.source = this.source++;

            try {
                this.socket.send_to (new InetSocketAddress (new InetAddress.from_string ("224.0.0.251"), 56700), packet.raw);
            } catch (Error e) {
                stderr.printf (e.message);
            }
        }

        private void getLabel (Lifx.LifxLamp lamp) {
            var packet = new Lifx.Packet ();
            packet.type = 23;
            packet.tagged = true;
            packet.addressable = true;
            //  packet.target = lamp.id;
            //  packet.ack_required = true;
            //  packet.res_required = true;
            packet.source = this.source++;

            try {
                this.socket.send_to (new InetSocketAddress (new InetAddress.from_string ("224.0.0.251"), 56700), packet.raw);
            } catch (Error e) {
                stderr.printf (e.message);
            }
        }

        private void getState (Lifx.LifxLamp lamp) {
            var packet = new Lifx.Packet ();
            packet.type = 101;
            packet.tagged = true;
            packet.addressable = true;
            //  packet.target = lamp.id;
            //  packet.ack_required = true;
            //  packet.res_required = true;
            packet.source = this.source++;

            try {
                this.socket.send_to (new InetSocketAddress (new InetAddress.from_string ("224.0.0.251"), 56700), packet.raw);
            } catch (Error e) {
                stderr.printf (e.message);
            }
        }
    }
}
