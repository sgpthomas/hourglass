/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2022 Sam Thomas
 */

public class Hourglass.Dialogs.MultiSelectPopover : Gtk.Popover {
    private Gtk.ToggleButton[] toggles;

    private int[]? selected_days;
    private string[] shortened_days = {
        _("Sun"), _("Mon"), _("Tue"), _("Wed"), _("Thu"), _("Fri"), _("Sat")
    };

    public MultiSelectPopover (Gtk.Widget parent, int[]? selected_days = null) {
        Object (
            relative_to: parent,
            modal: true
        );

        this.selected_days = selected_days;
    }

    construct {
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };
        box.get_style_context ().add_class ("linked");

        foreach (string day in shortened_days) {
            var toggle = new Gtk.ToggleButton.with_label (day);
            box.prepend (toggle);
            toggles += toggle;
        }

        child = box;
    }

    public int[] get_selected () {
        selected_days = {};
        for (int i = 0; i < toggles.length; i++) {
            if (toggles[i].active) {
                selected_days += i;
            }
        }

        return selected_days;
    }

    public void set_selected () {
        for (int i = 0; i < toggles.length; i++) {
            if (i in selected_days) {
                toggles[i].active = true;
            }
        }
    }
}
