/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2020 Sam Thomas
 *                         2020-2023 Ryo Nakano
 */

namespace HourglassDaemon {
    public class Daemon : GLib.Object {
        public AlarmManager alarm_manager;

        public static Daemon get_default () {
            if (instance == null) {
                instance = new Daemon ();
            }

            return instance;
        }
        private static Daemon instance = null;

        private Daemon () {
        }

        construct {
            alarm_manager = new AlarmManager (this);
        }

        public void start () {
            debug ("Starting Hourglass Daemon…");

            Timeout.add (1000, () => {
                // Check timer every 0 second
                if (new DateTime.now_local ().get_second () == 0) {
                    alarm_manager.check_alarm ();
                }

                return GLib.Source.CONTINUE;
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
