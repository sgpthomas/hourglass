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

public class HourglassDaemon.NotificationManager {
    private Notify.Notification notification;
    private Canberra.Context player;

    private bool open = false;

    public NotificationManager () {
        Notify.init ("com.github.sgpthomas.hourglass");

        Canberra.Context.create (out player);
    }

    public void show (string summary, string body = "", string track = "") {
        open = true;
        try {
            if (notification == null) {
                notification = new Notify.Notification (summary, body, "com.github.sgpthomas.hourglass"); // create notification
            } else {
                notification.update (summary, body, "com.github.sgpthomas.hourglass"); // update notification if it already exists
            }

            notification.set_urgency (Notify.Urgency.CRITICAL);
            notification.show ();

            notification.closed.connect (() => {
                player.cancel (1);
                open = false;
            });

            // player sound
            player.play (1, Canberra.PROP_EVENT_ID, HourglassDaemon.settings.get_string ("sound"), Canberra.PROP_MEDIA_ROLE, "alarm");

            Timeout.add (10000, () => {
                if (open) {
                    player.play (1, Canberra.PROP_EVENT_ID, HourglassDaemon.settings.get_string ("sound"), Canberra.PROP_MEDIA_ROLE, "alarm");
                    return Source.CONTINUE;
                } else {
                    return Source.REMOVE;
                }
            });
        } catch (GLib.Error e) {
            error ("Error: %s", e.message);
        }
    }
}
