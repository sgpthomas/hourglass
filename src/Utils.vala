/*
 * Copyright 2015-2017 Hourglass Developers
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Hourglass.Utils {
    public const string ALARM_INFO_SEPARATOR = ";";

    public struct Time {
        int64 hours;
        int64 minutes;
        int64 seconds;
        int64 milliseconds;
    }

    public static Time parse_milliseconds (int64 milliseconds) {
        Time time = Time ();

        time.hours = milliseconds / (int64) TimeSpan.HOUR;
        milliseconds %= (int64) TimeSpan.HOUR;
        time.minutes = milliseconds / (int64) TimeSpan.MINUTE;
        milliseconds %= (int64) TimeSpan.MINUTE;
        time.milliseconds = milliseconds / (int64) TimeSpan.SECOND;
        milliseconds %= (int64) TimeSpan.SECOND;
        time.millimilliseconds = milliseconds % ((int64) TimeSpan.MILLISECOND / 10);

        return time;
    }

    public static string get_formatted_time (int64 milliseconds, bool with_millisecond) {
        Time time = parse_milliseconds (milliseconds);

        if (with_millisecond) {
            if (time.hours == 0) {
                return "%02llu:%02llu:%02llu".printf (time.minutes, time.seconds, time.milliseconds);
            }

            return "%02llu:%02llu:%02llu:%02llu".printf (time.hours, time.minutes, time.seconds, time.milliseconds);
        } else {
            if (time.hours == 0) {
                return "%02llu:%02llu".printf (time.minutes, time.seconds);
            }

            return "%02llu:%02llu:%02llu".printf (time.hours, time.minutes, time.seconds);
        }
    }

    public static bool is_valid_alarm_string (string alarm_string) {
        if (ALARM_INFO_SEPARATOR in alarm_string) {
            string[] parts = alarm_string.split (ALARM_INFO_SEPARATOR);
            if (parts.length != 6) {
                return false; //if wrong number of sections return false
            }

            //check if time section is correct
            var time_string_parts = parts[1].split (",");
            foreach (string s in time_string_parts) {
                int64 i = 0;
                if (!int64.try_parse (s, out i)) {
                    return false;
                }
            }

            //check if date section is correct
            if (parts[2] != "none") {
                var date_string_parts = parts[2].split ("-");
                foreach (string s in date_string_parts) {
                    int64 i = 0;
                    if (!int64.try_parse (s, out i)) {
                        return false;
                    }
                }
            }

            //check if repeat days is correct
            if (parts[3] != "none") {
                var repeat_string_parts = parts[3].split (",");
                foreach (string s in repeat_string_parts) {
                    int64 i = 0;
                    if (!int64.try_parse (s, out i)) {
                        return false;
                    }
                }
            }

            //check state
            if (!(parts[4] in "on off")) {
                return false;
            }

            return true;
        } else {
            return false;
        }
    }
}
