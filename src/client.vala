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
    bool skip_wait = "--skip-wait" in args || "-sw" in args;

    try {
        if (args.length < 2) {
            print_help (args);
            return 1;
        }
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
        stderr.printf (e.message + "\n");
        if (skip_wait) Process.exit (1);
        return 1;
    }
    return 0;
}

void print_connection_error () {
    stderr.printf (
        "Could not connect to CC service. Will wait for connection...\n");
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
        MainLoop loop = new MainLoop ();
        Bus.watch_name (
            BusType.SESSION,
            "org.erikreider.swayfloatingswitcher",
            GLib.BusNameWatcherFlags.NONE,
            (conn, name, name_owner) => {
            if (try_connect (args) == 0) loop.quit ();
        },
            null);
        loop.run ();
    }
    return 0;
}
