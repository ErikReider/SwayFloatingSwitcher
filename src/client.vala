[DBus (name = "org.erikreider.swayfloatingswitcher")]
interface FloatingDaemon : Object {

    public abstract void next () throws Error;
    public abstract void previous () throws Error;
}

private FloatingDaemon floating_daemon = null;

private void print_help (string[] args) {
    print (@"Usage:\n");
    print (@"\t $(args[0]) <OPTION>\n");
    print (@"Help:\n");
    print (@"\t -h, --help \t\t Show help options\n");
    print (@"Options:\n");
    print (@"\t -n, --next \t\t Selects the next application\n");
    print (@"\t -p, --previous \t Selects the previous application\n");
}

public int command_line (string[] args) {
    if (args.length < 2) {
        print_help (args);
        Process.exit (1);
    }
    try {
        switch (args[1]) {
            case "--help":
            case "-h":
                print_help (args);
                break;
            case "--next":
            case "-n":
                floating_daemon.next ();
                break;
            case "--previous":
            case "-p":
                floating_daemon.previous ();
                break;
            default:
                print_help (args);
                break;
        }
    } catch (Error e) {
        stderr.printf ("ERROR: %s\n", e.message);
        return 1;
    }
    return 0;
}

void print_connection_error () {
    stderr.printf (
        "ERROR! Could not connect to switcher service...\n");
}

int try_connect (string[] args) {
    try {
        floating_daemon = Bus.get_proxy_sync (
            BusType.SESSION,
            "org.erikreider.swayfloatingswitcher",
            "/org/erikreider/swayfloatingswitcher");
        if (command_line (args) == 1) {
            print_connection_error ();
            return 1;
        }
        return 0;
    } catch (Error e) {
        print_connection_error ();
        return 1;
    }
}

public int main (string[] args) {
    if (try_connect (args) == 1) {
        Bus.watch_name (
            BusType.SESSION,
            "org.erikreider.swayfloatingswitcher",
            GLib.BusNameWatcherFlags.NONE);
    }
    return 0;
}
