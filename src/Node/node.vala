using Gee;

namespace Swayfloatingswitcher {
    public class AppNode : Object {
        public int id { get; set; }
        public bool focused { get; set; default = false; }
        public bool visible { get; set; default = false; }
        public int pid { get; set; }

        public string ? name { get; set; }
        public string ? app_id { get; set; }
    }

    public class WorkspaceNode : Object, Json.Serializable {
        public int id { get; set; }
        public bool focused { get; set; default = false; }
        public bool visible { get; set; default = false; }
        public string ? name { get; set; }
        public bool floating_nodes { get; set; default = false; }
        public ArrayList<AppNode> nodes {
            get;
            private set;
            default = new ArrayList<AppNode>();
        }

        /**
         * Called when `Json.gobject_deserialize` is called
         */
        public bool deserialize_property (string property_name,
                                          out GLib.Value value,
                                          GLib.ParamSpec pspec,
                                          Json.Node property_node) {
            switch (property_name) {
                case "floating-nodes":
                    // To manually deserialize all of the floating nodes
                    bool result = false;
                    if (property_node.get_node_type () == Json.NodeType.ARRAY) {
                        result = true;
                        if (property_node.get_node_type () == Json.NodeType.ARRAY) {
                            var array = property_node.get_array ();
                            get_app_nodes (array);
                        }
                    }
                    value = result;
                    return result;
                default:
                    return default_deserialize_property (
                        property_name, out @value, pspec, property_node);
            }
        }

        void get_app_nodes (Json.Array ? array) {
            foreach (var item in array.get_elements ()) {
                var obj = item.get_object ();
                int64 pid = obj.get_int_member_with_default (
                    "pid", -1);

                if (pid <= 0) {
                    if (!obj.has_member ("nodes")) break;
                    get_app_nodes (obj.get_array_member ("nodes"));
                } else {
                    AppNode n = Json.gobject_deserialize (
                        typeof (AppNode), item) as AppNode;
                    if (n != null) nodes.insert (0, n);
                }
            }
        }
    }
}
