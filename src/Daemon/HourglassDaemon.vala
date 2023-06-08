/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2020 Sam Thomas
 *                         2020-2023 Ryo Nakano
 */

namespace HourglassDaemon {
    public class Daemon : GLib.Object {
        public AlarmManager alarm_manager;
        public static Daemon get_default () {
            if (__instance == null) {
                __instance = new Daemon ();
            }

            return __instance;
        }
        private static Daemon __instance = null;

        private Daemon () {
        }

        construct {
            debug ("Hourglass-Daemon started");

            alarm_manager = new AlarmManager (this);
        }

        public void start () {
            Timeout.add (1000, () => {
                // Check timer every 0 second
                if (new DateTime.now_local ().get_second () == 0) {
                    alarm_manager.check_alarm ();
                }

                return true;
            });
        }

        public void send_notification (string summary, string body, string id) {
            var notification = new GLib.Notification (summary);
            notification.set_body (body);
            notification.set_priority (NotificationPriority.HIGH);

            GLib.Application.get_default ().send_notification ("%s-%s".printf (EXEC_NAME, id), notification);
        }
    }
}
