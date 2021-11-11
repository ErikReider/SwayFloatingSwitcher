using Gee;

namespace Swayfloatingswitcher {
    [GtkTemplate (ui = "/org/erikreider/sway-floating-switcher/Window/window.ui")]
    public class Window : Gtk.ApplicationWindow {

        [GtkChild]
        unowned Gtk.FlowBox flow_box;

        IPC ipc;
        int index = 0;

        public Window (IPC ipc) {
            this.ipc = ipc;

            GtkLayerShell.init_for_window (this);
            GtkLayerShell.set_layer (this, GtkLayerShell.Layer.TOP);

#if HAVE_LATEST_GTK_LAYER_SHELL
            GtkLayerShell.set_keyboard_mode (
                this,
                GtkLayerShell.KeyboardMode.EXCLUSIVE);
#else
            GtkLayerShell.set_keyboard_interactivity (this, true);
#endif

            this.key_release_event.connect ((e) => {
                switch (Gdk.keyval_name (e.keyval)) {
                    case "Alt_L":
                        this.hide ();
                        var selected = flow_box.get_selected_children ();
                        if (selected.length () == 0) break;
                        var item = (ApplicationItem) selected.nth_data (0);
                        if (item == null) break;
                        ipc.run_command (@"[con_id=$(item.appNode.id.to_string ())] focus");
                        break;
                }
                return true;
            });
            this.key_press_event.connect ((e) => {
                switch (Gdk.keyval_name (e.keyval)) {
                    case "Escape":
                        this.hide ();
                        break;
                }
                return true;
            });
        }

        public void select (bool next) {
            if (!visible) {
                index = 0;
                var node = ipc.get_reply (Sway_commands.GET_WORKSPACES);
                WorkspaceNode workspace = null;
                switch (node.get_node_type ()) {
                    case Json.NodeType.ARRAY:
                        var array = node.get_array ();
                        foreach (var item in array.get_elements ()) {
                            WorkspaceNode w = Json.gobject_deserialize (
                                typeof (WorkspaceNode), item) as WorkspaceNode;
                            if (w == null) continue;
                            if (w.focused && w.visible) {
                                workspace = w;
                                break;
                            }
                        }
                        break;
                    default: return;
                }
                if (workspace == null || workspace.nodes.size == 0) return;

                foreach (var child in flow_box.get_children ()) {
                    flow_box.remove (child);
                }
                unowned ArrayList<AppNode> nodes = workspace.nodes;
                foreach (var app in nodes) {
                    var item = new ApplicationItem (app);
                    if (item.is_valid) flow_box.add (item);
                }

                present ();
            } else {
                uint len = flow_box.get_children ().length ();
                if (len <= 1) return;
                if (next) {
                    index++;
                    if (index > len - 1) index = 0;
                } else {
                    index--;
                    if (index < 0) index = (int) len - 1;
                }
                Gtk.FlowBoxChild ? child = flow_box.get_child_at_index (index);
                if (child != null) flow_box.select_child (child);
            }
        }
    }
}
