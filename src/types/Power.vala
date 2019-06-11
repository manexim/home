public enum Power {
    UNKNOWN = -1,
    OFF = 0,
    ON = 65535;

    public string to_string() {
        switch (this) {
            case UNKNOWN:
                return "unknown";
            case OFF:
                return "off";
            case ON:
                return "on";
            default:
                print ("ERROR: Unsupported value %d\n", this);
                assert_not_reached();
        }
    }
}
