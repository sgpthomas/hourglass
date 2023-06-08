/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2020 Sam Thomas
 *                         2020-2023 Ryo Nakano
 */

namespace HourglassDaemon {

    public static GLib.Settings saved_alarms;
    public AlarmManager manager;

    public class HourglassAlarmDaemon : GLib.Object {
        public static HourglassAlarmDaemon get_default () {
            if (__instance == null) {
                __instance = new HourglassAlarmDaemon ();
            }

            return __instance;
        }
        private static HourglassAlarmDaemon __instance = null;

        private HourglassAlarmDaemon () {
        }

        static construct {
            saved_alarms = new GLib.Settings ("com.github.sgpthomas.hourglass.saved");
        }

        construct {
            debug ("Hourglass-Daemon started");

            manager = new AlarmManager (this);
            manager.load_alarm_list ();
        }

        public void start () {
            Timeout.add (1000, () => {
                // Check timer every 0 second
                if (new DateTime.now_local ().get_second () == 0) {
                    manager.check_alarm ();
                }

                return true;
            });
        }

        public void show (string summary, string body, string id) {
            var notification = new GLib.Notification (summary);
            notification.set_body (body);
            notification.set_priority (NotificationPriority.HIGH);

            GLib.Application.get_default ().send_notification ("%s-%s".printf (EXEC_NAME, id), notification);
        }
    }
}
