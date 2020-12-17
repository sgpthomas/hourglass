/* Copyright 2015-2017 Sam Thomas
*
* This file is part of Hourglass.
*
* Hourglass is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* Hourglass is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with Hourglass. If not, see http://www.gnu.org/licenses/.
*/

namespace HourglassDaemon {

    public HourglassServer server;
    public static GLib.Settings saved_alarms;
    public static GLib.Settings settings;
    public NotificationManager notification;
    public AlarmManager manager;

    public class HourglassAlarmDaemon : GLib.Application {

        public HourglassAlarmDaemon () {
            Object (application_id: "com.github.sgpthomas.hourglass", flags: ApplicationFlags.NON_UNIQUE);
            set_inactivity_timeout (1000);
        }

        static construct {
            saved_alarms = new GLib.Settings ("com.github.sgpthomas.hourglass.saved");
            settings = new GLib.Settings ("com.github.sgpthomas.hourglass.settings");
        }

        ~HourglassAlarmDaemon () {
            release ();
        }

        public override void startup () {
            debug ("Hourglass-Daemon started");
            base.startup ();

            server = new HourglassServer ();
            manager = new AlarmManager ();
            notification = new NotificationManager ();

            manager.load_alarm_list ();

            hold ();

            // check to make sure that update frequency is below 60,000
            if (HourglassDaemon.settings.get_int ("update-frequency") >= 60000) {
                HourglassDaemon.settings.set_int ("update-frequency", 15000);
            }

            Timeout.add (HourglassDaemon.settings.get_int ("update-frequency"), manager.check_alarm);
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
