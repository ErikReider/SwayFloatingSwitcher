namespace Swayfloatingswitcher {
    private enum ActionTypes {
        INVALID, NEXT, PREVIOUS, CLOSE;

        public string to_str () {
            switch (this) {
                case NEXT:
                    return "NEXT";
                case PREVIOUS:
                    return "PREVIOUS";
                case CLOSE:
                    return "CLOSE";
                default:
                    return "INVALID";
            }
        }

        public static ActionTypes from_str (string value) {
            switch (value) {
                case "NEXT":
                    return NEXT;
                case "PREVIOUS":
                    return PREVIOUS;
                case "CLOSE":
                    return CLOSE;
                default:
                    return INVALID;
            }
        }
    }

    private const OptionEntry[] ENTRIES = {
        {
            "next",
            'n',
            OptionFlags.NONE,
            OptionArg.NONE,
            null,
            "Selects the next application",
            null
        },
        {
            "previous",
            'p',
            OptionFlags.NONE,
            OptionArg.NONE,
            null,
            "Selects the previous application",
            null
        },
        {
            "close",
            'c',
            OptionFlags.NONE,
            OptionArg.NONE,
            null,
            "Closes the window",
            null
        },
        { null }
    };

    class Application : Gtk.Application {
        bool started = false;
        ulong action_signal_id = 0;

        Window window;

        const string ACTION_NAME = "action";

        public Application () {
            Object (application_id: "org.erikreider.swayfloatingswitcher",
                    flags : ApplicationFlags.FLAGS_NONE);

            this.add_main_option_entries (ENTRIES);

            SimpleAction action = new SimpleAction (ACTION_NAME,
                                                    VariantType.STRING);
            action_signal_id = action.activate.connect (on_activate_action);
            this.add_action (action);
            try {
                this.register ();
            } catch (Error e) {
                printerr ("Application register error: %s\n", e.message);
            }
        }

        protected override void activate () {
            if (started) return;
            started = true;

            window = new Window (this, new IPC ());
        }

        protected override int handle_local_options (VariantDict args) {
            Variant variant = args.end ();
            if (variant.n_children () > 1) {
                printerr ("Only run with one arg at once!...\n");
                return 1;
            } else if (variant.n_children () == 0) {
                return -1;
            }

            if (!variant.is_container ()) {
                printerr ("VariantDict isn't a container!...\n");
                return 1;
            }

            Variant child = variant.get_child_value (0);
            string child_type = child.get_type_string ();
            if (child_type != "{sv}") {
                printerr ("VariantDict entry isn't the correct type: \"%s\"...\n",
                          child_type);
                return 1;
            }
            Variant ? type = null;
            string key = child.get_child_value (0).get_string ();
            switch (key) {
                case "next":
                    type = new Variant.string (ActionTypes.NEXT.to_str ());
                    break;
                case "previous":
                    type = new Variant.string (ActionTypes.PREVIOUS.to_str ());
                    break;
                case "close":
                    type = new Variant.string (ActionTypes.CLOSE.to_str ());
                    break;
            }

            if (type != null) {
                this.activate_action (ACTION_NAME, type);
                return 0;
            }
            printerr ("Invalid arg: %s...\n", key);
            return 1;
        }

        private void on_activate_action (SimpleAction action, Variant ? variant) {
            if (!started) {
                printerr ("Please start the executable separately before running with args!...");
                return;
            }

            action.disconnect (action_signal_id);
            action_signal_id = 0;

            string key = variant.get_string ();
            switch (ActionTypes.from_str (key)) {
                case ActionTypes.NEXT:
                    window.select (true);
                    break;
                case ActionTypes.PREVIOUS:
                    window.select (false);
                    break;
                case ActionTypes.CLOSE:
                    window.hide ();
                    break;
                case ActionTypes.INVALID:
                default:
                    printerr ("INVALID action: %s...\n", key);
                    return;
            }

            action_signal_id = action.activate.connect (on_activate_action);
        }
    }

    void main (string[] args) {
        Gtk.init (ref args);

        var application = new Application ();
        application.run (args);
    }
}
