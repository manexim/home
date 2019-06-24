namespace Philips.Hue {
    public class Bridge : Models.Thing {
        public Bridge () {
            icon = "com.github.manexim.home.bridge.philips.hue-symbolic";
            manufacturer = "Philips";
            power = Power.WARNING;
        }

        public Bridge.from_object (Json.Object object) {
            _obj = object;
        }

        public string base_url {
            get {
                if (!_obj.has_member ("baseURL")) {
                    base_url = null;
                }

                return _obj.get_string_member ("baseURL");
            }
            set {
                _obj.set_string_member ("baseURL", value);
            }
        }

        public string username {
            get {
                if (!_obj.has_member ("username")) {
                    username = null;
                }

                return _obj.get_string_member ("username");
            }
            set {
                _obj.set_string_member ("username", value);
            }
        }
    }
}
