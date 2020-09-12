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

using Gtk;

using Granite.Widgets;
using Hourglass.Widgets;

namespace Hourglass.Dialogs {

    public class NewAlarmDialog : Gtk.Dialog {

        //Widgets
        private Entry title_entry;
        private TimePicker time_picker;
        private DatePicker date_picker;
        private Button repeat_day_picker;
        //private ComboBoxText repeat_combo_box;

        //list of repeat days
        private int[] repeat_days;

        //buttons
        private ButtonBox final_actions;
        private Button cancel_button;
        private Button delete_alarm_button;
        private Button create_alarm_button;

        //should display edit alarm dialog instead
        private bool edit_alarm_enabled = false;
        private Alarm alarm;

        //signals
        public signal void create_alarm (Alarm a);
        public signal void edit_alarm (Alarm old_alarm, Alarm new_alarm);
        public signal void delete_alarm (Alarm a);

        public NewAlarmDialog (Gtk.Window? parent, Alarm? alarm = null) {
            //assign the dialog a parent if one is provided
            if (parent != null) {
                set_transient_for (parent);
            }

            //if alarm is given, change some setings
            if (alarm != null) {
                edit_alarm_enabled = true;
                this.alarm = alarm;
                repeat_days = alarm.repeat;
            }

            //some dialog settings
            set_resizable (false);  //make dialog non-resizable
            set_deletable (false);   //make dialog non-deletable
            set_modal (true);

            //setup ui
            create_layout ();

            //connect signals
            connect_signals ();
        }

        private void create_layout () {
            //Title Entry
            title_entry = new Entry ();
            if (edit_alarm_enabled) title_entry.text = alarm.title;
            //if user tries to enter ';' stop them
            title_entry.insert_text.connect ((new_text, new_text_length, ref pos) => {
                if (";" in new_text) {
                    GLib.Signal.stop_emission_by_name (title_entry, "insert-text");
                }
            });

            //Time Picker
            time_picker = new TimePicker ();
            if (edit_alarm_enabled) time_picker.time = alarm.time; //set to time of alarm
            else time_picker.time = new DateTime.now_local ().add_minutes (10); //or set to current time plus 10

            //Date Picker
            date_picker = new DatePicker ();
            if (edit_alarm_enabled) date_picker.date = alarm.time; //set date_picker to date of alarm

            //Combo box
            //repeat_combo_box = new ComboBoxText ();
            var repeat_day_picker_label = edit_alarm_enabled ? MultiSelectPopover.selected_to_string (repeat_days) : _("Never");
            repeat_day_picker = new Button.with_label (repeat_day_picker_label);

            //create model for combo box
            /*repeat_combo_box.append ("nev", _("Never"));
            repeat_combo_box.append ("sun", _("Every Sunday"));
            repeat_combo_box.append ("mon", _("Every Monday"));
            repeat_combo_box.append ("tue", _("Every Tueday"));
            repeat_combo_box.append ("wed", _("Every Wednesday"));
            repeat_combo_box.append ("thur", _("Every Thursday"));
            repeat_combo_box.append ("fri", _("Every Friday"));
            repeat_combo_box.append ("sat", _("Every Saturday"));
            repeat_combo_box.set_active (0);*/

            //final action button box
            final_actions = new ButtonBox (Gtk.Orientation.HORIZONTAL);
            final_actions.set_layout (Gtk.ButtonBoxStyle.END);
            final_actions.spacing = 12;
            final_actions.margin_top = 6;

            var create_alarm_button_label = edit_alarm_enabled ? _("Save") : _("Create Alarm");

            cancel_button = new Button.with_label (_("Cancel"));

            delete_alarm_button = new Button.with_label (_("Delete"));
            delete_alarm_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);
            create_alarm_button = new Button.with_label (create_alarm_button_label);
            create_alarm_button.get_style_context ().add_class ("green-button");

            if (edit_alarm_enabled) {
                final_actions.pack_start (delete_alarm_button);
            }

            final_actions.pack_start (cancel_button);
            final_actions.pack_start (create_alarm_button);

            //put everything into a grid
            var main_grid = new Grid ();
            main_grid.row_spacing = 6;
            main_grid.column_spacing = 12;
            main_grid.margin_start = 12;
            main_grid.margin_end = 12;

            var label = new Granite.HeaderLabel (_("Title:"));
            label.halign = Gtk.Align.END;
            main_grid.attach (label, 0, 0, 1, 1);
            main_grid.attach (title_entry, 1, 0, 1, 1);

            label = new Granite.HeaderLabel (_("Time:"));
            label.halign = Gtk.Align.END;
            main_grid.attach (label , 0, 1, 1, 1);
            main_grid.attach (time_picker, 1, 1, 1, 1);

            label = new Granite.HeaderLabel (_("Date:"));
            label.halign = Gtk.Align.END;
            main_grid.attach (label, 0, 2, 1, 1);
            main_grid.attach (date_picker, 1, 2, 1, 1);

            /*label = new Label (_("Repeat:"));
            label.halign = Gtk.Align.END;
            main_grid.attach (label, 0, 3, 1, 1);
            main_grid.attach (repeat_combo_box, 1, 3, 1, 1);*/

            label = new Granite.HeaderLabel (_("Repeat:"));
            label.halign = Gtk.Align.END;
            main_grid.attach (label, 0, 3, 1, 1);
            main_grid.attach (repeat_day_picker, 1, 3, 1, 1);

            main_grid.attach (final_actions, 0, 4, 2, 1);

            //put the grid into the dialog
            get_content_area ().add (main_grid);
        }

        private void connect_signals () {
            var popover = new MultiSelectPopover (repeat_day_picker, repeat_days);

            repeat_day_picker.clicked.connect (() => {
                //var dialog = new MultiSelectDialog (this, repeat_days);
                //dialog.show_all ();

                /*dialog.on_finish.connect ((selected, str) => {
                    repeat_day_picker.label = str;
                    repeat_days = selected;
                });*/
                popover.closed.connect (() => {
                    repeat_day_picker.label = popover.get_display_string ();
                    repeat_days = popover.get_selected ();
                });

                popover.show_all ();
            });
            //create alarm
            create_alarm_button.clicked.connect (() => {
                string title = title_entry.get_text ();
                if (title == "") title = "Alarm";

                var time = time_picker.time; //time in time picker plus today's date
                //debug ("Time %i:%i", time.get_month (), time.get_day_of_month ());
                var date = date_picker.date; //date set in datepicker
                //debug ("Date %i:%i", date.get_month (), date.get_day_of_month ());

                //create datetime with time of alalarm
                var alarm_time = new DateTime.local (date.get_year (), date.get_month (), date.get_day_of_month (), time.get_hour (), time.get_minute (), time.get_second ());
                //time = time.add_months (time.get_month () - date.get_month ()); //current month - set month
                //time = time.add_days (time.get_day_of_month () - date.get_day_of_month ()); //current day - set day

                Alarm a;
                if (repeat_days.length > 0) {
                    a = new Alarm (alarm_time, title, repeat_days);
                } else {
                    a = new Alarm (alarm_time, title);
                }


                if (edit_alarm_enabled) {
                    edit_alarm (alarm, a);
                } else {
                    create_alarm (a);
                }
                this.destroy ();
            });

            delete_alarm_button.clicked.connect (() => {
                delete_alarm (alarm);
                this.destroy ();
            });

            cancel_button.clicked.connect (() => {
                this.destroy ();
            });
        }
    }
}
