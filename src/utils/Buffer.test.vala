void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/Buffer/alloc", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.length == 4);
        for (uint8 i = 0; i < buffer.length; i++) {
            assert (buffer[i] == 0);
        }
    });

    Test.add_func ("/Buffer/readUInt8", () => {
        uint8[] array = {1, 254};
        var buffer = new Buffer.from (array);

        assert (buffer.length == 2);
        assert (buffer.readUInt8 (0) == 1);
        assert (buffer.readUInt8 (1) == 254);
    });

    Test.add_func ("/Buffer/readUInt16", () => {
        uint8[] array = {0x12, 0x34, 0x56};
        var buffer = new Buffer.from (array);

        assert (buffer.readUInt16BE (0).to_string ("%x") == "1234");
        assert (buffer.readUInt16LE (0).to_string ("%x") == "3412");
        assert (buffer.readUInt16BE (1).to_string ("%x") == "3456");
        assert (buffer.readUInt16LE (1).to_string ("%x") == "5634");
    });

    Test.add_func ("/Buffer/writeUInt16", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.writeUInt16BE (0xdead, 0) == 2);
        assert (buffer.writeUInt16BE (0xbeef, 2) == 4);
        assert (buffer.to_string () == "deadbeef");

        assert (buffer.writeUInt16LE (0xdead, 0) == 2);
        assert (buffer.writeUInt16LE (0xbeef, 2) == 4);
        assert (buffer.to_string () == "addeefbe");
    });

    Test.add_func ("/Buffer/readUInt32", () => {
        uint8[] array = {0x12, 0x34, 0x56, 0x78};
        var buffer = new Buffer.from (array);

        assert (buffer.readUInt32BE (0).to_string ("%x") == "12345678");
        assert (buffer.readUInt32LE (0).to_string ("%x") == "78563412");
    });

    Test.add_func ("/Buffer/writeUInt32", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.writeUInt32BE ((uint32) 0xdeadbeef, 0) == 4);
        assert (buffer.to_string () == "deadbeef");

        assert (buffer.writeUInt32LE ((uint32) 0xdeadbeef, 0) == 4);
        assert (buffer.to_string () == "efbeadde");
    });

    Test.add_func ("/Buffer/writeFloat", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.writeFloatBE (3.14f, 0) == 4);
        assert (buffer.readFloatBE (0) == 3.14f);

        assert (buffer.writeFloatLE (3.14f, 0) == 4);
        assert (buffer.readFloatLE (0) == 3.14f);
    });

    Test.add_func ("/Buffer/concat", () => {
        uint8[] a1 = {0xde, 0xad};
        uint8[] a2 = {0xbe, 0xef};
        var buf1 = new Buffer.from (a1);
        var buf2 = new Buffer.from (a2);
        var buf = buf1.concat (buf2);

        assert (buf1.to_string () == "dead");
        assert (buf2.to_string () == "beef");
        assert (buf.to_string () == "deadbeef");
    });

    Test.add_func ("/Buffer/slice", () => {
        uint8[] array = {0xde, 0xad, 0xbe, 0xef};
        var buffer = new Buffer.from (array);

        assert (buffer.slice (2, 4).to_string () == "beef");
    });

    Test.add_func ("/Buffer/raw", () => {
        uint8[] a = {0xde, 0xad, 0xbe, 0xef};
        var buffer = new Buffer.from (a);
        var b = buffer.raw;

        assert (b.length == a.length);
        for (uint i = 0; i < b.length; i++) {
            assert (b[i] == a[i]);
        }
    });

    Test.add_func ("/Buffer/to_string", () => {
        uint8[] array = {0xde, 0xad, 0xbe, 0xef};
        var buffer = new Buffer.from (array);

        assert (buffer.to_string () == "deadbeef");
    });

    Test.run ();
}
