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

public class Philips.Hue.BridgeController {
    private Bridge _bridge;
    private Gee.HashMap<string, Models.Device> thing_map;

    #if DEMO_MODE
    private uint register_counter = 0;
    #endif

    public signal void on_new_lamp (Models.Lamp lamp);
    public signal void on_updated_lamp (Models.Lamp lamp);

    public BridgeController (Bridge bridge) {
        _bridge = bridge;
        thing_map = new Gee.HashMap<string, Models.Device> ();
    }

    public void get_description () {
        string url = "%sdescription.xml".printf (_bridge.base_url);

        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);

        session.send_message (message);

        // replace <root xmlns="urn:schemas-upnp-org:device-1-0"> with <root>
        // because  otherwise the node can not be found
        GLib.Regex r = /.*(<root.*>).*/;
        Xml.Doc* doc;
        try {
            var patched = r.replace ((string) message.response_body.data, (ssize_t) message.response_body.length, 0, "<root>");

            Xml.Parser.init ();

            doc = Xml.Parser.parse_memory (patched, patched.length);
            if (doc == null) {
                stderr.printf ("failed to read the .xml file\n");
            }

            Xml.XPath.Context context = new Xml.XPath.Context(doc);
            if (context == null) {
                stderr.printf ("failed to create the xpath context\n");
            }

            Xml.XPath.Object* obj = context.eval_expression("/root/device/friendlyName");
            if (obj == null) {
                stderr.printf ("failed to evaluate xpath\n");
            }

            Xml.Node* node = null;
            if (obj->nodesetval != null && obj->nodesetval->item(0) != null) {
                node = obj->nodesetval->item(0);
            } else {
                stderr.printf ("failed to find the expected node\n");
            }

            _bridge.name = node->get_content ();

            delete obj;

            obj = context.eval_expression("/root/device/manufacturer");
            if (obj == null) {
                stderr.printf ("failed to evaluate xpath\n");
            }

            node = null;
            if (obj->nodesetval != null && obj->nodesetval->item(0) != null) {
                node = obj->nodesetval->item(0);
            } else {
                stderr.printf ("failed to find the expected node\n");
            }

            _bridge.manufacturer = node->get_content ();

            delete obj;

            obj = context.eval_expression("/root/device/modelName");
            if (obj == null) {
                stderr.printf ("failed to evaluate xpath\n");
            }

            node = null;
            if (obj->nodesetval != null && obj->nodesetval->item(0) != null) {
                node = obj->nodesetval->item(0);
            } else {
                stderr.printf ("failed to find the expected node\n");
            }

            _bridge.model = node->get_content ();

            delete obj;
        } catch (GLib.RegexError e) {
            stderr.printf (e.message);
        } finally {
            delete doc;
        }

        Xml.Parser.cleanup ();
    }

    public bool register () throws GLib.Error {
        #if DEMO_MODE
        if (register_counter++ == 2) {
            _bridge.power = Types.Power.ON;

            return true;
        }
        #else
        string url = "%sapi".printf (_bridge.base_url);

        var session = new Soup.Session ();
        var message = new Soup.Message ("POST", url);

        var gen = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        var object = new Json.Object ();

        object.set_string_member ("devicetype", "com.github.manexim.home");

        root.set_object (object);
        gen.set_root (root);

        size_t length;
        string json = gen.to_data (out length);

        message.request_body.append_take (json.data);

        session.send_message (message);

        string response = (string) message.response_body.flatten ().data;

        var parser = new Json.Parser();
        parser.load_from_data (response, -1);

        foreach (var element in parser.get_root ().get_array ().get_elements ()) {
            var obj = element.get_object ();

            if (obj.has_member ("error")) {
                throw new GLib.Error (
                    GLib.Quark.from_string (""),
                    (int) obj.get_object_member ("error").get_int_member ("type"),
                    obj.get_object_member ("error").get_string_member ("description")
                );
            } else if (obj.has_member ("success")) {
                _bridge.username = "%s".printf (obj.get_object_member ("success").get_string_member ("username"));
                _bridge.power = Types.Power.ON;

                return true;
            }
        }
        #endif

        return false;
    }

    public void state () {
        string url = "%sapi/%s".printf (_bridge.base_url, _bridge.username);

        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);

        session.send_message (message);

        string response = (string) message.response_body.flatten ().data;

        try {
            var parser = new Json.Parser();
            parser.load_from_data (response, -1);
            var object = parser.get_root ().get_object ();
            var lights = object.get_object_member ("lights");

            foreach (var key in lights.get_members ()) {
                var light = lights.get_object_member (key);
                var lamp = new Philips.Hue.Lamp ();
                lamp.number = key;
                lamp.name = light.get_string_member ("name");
                lamp.manufacturer = light.get_string_member ("manufacturername");
                lamp.model = light.get_string_member ("modelid");
                lamp.id = light.get_string_member ("uniqueid");
                lamp.bridge = bridge;
                var on = light.get_object_member ("state").get_boolean_member ("on");

                if (light.get_object_member ("state").has_member ("bri")) {
                    lamp.supports_brightness = true;
                    lamp.brightness = (uint8) light.get_object_member ("state").get_int_member ("bri");
                }

                if (light.get_object_member ("state").has_member ("ct")) {
                    lamp.supports_color_temperature = true;
                    lamp.color_temperature = (uint16) light.get_object_member ("state").get_int_member ("ct");
                }

                if (light.get_object_member ("capabilities").get_object_member ("control").has_member ("ct")) {
                    lamp.color_temperature_min = (uint16) light.get_object_member ("capabilities").
                        get_object_member ("control").get_object_member ("ct").get_int_member ("min");
                    lamp.color_temperature_max = (uint16) light.get_object_member ("capabilities").
                        get_object_member ("control").get_object_member ("ct").get_int_member ("max");
                }

                if (on) {
                    lamp.power = Types.Power.ON;
                } else {
                    lamp.power = Types.Power.OFF;
                }

                if (!thing_map.has_key (lamp.id)) {
                    thing_map.set (lamp.id, lamp);
                    on_new_lamp (lamp);
                } else {
                    thing_map.set (lamp.id, lamp);
                    on_updated_lamp (lamp);
                }
            }
        } catch (GLib.Error e) {
            stderr.printf (e.message);
        }
    }

    public void switch_light_power (Philips.Hue.Lamp lamp, bool on) {
        string url = "%sapi/%s/lights/%s/state".printf (_bridge.base_url, _bridge.username, lamp.number);

        var session = new Soup.Session ();
        var message = new Soup.Message ("PUT", url);

        size_t length;

        var obj = new Json.Object ();
        obj.set_boolean_member ("on", on);

        var gen = new Json.Generator ();
        var root = new Json.Node (Json.NodeType.OBJECT);
        root.set_object (obj);
        gen.set_root (root);

        var params = gen.to_data (out length);

        Soup.MemoryUse buffer = Soup.MemoryUse.STATIC;
        message.set_request ("application/json", buffer, params.data);

        session.send_message (message);
    }

    public Bridge bridge {
        get {
            return _bridge;
        }
    }
}
