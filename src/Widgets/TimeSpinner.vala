/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2021 Sam Thomas
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

        get_style_context ().add_class ("timer");

        output.connect (() => {
            if (value < 10) {
                text = "0%i".printf ((int) value);
                return true;
            }

            return false;
        });
    }
}
