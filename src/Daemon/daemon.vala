namespace Swayfloatingswitcher {
    [DBus (name = "org.erikreider.swayfloatingswitcher")]
    class Daemon : Object {
        IPC ipc;
        Window win;

        public Daemon() {
            this.ipc = new IPC();
            this.win = new Window (ipc);
        }

        public void next () throws Error {
            win.select (true);
        }
        public void previous () throws Error {
            win.select (false);
        }
    }
}
