namespace Lifx {
    public class LifxLamp : Lamp {
        public uint16 port {
            get {
                if (!this._obj.has_member ("port")) {
                    this.port = 56700;
                }

                return (uint16) this._obj.get_int_member ("port");
            }
            set {
                this._obj.set_int_member ("port", value);
            }
        }

        public uint16 hue {
            get {
                return (uint16) this._obj.get_int_member ("hue");
            }
            set {
                this._obj.set_int_member ("hue", value);
            }
        }

        public uint16 saturation {
            get {
                return (uint16) this._obj.get_int_member ("saturation");
            }
            set {
                this._obj.set_int_member ("saturation", value);
            }
        }

        public uint16 brightness {
            get {
                return (uint16) this._obj.get_int_member ("brightness");
            }
            set {
                this._obj.set_int_member ("brightness", value);
            }
        }

        public uint16 kelvin {
            get {
                return (uint16) this._obj.get_int_member ("kelvin");
            }
            set {
                this._obj.set_int_member ("kelvin", value);
            }
        }

        public bool supports_infrared {
            get {
                if (!this._obj.has_member ("supportsInfrared")) {
                    this.supports_infrared = false;
                }

                return this._obj.get_boolean_member ("supportsInfrared");
            }
            set {
                this._obj.set_boolean_member ("supportsInfrared", value);
            }
        }
    }
}
