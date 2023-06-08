/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2020 Sam Thomas
 *                         2020-2023 Ryo Nakano
 */

namespace Hourglass {
    public HourglassDaemon.Daemon daemon;
    public static GLib.Settings saved;

    public class HourglassApp : Gtk.Application {
        const OptionEntry[] OPTIONS = {
            { "background", 'b', 0, OptionArg.NONE, out run_in_background, "Run the Application in background", null },
            { null }
        };

        private static bool run_in_background;

        private bool first_activation = true;
        private Hourglass.Window.MainWindow main_window;

        construct {
            daemon = HourglassDaemon.Daemon.get_default ();
            GLib.Intl.setlocale (LocaleCategory.ALL, "");
            GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
            GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
            GLib.Intl.textdomain (GETTEXT_PACKAGE);

            add_main_option_entries (OPTIONS);
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

        protected override void startup () {
            base.startup ();

            daemon.start ();
        }

        public override void activate () {
            if (first_activation) {
                hold ();
                first_activation = false;
            }

            if (run_in_background) {
                request_background.begin ();
                run_in_background = false;
                return;
            }

            if (main_window != null) {
                main_window.present ();
                return;
            }

            main_window = new Hourglass.Window.MainWindow (this);
            // The window seems to need showing before restoring its size in Gtk4
            main_window.present ();

            Hourglass.saved.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
            Hourglass.saved.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

            /*
             * Binding of window maximization with "SettingsBindFlags.DEFAULT" results the window getting bigger and bigger on open.
             * So we use the prepared binding only for setting
             */
            if (Hourglass.saved.get_boolean ("is-maximized")) {
                main_window.maximize ();
            }

            Hourglass.saved.bind ("is-maximized", main_window, "maximized", SettingsBindFlags.SET);
        }

        public async void request_background () {
            var portal = new Xdp.Portal ();

            Xdp.Parent? parent = null;
            if (active_window != null) {
                parent = Xdp.parent_new_gtk (active_window);
            }

            var command = new GenericArray<weak string> ();
            command.add ("com.github.sgpthomas.hourglass");
            command.add ("--background");

            try {
                bool result = yield portal.request_background (
                    parent,
                    _("Hourglass will automatically start when this device turns on and keep running when its window is closed so that it can send notifications when alarm goes off."),
                    (owned) command,
                    Xdp.BackgroundFlags.AUTOSTART,
                    null
                );
                if (!result) {
                    release ();
                }
            } catch (Error e) {
                if (e is IOError.CANCELLED) {
                    debug ("Request for autostart and background permissions denied: %s", e.message);
                    release ();
                } else {
                    warning ("Failed to request autostart and background permissions: %s", e.message);
                }
            }
        }
    }

    public static int main (string[] args) {
        return new HourglassApp ().run (args);
    }
}
