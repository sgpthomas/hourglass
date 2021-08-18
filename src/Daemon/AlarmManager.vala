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

namespace HourglassDaemon {
    public class AlarmManager {
        public Gee.ArrayList<string> alarm_list { get; private set; }

        public AlarmManager () {
            debug ("Initiating Alarm Manager");
            alarm_list = new Gee.ArrayList<string> ();

            load_alarm_list (); //load alarm list
        }

        public void check_alarm () {
            debug ("Checking alarms");

            //loop through alarm list
            foreach (string alarm in alarm_list) {
                //if alarm is now and is on, set it off and then disable it
                if (is_alarm_string_now (alarm) && get_alarm_state (alarm)) {
                    notification.show (get_alarm_name (alarm), get_alarm_time (alarm), "alarm");

                    if (!get_alarm_repeat (alarm)) {
                        toggle_alarm (alarm);
                        server.server.should_refresh_client ();
                    }
                }
            }
        }

        public void add_alarm (string alarm_string) {
            if (alarm_list.contains (alarm_string)) {
                return; //return if alarm is already in array
            }

            if (!Utils.is_valid_alarm_string (alarm_string)) {
                return; //don't add string if string is not valid
            }

            //add alarm to list
            alarm_list.add (alarm_string);

            //save alarm
            save_alarm_list ();
        }

        public void remove_alarm (string alarm_string) {
            if (alarm_string in alarm_list) { //if alarm string is in alarm list, remove alarm-string
                alarm_list.remove (alarm_string);

                //reload list
                save_alarm_list ();
            }
        }

        public void load_alarm_list () {
            alarm_list = new Gee.ArrayList<string> (); //empty alarm list
            foreach (string s in HourglassDaemon.saved_alarms.get_strv ("alarms")) { //loop through all entries in schema
                if (Utils.is_valid_alarm_string (s)) { //check for validity
                    alarm_list.add (s); //add to alarm list
                }
            }
        }

        public void save_alarm_list () {
            string[] new_alarm_list = {};
            foreach (string s in alarm_list) { //loop through all entries in alarm list
                new_alarm_list += s;
            }

            HourglassDaemon.saved_alarms.set_strv ("alarms", new_alarm_list); //update alarms gsettings entry
        }

        public string get_alarm_name (string alarm_string) {
            string[] parts = alarm_string.split (Utils.ALARM_INFO_SEPARATOR);
            return parts[0];
        }

        public string get_alarm_time (string alarm_string) {
            string[] parts = alarm_string.split (Utils.ALARM_INFO_SEPARATOR);
            string[] time = parts[1].split (",");

            string hour = time[0];
            string min = time[1];

            //hour part
            if (int.parse (hour) < 10) {
                hour = "0%s".printf (hour);
            }

            //min part
            if (int.parse (min) < 10) {
                min = "0%s".printf (min);
            }

            return "%s:%s".printf (hour, min);
        }

        public bool get_alarm_state (string alarm_string) {
            string[] parts = alarm_string.split (Utils.ALARM_INFO_SEPARATOR);
            if (parts[4] == "on") {
                return true;
            } else {
                return false;
            }
        }

        public bool get_alarm_repeat (string alarm_string) {
            string[] parts = alarm_string.split (Utils.ALARM_INFO_SEPARATOR); //split alarm string

            if (parts[3] == "none") {
                return false;
            }

            return true;
        }

        public void toggle_alarm (string input) {
            //find index of given item if it exists
            var index = alarm_list.index_of (input);

            if (index != -1) {
                //modify string
                var str = alarm_list[index];
                if (";on;" in str) {
                    str = str.replace (";on;", ";off;");
                } else if (";off;" in str) {
                    str = str.replace (";off;", ";on;");
                }

                //modify array with new string
                alarm_list[index] = str;

                //save new alarm list
                save_alarm_list ();
            } else { //if index == -1, try switching input

                //switch input
                var str = input;
                if (";on;" in str) {
                    str = str.replace (";on;", ";off;");
                } else if (";off;" in str) {
                    str = str.replace (";off;", ";on;");
                }

                //check if exists in alarm list, if exists, call self
                index = alarm_list.index_of (str);
                if (index != -1) {
                    toggle_alarm (str);
                }
            }
        }

        public bool is_alarm_string_now (string alarm_string) {
            var now = new DateTime.now_local (); //current time
            string[] parts = alarm_string.split (Utils.ALARM_INFO_SEPARATOR);

            //time
            string[] time_parts = parts[1].split (",");
            var alarm_hour = int.parse (time_parts[0]);
            var alarm_min = int.parse (time_parts[1]);

            //date
            string[] date_parts = parts[2].split ("-");
            var alarm_month = int.parse (date_parts[0]);
            var alarm_day = int.parse (date_parts[1]);
            var alarm_year = int.parse (date_parts[2]);

            //create booleans that checks same date and time
            bool same_month = alarm_month == now.get_month ();
            bool same_day = alarm_day == now.get_day_of_month ();
            bool same_year = alarm_year == now.get_year ();
            bool same_hour = alarm_hour == now.get_hour ();
            bool same_min = alarm_min == now.get_minute ();

            if (same_hour && same_min) {
                //if today, alarm goes off
                if (same_day && same_month && same_year) {
                    return true;
                }

                //if today is one of the repeat days, we want the alarm to go off
                int today = now.get_day_of_week () != 7 ? now.get_day_of_week () : 0;
                foreach (string s in parts[3].split (",")) {
                    if (int.parse (s) == today) {
                        return true;
                    }
                }
            }

            return false;
        }
    }
}
