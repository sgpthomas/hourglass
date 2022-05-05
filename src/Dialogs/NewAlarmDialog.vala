/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2022 Sam Thomas
 */

using Hourglass.Widgets;

public class Hourglass.Dialogs.NewAlarmDialog : Granite.Dialog {
    public signal void create_alarm (Alarm a);
    public signal void edit_alarm (Alarm old_alarm, Alarm new_alarm);

    public Alarm? alarm { get; construct; }

    private Gtk.Switch date_switch;

    private bool is_existing_alarm = false;
    private int[]? repeat_days = null;

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

        var title_entry = new Gtk.Entry () {
            placeholder_text = _("Alarm")
        };

        var time_label = new Gtk.Label (_("Time:")) {
            halign = Gtk.Align.END
        };

        var time_picker = new Granite.TimePicker ();

        var date_label = new Gtk.Label (_("Date:")) {
            halign = Gtk.Align.END
        };

        date_switch = new Gtk.Switch () {
            halign = Gtk.Align.START
        };

        var date_picker = new Granite.DatePicker ();

        var repeat_label = new Gtk.Label (_("Repeat:")) {
            halign = Gtk.Align.END
        };

        var popover = new MultiSelectPopover (repeat_days);
        var repeat_day_picker = new Gtk.MenuButton () {
            popover = popover
        };

        if (is_existing_alarm) {
            title_entry.text = alarm.title;
            time_picker.time = alarm.time;
            date_switch.active = alarm.has_date;
            date_picker.date = alarm.time;
        } else {
            time_picker.time = new GLib.DateTime.now_local ().add_minutes (10);
        }

        repeat_day_picker.label = Utils.selected_days_to_string (repeat_days);

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
        main_grid.attach (date_switch, 1, 2, 1, 1);
        main_grid.attach (date_picker, 1, 3, 1, 1);
        main_grid.attach (repeat_label, 0, 4, 1, 1);
        main_grid.attach (repeat_day_picker, 1, 4, 1, 1);

        get_content_area ().append (main_grid);

        var cancel_button = (Gtk.Button) add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

        var create_alarm_button = (Gtk.Button) add_button (
            is_existing_alarm ? _("Save") : _("Create Alarm"),
            Gtk.ResponseType.YES
        );
        create_alarm_button.get_style_context ().add_class (Granite.STYLE_CLASS_SUGGESTED_ACTION);

        //if user tries to enter ';' stop them
        title_entry.insert_text.connect ((new_text, new_text_length, ref pos) => {
            if (Hourglass.Utils.ALARM_INFO_SEPARATOR in new_text) {
                GLib.Signal.stop_emission_by_name (title_entry, "insert-text");
            }
        });

        repeat_day_picker.activate.connect (() => {
            popover.set_selected ();
            popover.popup ();
        });

        popover.closed.connect (() => {
            repeat_days = popover.get_selected ();
            repeat_day_picker.label = Utils.selected_days_to_string (repeat_days);
        });

        response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.YES) {
                string title = title_entry.get_text ();
                if (title == "") {
                    title = title_entry.placeholder_text;
                }

                bool has_date = date_switch.active;

                var date = date_picker.date;
                var time = time_picker.time;

                var now = new DateTime.now_local ();
                //treat the time as of tomorrow when the date isn't specified and the given time is prior to now
                if (!has_date &&
                        (time.get_hour () == now.get_hour () && time.get_minute () < now.get_minute ()) ||
                        time.get_hour () < now.get_hour ()
                ) {
                    date = now.add_days (1);
                    has_date = true;
                }

                //create datetime with time of alarm
                var alarm_time = new GLib.DateTime.local (
                    date.get_year (), date.get_month (), date.get_day_of_month (),
                    time.get_hour (), time.get_minute (), time.get_second ()
                );

                Alarm new_alarm;
                if (repeat_days.length > 0) {
                    new_alarm = new Alarm (alarm_time, has_date, title, repeat_days);
                } else {
                    new_alarm = new Alarm (alarm_time, has_date, title);
                }

                if (is_existing_alarm) {
                    edit_alarm (alarm, new_alarm);
                } else {
                    create_alarm (new_alarm);
                }
            }

            destroy ();
        });

        date_switch.bind_property ("active", date_picker, "sensitive", GLib.BindingFlags.SYNC_CREATE);
    }
}
