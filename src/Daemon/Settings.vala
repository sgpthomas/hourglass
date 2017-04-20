/* Copyright 2015 Sam Thomas
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

    public class SavedAlarms : Granite.Services.Settings {

        public string[] alarms {get; set;}

        public SavedAlarms () {
            base ("org.pantheon.hourglass.saved");
        }
    }

    public class Settings : Granite.Services.Settings {

        public int update_frequency {get; set;}
        public string sound {get; set;}

        public Settings () {
            base ("org.pantheon.hourglass.settings");
        }
    }
}
