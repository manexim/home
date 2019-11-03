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

public class Buffer {
    private uint8[] values;

    public Buffer.alloc (uint8 size) {
        this.values = new uint8[size];
        for (uint8 i = 0; i < size; i++) {
            this.values[i] = 0;
        }
    }

    public Buffer.from (uint8[] array) {
        this.values = array;
    }

    public uint length {
        get { return this.values.length; }
    }

    public uint8 get (uint8 offset) {
        return this.values[offset];
    }

    public uint8 read_uint8 (uint8 offset) {
        return this.values[offset];
    }

    public uint8 write_uint8 (uint8 value, uint8 offset) {
        this.values[offset] = value;

        return offset + 1;
    }

    private uint16 read_uint16_backwards (uint8 offset) {
        return this.values[offset + 1]
            | (this.values[offset] << 8);
    }

    private uint16 read_uint16_forwards (uint8 offset) {
        return this.values[offset]
            | (this.values[offset + 1] << 8);
    }

    public uint16 read_uint16_be (uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.read_uint16_forwards (offset);
        }

        return this.read_uint16_backwards (offset);
    }

    public uint16 read_uint16_le (uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.read_uint16_backwards (offset);
        }

        return this.read_uint16_forwards (offset);
    }

    private uint8 writer_uint16_backwards (uint16 value, uint8 offset) {
        this.values[offset + 1] = (uint8) (value & 0xff);
        this.values[offset] = (uint8) ((value >> 8) & 0xff);

        return offset + 2;
    }

    private uint8 write_uint16_forwards (uint16 value, uint8 offset) {
        this.values[offset] = (uint8) (value & 0xff);
        this.values[offset + 1] = (uint8) ((value >> 8) & 0xff);

        return offset + 2;
    }

    public uint8 write_uint16_be (uint16 value, uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.write_uint16_forwards (value, offset);
        }

        return this.writer_uint16_backwards (value, offset);
    }

    public uint8 write_uint16_le (uint16 value, uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.writer_uint16_backwards (value, offset);
        }

        return this.write_uint16_forwards (value, offset);
    }

    private uint32 read_uint32_backwards (uint8 offset) {
        return this.values[offset + 3]
            | (this.values[offset + 2] << 8)
            | (this.values[offset + 1] << 16)
            | (this.values[offset] << 24);
    }

    private uint32 read_uint32_forwards (uint8 offset) {
        return this.values[offset]
            | (this.values[offset + 1] << 8)
            | (this.values[offset + 2] << 16)
            | (this.values[offset + 3] << 24);
    }

    public uint32 read_uint32_be (uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.read_uint32_forwards (offset);
        }

        return this.read_uint32_backwards (offset);
    }

    public uint32 read_uint32_le (uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.read_uint32_backwards (offset);
        }

        return this.read_uint32_forwards (offset);
    }

    private uint8 write_uint32_backwards (uint32 value, uint8 offset) {
        this.values[offset + 3] = (uint8) (value & 0xff);
        this.values[offset + 2] = (uint8) ((value >> 8) & 0xff);
        this.values[offset + 1] = (uint8) ((value >> 16) & 0xff);
        this.values[offset] = (uint8) ((value >> 24) & 0xff);

        return offset + 4;
    }

    private uint8 write_uint32_forwards (uint32 value, uint8 offset) {
        this.values[offset] = (uint8) (value & 0xff);
        this.values[offset + 1] = (uint8) ((value >> 8) & 0xff);
        this.values[offset + 2] = (uint8) ((value >> 16) & 0xff);
        this.values[offset + 3] = (uint8) ((value >> 24) & 0xff);

        return offset + 4;
    }

    public uint8 write_uint32_be (uint32 value, uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.write_uint32_forwards (value, offset);
        }

        return this.write_uint32_backwards (value, offset);
    }

    public uint8 write_uint32_le (uint32 value, uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.write_uint32_backwards (value, offset);
        }

        return this.write_uint32_forwards (value, offset);
    }

    private float read_float_backwards (uint8 offset) {
        float f = (float) 0.0;
        Posix.memcpy (&f, &this.values[offset], 4);

        return f;
    }

    private float read_float_forwards (uint8 offset) {
        float f = (float) 0.0;
        Posix.memcpy (&f, &this.values[offset], 4);

        return f;
    }

    public float read_float_be (uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.read_float_forwards (offset);
        }

        return this.read_float_backwards (offset);
    }

    public float read_float_le (uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.read_float_backwards (offset);
        }

        return this.read_float_forwards (offset);
    }

    private uint8 write_float_backwards (float value, uint8 offset) {
        Posix.memcpy (&this.values[offset], &value, 4);

        return 4;
    }

    private uint8 write_float_forwards (float value, uint8 offset) {
        Posix.memcpy (&this.values[offset], &value, 4);

        return 4;
    }

    public uint8 write_float_be (float value, uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.write_float_forwards (value, offset);
        }

        return this.write_float_backwards (value, offset);
    }

    public uint8 write_float_le (float value, uint8 offset) {
        if (Platform.is_big_endian ()) {
            return this.write_float_backwards (value, offset);
        }

        return this.write_float_forwards (value, offset);
    }

    public Buffer concat (Buffer list) {
        uint length = this.length + list.length;
        uint8[] raw = new uint8[length];

        for (uint8 i = 0; i < this.length; i++) {
            raw[i] = this.values[i];
        }

        for (uint8 i = 0; i < list.length; i++) {
            raw[this.length + i] = list[i];
        }

        return new Buffer.from (raw);
    }

    public Buffer slice (uint8 start, uint8 end) {
        uint8[] vs = this.values[start:end];

        return new Buffer.from (vs);
    }

    public uint8[] raw {
        get {
            return this.values;
        }
    }

    public string to_string (string format = "%x") {
        StringBuilder sb = new StringBuilder ();
        foreach (var v in this.values) {
            sb.append (v.to_string (format));
        }

        return sb.str;
    }
}
