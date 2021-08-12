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

public class Hourglass.Widgets.TimeSpinner : Gtk.SpinButton {
    public int limit { get; construct; }

    public TimeSpinner (int limit) {
        Object (
            limit: limit,
            orientation: Gtk.Orientation.VERTICAL,
            wrap: true,
            numeric: true
        );
    }

    construct {
        var adj = new Gtk.Adjustment (0, 0, limit, 1, 0, 0);
        configure (adj, 1, 0);

        get_style_context ().add_class ("time-spinner");

        output.connect (() => {
            if (value < 10) {
                text = "0%i".printf ((int) value);
                return true;
            }

            return false;
        });
    }
}
