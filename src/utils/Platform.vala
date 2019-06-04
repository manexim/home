namespace Platform {
    bool isBigEndian () {
        uint8 x = 1;
        uint8 *c = (uint8 *) &x;

        return (((int) *c) == 0) ? true : false;
    }
}
