/*
* Copyright (c) 2019 Manexim (https://github.com/manexim)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
*/

void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/Buffer/alloc", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.length == 4);
        for (uint8 i = 0; i < buffer.length; i++) {
            assert (buffer[i] == 0);
        }
    });

    Test.add_func ("/Buffer/read_uint8", () => {
        uint8[] array = {1, 254};
        var buffer = new Buffer.from (array);

        assert (buffer.length == 2);
        assert (buffer.read_uint8 (0) == 1);
        assert (buffer.read_uint8 (1) == 254);
    });

    Test.add_func ("/Buffer/read_uint16", () => {
        uint8[] array = {0x12, 0x34, 0x56};
        var buffer = new Buffer.from (array);

        assert (buffer.read_uint16_be (0).to_string ("%x") == "1234");
        assert (buffer.read_uint16_le (0).to_string ("%x") == "3412");
        assert (buffer.read_uint16_be (1).to_string ("%x") == "3456");
        assert (buffer.read_uint16_le (1).to_string ("%x") == "5634");
    });

    Test.add_func ("/Buffer/write_uint16", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.write_uint16_be (0xdead, 0) == 2);
        assert (buffer.write_uint16_be (0xbeef, 2) == 4);
        assert (buffer.to_string () == "deadbeef");

        assert (buffer.write_uint16_le (0xdead, 0) == 2);
        assert (buffer.write_uint16_le (0xbeef, 2) == 4);
        assert (buffer.to_string () == "addeefbe");
    });

    Test.add_func ("/Buffer/read_uint32", () => {
        uint8[] array = {0x12, 0x34, 0x56, 0x78};
        var buffer = new Buffer.from (array);

        assert (buffer.read_uint32_be (0).to_string ("%x") == "12345678");
        assert (buffer.read_uint32_le (0).to_string ("%x") == "78563412");
    });

    Test.add_func ("/Buffer/write_uint32", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.write_uint32_be ((uint32) 0xdeadbeef, 0) == 4);
        assert (buffer.to_string () == "deadbeef");

        assert (buffer.write_uint32_le ((uint32) 0xdeadbeef, 0) == 4);
        assert (buffer.to_string () == "efbeadde");
    });

    Test.add_func ("/Buffer/write_float", () => {
        var buffer = new Buffer.alloc (4);

        assert (buffer.write_float_be (3.14f, 0) == 4);
        assert (buffer.read_float_be (0) == 3.14f);

        assert (buffer.write_float_le (3.14f, 0) == 4);
        assert (buffer.read_float_le (0) == 3.14f);
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
