
namespace Swayfloatingswitcher {
    void main (string[] args) {
        Gtk.init (ref args);
        var daemon = new Daemon ();
        Bus.own_name (BusType.SESSION, "org.erikreider.swayfloatingswitcher",
                      BusNameOwnerFlags.NONE,
                      (conn, e) => on_bus_aquired (conn, e, daemon),
                      () => {},
                      () => stderr.printf (
                          "Could not aquire \"org.erikreider.swayfloatingswitcher\" name\n"));

        Gtk.main ();
    }

    void on_bus_aquired (DBusConnection conn, string name, Daemon daemon) {
        try {
            conn.register_object ("/org/erikreider/swayfloatingswitcher", daemon);
        } catch (IOError e) {
            stderr.printf ("Could not register Swayfloatingswitcher service\n");
        }
    }
}
