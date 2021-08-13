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

using Hourglass.Widgets;

public class Hourglass.Dialogs.NewAlarmDialog : Granite.Dialog {
    public signal void create_alarm (Alarm a);
    public signal void edit_alarm (Alarm old_alarm, Alarm new_alarm);

    public Alarm? alarm { get; construct; }

    private int[] repeat_days;
    private bool is_existing_alarm = false;

    public NewAlarmDialog (Gtk.Window parent, Alarm? alarm = null) {
        Object (
            transient_for: parent,
            alarm: alarm,
            resizable: false,
            deletable: false,
            modal: true
        );
    }

    construct {
        if (alarm != null) {
            is_existing_alarm = true;
            repeat_days = alarm.repeat;
        }

        var title_label = new Gtk.Label (_("Title:")) {
            halign = Gtk.Align.END
        };

        var title_entry = new Gtk.Entry ();

        var time_label = new Gtk.Label (_("Time:")) {
            halign = Gtk.Align.END
        };

        var time_picker = new Granite.Widgets.TimePicker ();

        var date_label = new Gtk.Label (_("Date:")) {
            halign = Gtk.Align.END
        };

        var date_picker = new Granite.Widgets.DatePicker ();

        var repeat_label = new Gtk.Label (_("Repeat:")) {
            halign = Gtk.Align.END
        };

        var repeat_day_picker = new Gtk.Button ();
        var popover = new MultiSelectPopover (repeat_day_picker, repeat_days);

        if (is_existing_alarm) {
            title_entry.text = alarm.title;
            time_picker.time = alarm.time;
            date_picker.date = alarm.time;
            repeat_day_picker.label = popover.get_display_string ();
        } else {
            time_picker.time = new GLib.DateTime.now_local ().add_minutes (10);
            repeat_day_picker.label = _("Never");
        }

        var main_grid = new Gtk.Grid () {
            row_spacing = 6,
            column_spacing = 12,
            margin_start = 12,
            margin_end = 12
        };

        main_grid.attach (title_label, 0, 0, 1, 1);
        main_grid.attach (title_entry, 1, 0, 1, 1);
        main_grid.attach (time_label , 0, 1, 1, 1);
        main_grid.attach (time_picker, 1, 1, 1, 1);
        main_grid.attach (date_label, 0, 2, 1, 1);
        main_grid.attach (date_picker, 1, 2, 1, 1);
        main_grid.attach (repeat_label, 0, 3, 1, 1);
        main_grid.attach (repeat_day_picker, 1, 3, 1, 1);

        get_content_area ().add (main_grid);

        var cancel_button = (Gtk.Button) add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

        var create_alarm_button = (Gtk.Button) add_button (
            is_existing_alarm ? _("Save") : _("Create Alarm"),
            Gtk.ResponseType.YES
        );
        create_alarm_button.get_style_context ().add_class ("green-button");

        //if user tries to enter ';' stop them
        title_entry.insert_text.connect ((new_text, new_text_length, ref pos) => {
            if (";" in new_text) {
                GLib.Signal.stop_emission_by_name (title_entry, "insert-text");
            }
        });

        repeat_day_picker.clicked.connect (() => {
            popover.set_selected ();
            popover.show_all ();
        });

        popover.closed.connect (() => {
            repeat_days = popover.get_selected ();
            repeat_day_picker.label = popover.get_display_string ();
        });

        create_alarm_button.clicked.connect (() => {
            string title = title_entry.get_text ();
            if (title == "") {
                title = _("Alarm");
            }

            var date = date_picker.date;
            var time = time_picker.time;

            //create datetime with time of alalarm
            var alarm_time = new GLib.DateTime.local (
                date.get_year (), date.get_month (), date.get_day_of_month (),
                time.get_hour (), time.get_minute (), time.get_second ()
            );

            Alarm new_alarm;
            if (repeat_days.length > 0) {
                new_alarm = new Alarm (alarm_time, title, repeat_days);
            } else {
                new_alarm = new Alarm (alarm_time, title);
            }

            if (is_existing_alarm) {
                edit_alarm (alarm, new_alarm);
            } else {
                create_alarm (new_alarm);
            }

            destroy ();
        });

        cancel_button.clicked.connect (() => {
            destroy ();
        });
    }
}
