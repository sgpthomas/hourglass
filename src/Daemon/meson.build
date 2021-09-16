daemon_files = files(
    meson.source_root() / 'src' / 'Utils.vala',
    'AlarmManager.vala',
    'HourglassDaemon.vala',
    'HourglassServer.vala',
    'NotificationManager.vala'
)

executable(
    meson.project_name() + '-daemon',
    config_file,
    daemon_files,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('granite'),
    ],
    install: true,
)
