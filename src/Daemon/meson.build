utils_file = files(
    meson.source_root() / 'src' / 'Utils.vala',
    'AlarmManager.vala',
    'HourglassDaemon.vala',
    'HourglassServer.vala',
    'NotificationManager.vala'
)

executable(
    meson.project_name() + '-daemon',
    config_file,
    utils_file,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('granite'),
    ],
    install: true,
)
