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
            border_width = 6
        };
        box.get_style_context ().add_class ("linked");

        foreach (string day in shortened_days) {
            var toggle = new Gtk.ToggleButton.with_label (day);
            box.add (toggle);
            toggles += toggle;
        }

        box.show_all ();
        add (box);
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

    public string get_display_string () {
        return selected_to_string (selected_days);
    }

    public static string selected_to_string (int[] selected_days) {
        string[] shortened_days = {
            _("Sun"), _("Mon"), _("Tue"), _("Wed"), _("Thu"), _("Fri"), _("Sat")
        };

        string str = "";
        if (selected_days.length == 7) {
            str = _("Every Day");
        } else if (selected_days.length == 5 && !(0 in selected_days) && !(6 in selected_days)) {
            str = _("Every Weekday");
        } else if (selected_days.length == 2 && (0 in selected_days) && (6 in selected_days)) {
            str = _("Every Weekend");
        } else if (selected_days.length > 0) {
            int i = 0;
            foreach (int day in selected_days) {
                if (i == selected_days.length - 1) {
                    str += shortened_days[day];
                } else {
                    ///TRANSLATORS: %s represents translated string of a day of the week
                    str += _("%s, ").printf (shortened_days[day]);
                }

                i++;
            }
        } else {
            str = _("Never");
        }

        return str;
    }
}
