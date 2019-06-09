namespace Lifx {
    public class LifxLamp : Lamp {
        public uint16 port;
        public uint16 hue;
        public uint16 saturation;
        public uint16 brightness;
        public uint16 kelvin;

        public new string toString () {
            size_t length;

            var gen = new Json.Generator ();
            var root = new Json.Node (Json.NodeType.OBJECT);
            var object = new Json.Object ();
            root.set_object (object);
            gen.set_root (root);

            object.set_string_member ("id", this.id);
            object.set_string_member ("name", this.name);
            object.set_boolean_member ("on", this.on);
            object.set_int_member ("port", this.port);
            object.set_int_member ("hue", this.hue);
            object.set_int_member ("saturation", this.saturation);
            object.set_int_member ("brightness", this.brightness);
            object.set_int_member ("kelvin", this.kelvin);

            return gen.to_data (out length);
        }
    }
}
