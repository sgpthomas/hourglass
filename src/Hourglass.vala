/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2021 Sam Thomas
 */

namespace Hourglass {
    public Hourglass.Services.HourglassClient dbus_server;
    public static GLib.Settings saved;

    public class HourglassApp : Gtk.Application {
        private Hourglass.Window.MainWindow main_window;

        construct {
            dbus_server = new Hourglass.Services.DBusManager ().client;
            GLib.Intl.setlocale (LocaleCategory.ALL, "");
            GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
            GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
            GLib.Intl.textdomain (GETTEXT_PACKAGE);
        }

        static construct {
            saved = new GLib.Settings ("com.github.sgpthomas.hourglass.saved");
        }

        public HourglassApp () {
            Object (
                application_id :"com.github.sgpthomas.client",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        public override void activate () {
            if (main_window != null) {
                debug ("There is an instance of hourglass already open.");
                main_window.deiconify ();
                return;
            }

            main_window = new Hourglass.Window.MainWindow ();

            if (Hourglass.saved.get_boolean ("is-maximized")) {
                main_window.maximize ();
            } else {
                int window_width, window_height;
                Hourglass.saved.get ("window-size", "(ii)", out window_width, out window_height);
                main_window.resize (window_width, window_height);
            }

            int widnow_x, window_y;
            Hourglass.saved.get ("window-position", "(ii)", out widnow_x, out window_y);
            if (widnow_x != -1 | window_y != -1) {
                main_window.move (widnow_x, window_y);
            } else {
                main_window.window_position = Gtk.WindowPosition.CENTER;
            }

            Gtk.main ();
        }

        public static void spawn_daemon () {
            debug ("starting daemon");
            string[] spawn_args = {"com.github.sgpthomas.hourglass-daemon"}; // command name

            //try to spawn daemon
            try {
                GLib.Process.spawn_async ("/", spawn_args, Environ.get () , GLib.SpawnFlags.SEARCH_PATH, null, null);
            } catch (GLib.SpawnError e) {
                error ("Spawning error message: %s".printf (e.message));
            }
        }
    }

    public static void main (string[] args) {
        HourglassApp.spawn_daemon ();

        Gtk.init (ref args);
        Hdy.init ();

        HourglassApp app = new HourglassApp ();
        app.run (args);
    }
}
