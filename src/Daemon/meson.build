executable(
    meson.project_name() + '-daemon',
    config_file,
    meson.source_root() + '/src/Utils.vala',
    'AlarmManager.vala',
    'HourglassDaemon.vala',
    'HourglassServer.vala',
    'NotificationManager.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('granite'),
    ],
    install: true,
)
