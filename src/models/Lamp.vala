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
}
