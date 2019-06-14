public class Lamp : Thing {
    public Power power {
        get {
            if (!this._obj.has_member ("power")) {
                this._obj.set_string_member ("power", "unknown");
            }

            switch (this._obj.get_string_member ("power")) {
            case "on":
                return Power.ON;
            case "off":
                return Power.OFF;
            default:
                return Power.UNKNOWN;
            }
        }
        set {
            this._obj.set_string_member ("power", value.to_string ());
        }
    }

    public string manufacturer {
        get {
            if (!this._obj.has_member ("manufacturer")) {
                this.manufacturer = null;
            }

            return this._obj.get_string_member ("manufacturer");
        }
        set {
            this._obj.set_string_member ("manufacturer", value);
        }
    }

    public string model {
        get {
            if (!this._obj.has_member ("model")) {
                this.model = null;
            }

            return this._obj.get_string_member ("model");
        }
        set {
            this._obj.set_string_member ("model", value);
        }
    }
}
