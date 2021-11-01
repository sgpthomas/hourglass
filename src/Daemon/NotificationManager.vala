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
