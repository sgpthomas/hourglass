/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2021 Sam Thomas
 */

public class HourglassDaemon.NotificationManager : Object {
    public GLib.Application app { private get; construct; }

    public NotificationManager (GLib.Application app) {
        Object (app: app);
    }

    public void show (string summary, string body, string id) {
        var notification = new GLib.Notification (summary);
        notification.set_body (body);
        notification.set_priority (NotificationPriority.HIGH);

        app.send_notification ("%s-%s".printf (EXEC_NAME, id), notification);
    }
}
