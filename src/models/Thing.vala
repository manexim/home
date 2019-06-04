public class Thing {
    public string id;
    public string name;

    public string toString () {
        size_t length;

        var gen = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        var object = new Json.Object ();
        root.set_object (object);
        gen.set_root (root);

        object.set_string_member ("id", this.id);
        object.set_string_member ("name", this.name);

        return gen.to_data (out length);
    }
}
