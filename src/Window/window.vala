using Gee;

namespace Swayfloatingswitcher {
    [GtkTemplate (ui = "/org/erikreider/sway-floating-switcher/Window/window.ui")]
    public class Window : Gtk.ApplicationWindow {
        const double DEGREES = Math.PI / 180.0;

        [GtkChild]
        unowned Gtk.FlowBox flow_box;

        IPC ipc;
        int index = 0;

        public Window (Gtk.Application app, IPC ipc) {
            Object (application: app);

            this.ipc = ipc;

            GtkLayerShell.init_for_window (this);
            GtkLayerShell.set_layer (this, GtkLayerShell.Layer.OVERLAY);

#if HAVE_LATEST_GTK_LAYER_SHELL
            GtkLayerShell.set_keyboard_mode (
                this,
                GtkLayerShell.KeyboardMode.EXCLUSIVE);
#else
            GtkLayerShell.set_keyboard_interactivity (this, true);
#endif

            this.set_size_request (10, 10);
            get_style_context ().add_class ("osd");
        }

        protected override bool draw(Cairo.Context ctx) {
            double width = this.get_allocated_width ();
            double height = this.get_allocated_height ();
            double radius = 12.0;

            ctx.new_sub_path ();
            ctx.arc (width - radius, radius, radius, -90 * DEGREES, 0 * DEGREES);
            ctx.arc (width - radius, height - radius, radius, 0 * DEGREES, 90 * DEGREES);
            ctx.arc (radius, height - radius, radius, 90 * DEGREES, 180 * DEGREES);
            ctx.arc (radius, radius, radius, 180 * DEGREES, 270 * DEGREES);
            ctx.close_path ();

            ctx.clip ();
            base.draw (ctx);
            return true;
        }

        public override bool key_release_event (Gdk.EventKey e) {
            debug ("Release keyval: %s\n", Gdk.keyval_name (e.keyval));
            switch (Gdk.keyval_name (e.keyval)) {
                case "Alt_L":
                case "Meta_L":
                    this.hide ();
                    select_item ();
                    break;
            }
            return true;
        }

        public override bool key_press_event (Gdk.EventKey e) {
            debug ("Press keyval: %s\n", Gdk.keyval_name (e.keyval));
            switch (Gdk.keyval_name (e.keyval)) {
                case "Escape":
                    this.hide ();
                    break;
                case "Return":
                    this.hide ();
                    select_item ();
                    break;
                case "Left":
                    select (false);
                    break;
                case "Right":
                    select (true);
                    break;
            }
            return true;
        }

        private void select_item () {
            Idle.add (() => {
                var selected = flow_box.get_selected_children ();
                if (selected.length () == 0) return Source.REMOVE;
                var item = (ApplicationItem) selected.nth_data (0);
                if (item == null) return Source.REMOVE;
                string cmd = item.is_application
                    ? @"[con_id=$(item.appNode.id.to_string ())] focus"
                    : item.cmd;
                ipc.run_command (cmd);
                return Source.REMOVE;
            }, Priority.HIGH_IDLE);
        }

        public void select (bool next) {
            if (!visible) {
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

                var tiling_item = new ApplicationItem.custom ("Tiling",
                                                              "view-grid-symbolic",
                                                              "focus tiling");
                flow_box.add (tiling_item);

                bool is_floating_focus = false;
                unowned ArrayList<AppNode> nodes = workspace.nodes;
                foreach (var app in nodes) {
                    if (app.focused) is_floating_focus = true;
                    var item = new ApplicationItem (app);
                    if (item.is_valid) flow_box.add (item);
                }

                GLib.List<weak Gtk.Widget> children = flow_box.get_children ();
                uint len = children.length ();
                // To quickly toggle between tiled and floating windows
                index = is_floating_focus ? 0 : 1;
                if (len > 2) {
                    if (next) {
                        index = is_floating_focus ? 2 : 1;
                    } else {
                        index = (int) len - 1;
                    }
                }
                this.present ();
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
            }
            Gtk.FlowBoxChild ? child = flow_box.get_child_at_index (index);
            if (child != null) flow_box.select_child (child);
            return;
        }
    }
}
