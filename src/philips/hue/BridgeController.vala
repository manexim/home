namespace Philips.Hue {
    public class BridgeController {
        private Bridge _bridge;

        public BridgeController (Bridge bridge) {
            _bridge = bridge;
        }

        public void get_description () {
            string url = "%sdescription.xml".printf (_bridge.base_url);

            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);

            // send the HTTP request and wait for response
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
                    print ("failed to read the .xml file\n");
                }

                Xml.XPath.Context context = new Xml.XPath.Context(doc);
                if (context == null) {
                    print ("failed to create the xpath context\n");
                }

                Xml.XPath.Object* obj = context.eval_expression("/root/device/manufacturer");
                if (obj == null) {
                    print ("failed to evaluate xpath\n");
                }

                Xml.Node* node = null;
                if (obj->nodesetval != null && obj->nodesetval->item(0) != null) {
                    node = obj->nodesetval->item(0);
                } else {
                    print ("failed to find the expected node\n");
                }

                _bridge.manufacturer = node->get_content ();

                delete obj;

                obj = context.eval_expression("/root/device/modelName");
                if (obj == null) {
                    print ("failed to evaluate xpath\n");
                }

                node = null;
                if (obj->nodesetval != null && obj->nodesetval->item(0) != null) {
                    node = obj->nodesetval->item(0);
                } else {
                    print ("failed to find the expected node\n");
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

        public Bridge bridge {
            get {
                return _bridge;
            }
        }
    }
}
