namespace Swayfloatingswitcher {
    [GtkTemplate (ui = "/org/erikreider/sway-floating-switcher/ApplicationItem/application_item.ui")]
    public class ApplicationItem : Gtk.FlowBoxChild {

        [GtkChild]
        unowned Gtk.Image image;
        [GtkChild]
        unowned Gtk.Label title;

        public AppNode appNode { public get; private set; }
        public bool is_valid { public get; private set; default = true; }
        public bool is_application { public get; private set; default = true; }
        public string cmd { public get; private set; default = ""; }

        construct {
            image.set_pixel_size (96);
        }

        public ApplicationItem (AppNode node) {
            this.appNode = node;

            string ? name = null;
            try {
                string path = Path.build_path (Path.DIR_SEPARATOR_S,
                                               "/proc",
                                               this.appNode.pid.to_string (),
                                               "exe");
                string link = FileUtils.read_link (path);
                string basename = File.new_for_path (link).get_basename ();
                string * *[] results = DesktopAppInfo.search (basename);
                if (results.length > 0) {
                    string desktop = *results[0];
                    var app = new DesktopAppInfo (desktop);
                    image.set_from_gicon (app.get_icon (),
                                          Gtk.IconSize.INVALID);
                    name = appNode.name ?? app.get_display_name ();
                } else {
                    image.set_from_icon_name ("image-missing",
                                              Gtk.IconSize.INVALID);
                    name = this.appNode.name ?? basename;
                }
            } catch (Error e) {
                stderr.printf ("App item ERROR: %s\n", e.message);
                is_valid = false;
                return;
            }

            title.set_text (name);
        }

        public ApplicationItem.custom (string title,
                                       owned string image_name,
                                       string cmd) {
            this.is_application = false;
            this.cmd = cmd;

            this.title.set_text (title);
            if (image_name.length == 0) image_name = " image-missing";
            this.image.set_from_icon_name (image_name,
                                           Gtk.IconSize.INVALID);
        }
    }
}
