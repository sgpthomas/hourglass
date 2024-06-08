conf_data = configuration_data()
conf_data.set_quoted('EXEC_NAME', meson.project_name())
conf_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

sources = files(
    'Dialogs/MultiSelectPopover.vala',
    'Dialogs/NewAlarmDialog.vala',
    'Objects/Counter.vala',
    'Views/AbstractView.vala',
    'Views/AlarmView.vala',
    'Views/StopwatchView.vala',
    'Views/TimerView.vala',
    'Widgets/Alarm.vala',
    'Window/MainWindow.vala',
    'Hourglass.vala',
    'Utils.vala'
)

subdir('Daemon')

executable(
    meson.project_name(),
    config_file,
    asresources,
    sources,
    daemon_files,
    dependencies: [
        dependency('gtk4'),
        dependency('gee-0.8'),
        dependency('granite-7', version: '>= 7.1.0'),
        dependency('libportal'),
        dependency('libportal-gtk4'),
    ],
    install: true,
)
