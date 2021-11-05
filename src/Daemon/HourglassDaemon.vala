/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2021 Sam Thomas
 */

namespace HourglassDaemon {

    public HourglassServer server;
    public static GLib.Settings saved_alarms;
    public NotificationManager notification;
    public AlarmManager manager;

    public class HourglassAlarmDaemon : GLib.Application {

        public HourglassAlarmDaemon () {
            Object (application_id: "com.github.sgpthomas.hourglass", flags: ApplicationFlags.NON_UNIQUE);
            set_inactivity_timeout (1000);
        }

        static construct {
            saved_alarms = new GLib.Settings ("com.github.sgpthomas.hourglass.saved");
        }

        ~HourglassAlarmDaemon () {
            release ();
        }

        public override void startup () {
            debug ("Hourglass-Daemon started");
            base.startup ();

            server = new HourglassServer ();
            manager = new AlarmManager ();
            notification = new NotificationManager (this);

            manager.load_alarm_list ();

            hold ();

            Timeout.add (1000, () => {
                // Check timer every 0 second
                if (new DateTime.now_local ().get_second () == 0) {
                    manager.check_alarm ();
                }

                return true;
            });
        }

        public override void activate () {
            debug ("Daemon Activated");
        }

        public override bool dbus_register (DBusConnection connection, string object_path) throws Error {
            return true;
        }
    }

    //start the daemon
    public static int main (string[] args) {
        var app = new HourglassAlarmDaemon (); //create instance of hourglass daemon

        //try to register app
        try {
            app.register ();
        } catch (Error e) {
            error ("Couldn't register application.");
        }

        //run
        return app.run (args);
    }
}
