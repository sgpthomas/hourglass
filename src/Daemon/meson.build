executable(
    meson.project_name() + '-daemon',
    'AlarmManager.vala',
    'HourglassDaemon.vala',
    'HourglassServer.vala',
    'NotificationManager.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('granite'),
        dependency('libnotify'),
        dependency('libcanberra'),
    ],
    install: true,
)
