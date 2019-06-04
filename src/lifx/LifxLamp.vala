namespace Lifx {
    public class LifxLamp : Lamp {
        public uint16 port;

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

            return gen.to_data (out length);
        }
    }
}
