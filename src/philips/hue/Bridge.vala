namespace Philips.Hue {
    public class Bridge : Models.Thing {
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

        public string manufacturer {
            get {
                if (!_obj.has_member ("manufacturer")) {
                    manufacturer = null;
                }

                return _obj.get_string_member ("manufacturer");
            }
            set {
                _obj.set_string_member ("manufacturer", value);
            }
        }

        public string model {
            get {
                if (!_obj.has_member ("model")) {
                    model = null;
                }

                return _obj.get_string_member ("model");
            }
            set {
                _obj.set_string_member ("model", value);
            }
        }
    }
}
