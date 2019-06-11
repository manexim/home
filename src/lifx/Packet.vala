namespace Lifx {
    public class Packet {
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
            this.target = "00:00:00:00:00:00:00:00";
            this.payload = new Json.Object ();
        }

        public Packet.from (uint8[] array) {
            var buffer = new Buffer.from (array);

            if (buffer.length < 36) {
                // TODO error
            }

            // frame
            this.size = buffer.readUInt16LE (0);
            if (this.size != buffer.length) {
                // TODO error
            }

            this.tagged = ((buffer.readUInt8 (3) & 32) == 1) ? true : false;
            this.addressable = ((buffer.readUInt8 (3) & 16) == 1) ? true : false;
            this.protocol = buffer.readUInt16LE (2) & 0xfff;
            this.source = buffer.readUInt32LE (4);

            // frame address
            string[] targetParts = new string[8];
            for (uint8 i = 8; i < 16; i++) {
                targetParts[i - 8] = buffer.slice (i, i + 1).to_string ("%02x").up ();
            }
            this.target = string.joinv (":", targetParts);
            this.res_required = ((buffer.readUInt8 (22) & 1) == 1) ? true : false;
            this.ack_required = ((buffer.readUInt8 (22) & 2) == 1) ? true : false;
            this.sequence = buffer.readUInt8 (23);

            // header
            this.type = buffer.readUInt16LE (32);

            // payload
            this.payload = new Json.Object ();
            const uint8 i = 36;

            switch (this.type) {
            case 3: // StateService
                this.payload.set_int_member ("service", buffer.readUInt8 (i));
                this.payload.set_int_member ("port", buffer.readUInt32LE (i + 1));
                break;
            case 13: // StateHostInfo
                this.payload.set_double_member ("signal", buffer.readFloatLE (i));
                this.payload.set_int_member ("tx", buffer.readUInt32LE (i + 4));
                this.payload.set_int_member ("rx", buffer.readUInt32LE (i + 8));
                break;
            case 15: // StateHostFirmware
                this.payload.set_double_member ("signal", buffer.readFloatLE (i));
                this.payload.set_int_member ("tx", buffer.readUInt32LE (i + 4));
                this.payload.set_int_member ("rx", buffer.readUInt32LE (i + 8));
                break;
            case 22: // StatePower
            Power power = Power.UNKNOWN;
                uint16 power_t = buffer.readUInt16LE (i);
                if (power_t > 0) {
                    power = Power.ON;
                } else if (power_t == 0) {
                    power = Power.OFF;
                }
                this.payload.set_int_member ("level", power);
                break;
            case 25: // StateLabel
            this.payload.set_string_member ("label", (string) buffer.slice (i, i + 32).raw);
                break;
            case 107: // State
                this.payload.set_int_member ("hue", buffer.readUInt16LE (i));
                this.payload.set_int_member ("saturation", buffer.readUInt16LE (i + 2));
                this.payload.set_int_member ("brightness", buffer.readUInt16LE (i + 4));
                this.payload.set_int_member ("kelvin", buffer.readUInt16LE (i + 6));

                // power
                Power power = Power.UNKNOWN;
                uint16 power_t = buffer.readUInt16LE (i + 10);
                if (power_t > 0) {
                    power = Power.ON;
                } else if (power_t == 0) {
                    power = Power.OFF;
                }
                this.payload.set_int_member ("power", power);

                this.payload.set_string_member ("label", (string) buffer.slice (i + 12, i + 44).raw);
                break;
            case 118: // StatePower
                Power power = Power.UNKNOWN;
                uint16 power_t = buffer.readUInt16LE (i);
                if (power_t > 0) {
                    power = Power.ON;
                } else if (power_t == 0) {
                    power = Power.OFF;
                }
                this.payload.set_int_member ("level", power);
                break;
            default:
                var a = new Json.Array ();
                var raw = buffer.slice (i, (uint8) this.size).raw;

                for (uint8 j = 0; j < raw.length; j++) {
                    a.add_int_element (raw[j]);
                }

                this.payload.set_array_member ("raw", a);
                break;
            }
        }

        public uint8[] raw {
            owned get {
                uint8 ack_required = this.ack_required ? 1 : 0;
                uint8 res_required = this.res_required ? 1 : 0;
                uint8 tagged = this.tagged ? 1 : 0;
                uint8[] targetParts = new uint8[8];
                this.target.scanf (
                    "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
                    &targetParts[0],
                    &targetParts[1],
                    &targetParts[2],
                    &targetParts[3],
                    &targetParts[4],
                    &targetParts[5],
                    &targetParts[6],
                    &targetParts[7]
                );

                // frame
                uint8 origin = 0;
                uint8 addressable = 1;
                uint16 protocol = 1024;

                Buffer buf1 = new Buffer.alloc (8);
                uint16 buf1n2 = protocol | (origin << 14) | (tagged << 13) | (addressable << 12);
                buf1.writeUInt16LE (buf1n2, 2);
                buf1.writeUInt32LE (source, 4);

                // frame address
                Buffer buf2 = new Buffer.alloc (16);
                for (uint8 i = 0; i < 8; i++) {
                    buf2.writeUInt8(targetParts[i], i);
                }

                // header
                Buffer buf3 = new Buffer.alloc(12);
	            buf3.writeUInt16LE (type, 8);

                uint8 byte14 = (ack_required << 1) | res_required;
                buf2.writeUInt8 (byte14, 14);
                buf2.writeUInt8 (sequence, 15);

                // payload
                Buffer buf4 = new Buffer ();

                switch (this.type) {
                case 2: // GetService
                    break;
                case 21: // SetPower
                    buf4 = new Buffer.alloc (2);
                    buf4.writeUInt16LE ((uint16) this.payload.get_int_member ("level"), 0);
                    break;
                case 117: // SetPower
                    buf4 = new Buffer.alloc (6);
                    buf4.writeUInt16LE ((uint16) this.payload.get_int_member ("level"), 0);
                    buf4.writeUInt32LE ((uint32) this.payload.get_int_member ("duration"), 2);
                    break;
                default:
                    break;
                }

                Buffer buffer = buf1.concat (buf2);
                buffer = buffer.concat (buf3);
                buffer = buffer.concat (buf4);

                uint16 size = (uint16) buffer.length;
                buffer.writeUInt16LE (size, 0);

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
            object.set_int_member ("size", this.size);
            object.set_boolean_member ("addressable", this.addressable);
            object.set_boolean_member ("tagged", this.tagged);
            object.set_int_member ("source", this.source);

            // frame address
            object.set_string_member ("target", this.target);
            object.set_boolean_member ("res_required", this.res_required);
            object.set_boolean_member ("ack_required", this.ack_required);
            object.set_int_member ("sequence", this.sequence);

            // protocol
            object.set_int_member ("type", this.type);

            // payload
            object.set_object_member ("payload", this.payload);

            return gen.to_data (out length);
        }
    }
}
