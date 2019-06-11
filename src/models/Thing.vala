public class Thing {
    protected Json.Object _obj;

    public Thing () {
        this._obj = new Json.Object ();
    }

    public string id {
        get {
            if (!this._obj.has_member ("id")) {
                this.id = null;
            }

            return this._obj.get_string_member ("id");
        }
        set {
            this._obj.set_string_member ("id", value);
        }
    }

    public string name {
        get {
            if (!this._obj.has_member ("name")) {
                this.name = null;
            }

            return this._obj.get_string_member ("name");
        }
        set {
            this._obj.set_string_member ("name", value);
        }
    }

    public string toString () {
        size_t length;

        var gen = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        root.set_object (this._obj);
        gen.set_root (root);

        return gen.to_data (out length);
    }
}
