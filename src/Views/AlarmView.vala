/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2015-2020 Sam Thomas
 *                         2020-2025 Ryo Nakano
 */

using Hourglass.Widgets;

public class Hourglass.Views.AlarmView : AbstractView {
    public override string id {
        get {
            return "alarm";
        }
    }

    public override string display_name {
        get {
            return _("Alarm");
        }
    }

    public override bool should_keep_open {
        get {
            return false;
        }
    }

    public Hourglass.Window.MainWindow window { get; construct; }

    private Gtk.ListBox list_box;
    private Gtk.Button edit_alarm_button;
    private Gtk.Button delete_alarm_button;

    private uint timeout_id;

    public AlarmView (Hourglass.Window.MainWindow window) {
        Object (window: window);
    }

    construct {
        var no_alarm_screen = new Granite.Placeholder (_("No Alarms")) {
            description = _("Click the add icon in the toolbar below to get started.")
        };

        list_box = new Gtk.ListBox ();
        list_box.set_sort_func (sort_alarm_func);
        list_box.set_placeholder (no_alarm_screen);

        var scrolled_window = new Gtk.ScrolledWindow () {
            vexpand = true,
            hexpand = true,
            child = list_box
        };

        // action buttons
        var add_alarm_button = new Gtk.Button.from_icon_name ("list-add-symbolic");
        add_alarm_button.tooltip_text = _("Add…");

        edit_alarm_button = new Gtk.Button.from_icon_name ("edit-symbolic");
        edit_alarm_button.tooltip_text = _("Edit…");

        delete_alarm_button = new Gtk.Button.from_icon_name ("list-remove-symbolic");
        delete_alarm_button.tooltip_text = _("Delete");

        var actionbar = new Gtk.ActionBar ();
        actionbar.pack_start (add_alarm_button);
        actionbar.pack_start (edit_alarm_button);
        actionbar.pack_start (delete_alarm_button);
        actionbar.add_css_class (Granite.STYLE_CLASS_FLAT);

        add_css_class (Granite.STYLE_CLASS_FRAME);
        append (scrolled_window);
        append (actionbar);

        list_box.row_selected.connect (update);

        add_alarm_button.clicked.connect (() => {
            var new_alarm_dialog = new Hourglass.Dialogs.NewAlarmDialog (window);
            new_alarm_dialog.create_alarm.connect ((alarm) => {
                append_alarm (alarm);
                list_box.select_row (alarm);
            });
            new_alarm_dialog.present ();
        });

        edit_alarm_button.clicked.connect (edit_alarm_action);

        delete_alarm_button.clicked.connect (() => {
            unowned Alarm alarm = ((Alarm) list_box.get_selected_row ());
            list_box.remove (alarm);
            try {
                daemon.alarm_manager.remove_alarm (alarm.to_string ());
            } catch (GLib.Error e) {
                error (e.message);
            }

            list_box.select_row (list_box.get_row_at_index (0));
        });

        daemon.alarm_manager.refresh_client.connect (() => {
            load_alarms ();
            debug ("Refresh");
        });

        // load previously saved alarms
        update ();
    }

    private void update () {
        if (list_box.get_row_at_index (0) == null) {
            // add small delay if daemon loads after application and list is empty
            if (Hourglass.saved.get_strv ("alarms").length != 0) {
                timeout_id = Timeout.add (500, load_alarms_source_func);
            } else {
                load_alarms ();
            }
        }

        bool has_selected_alarm = list_box.get_selected_row () != null;
        edit_alarm_button.sensitive = has_selected_alarm;
        delete_alarm_button.sensitive = has_selected_alarm;
    }

    private void load_alarms () {
        // Clear alarms
        Gtk.ListBoxRow child;
        while ((child = (Gtk.ListBoxRow) list_box.get_row_at_index (0)) != null) {
            list_box.remove (child);
        }

        foreach (string str in daemon.alarm_manager.alarm_list) {
            if (Hourglass.Utils.is_valid_alarm_string (str)) {
                append_alarm (Alarm.new_from_string (str));
            }
        }

        list_box.select_row (list_box.get_row_at_index (0));
    }

    private bool load_alarms_source_func () {
        load_alarms ();

        // remove timeout
        if (list_box.get_row_at_index (0) != null) {
            GLib.Source.remove (timeout_id);
        }

        return false;
    }

    private void append_alarm (Alarm alarm) {
        list_box.append (alarm);

        alarm.state_toggled.connect (() => {
            debug ("toggled");
            daemon.alarm_manager.toggle_alarm (alarm.to_string ());
        });

        daemon.alarm_manager.add_alarm (alarm.to_string ());

        update ();
    }

    private void edit_alarm_action () {
        var widget = list_box.get_selected_row ();
        if (widget != null) {
            var new_alarm_dialog = new Hourglass.Dialogs.NewAlarmDialog (window, (Alarm) widget);
            new_alarm_dialog.edit_alarm.connect ((old_a, new_a) => {
                list_box.remove (old_a); //  remove old alarm
                daemon.alarm_manager.remove_alarm (old_a.to_string ());

                append_alarm (new_a); // add new alarms
                list_box.select_row (new_a);
            });

            new_alarm_dialog.present ();
        }

        update ();
    }

    private int sort_alarm_func (Gtk.ListBoxRow row1, Gtk.ListBoxRow row2) {
        if (row1 is Alarm && row2 is Alarm) {
            var time1 = ((Alarm) row1).time;
            var time2 = ((Alarm) row2).time;

            return time1.compare (time2);
        } else {
            return 0;
        }
    }
}
