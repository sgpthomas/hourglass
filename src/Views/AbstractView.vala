/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2022 Sam Thomas
 */

public abstract class Hourglass.Views.AbstractView : Gtk.Box {
    public abstract string id { get; }
    public abstract string display_name { get; }
    public abstract bool should_keep_open { get; }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 0;
    }
}
