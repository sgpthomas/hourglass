/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Ryo Nakano
 */

public class Hourglass.Objects.Region : GLib.Object {
    public GLib.TimeZone? tz { get; private set; }
    public string name { get; construct; }

    public Region (string id, string name) {
        Object (
            name: name
        );
        tz = get_tz_from_id (id);
    }

    private GLib.TimeZone? get_tz_from_id (string id) {
        GLib.TimeZone? tz = null;

        try {
            tz = new TimeZone.identifier (id);
        } catch (Error e) {
            warning (e.message);
        }

        return tz;
    }
}
