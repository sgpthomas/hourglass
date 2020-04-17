project('com.github.sgpthomas.hourglass', 'vala', 'c', version: '1.1.1')

i18n = import('i18n')
add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

conf_data = configuration_data()
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set('DAEMON_EXEC_NAME', meson.project_name() + '-daemon')
conf_data.set('DAEMON_NAME', meson.project_name() + '-daemon')
conf_data.set('ICON_NAME', meson.project_name())
conf_data.set('APP_NAME', 'Hourglass')
conf_data.set('GENERIC_NAME', 'Timer')
conf_data.set('RELEASE_NAME', 'Loki')
conf_data.set('COMMENT', 'This clock application provides stopwatches, alarms, and timers.')
conf_data.set('DAEMON_COMMENT', 'Daemon that deals with Hourglass\'s alarms.')
conf_data.set('VERSION', meson.project_version())
conf_data.set('VERSION_INFO', 'Release')

conf_data.set('DATADIR', get_option('datadir'))
conf_data.set('PKG_DATADIR', join_paths(get_option('datadir'), meson.project_name()))
conf_data.set('INSTALL_PREFIX', get_option('prefix'))

config_file = configure_file(
    input: join_paths('src', 'Config.vala.in'),
    output: 'Config.vala',
    configuration: conf_data
)

executable(
    meson.project_name(),
    config_file,
    'src/Dialogs/MultiSelectPopover.vala',
    'src/Dialogs/NewAlarmDialog.vala',
    'src/Services/DBusManager.vala',
    'src/Services/Settings.vala',
    'src/Services/StyleManager.vala',
    'src/Widgets/Alarm.vala',
    'src/Widgets/AlarmTimeWidget.vala',
    'src/Widgets/Counter.vala',
    'src/Widgets/Spacer.vala',
    'src/Widgets/StopwatchTimeWidget.vala',
    'src/Widgets/TimeSpinner.vala',
    'src/Widgets/TimeWidget.vala',
    'src/Widgets/TimerTimeWidget.vala',
    'src/Window/MainWindow.vala',
    'src/Hourglass.vala',
    dependencies: [
        dependency('gtk+-3.0', version: '>= 3.18'),
        dependency('gee-0.8'),
        dependency('granite'),
    ],
    install: true,
)

install_data(
    'schemas/com.github.sgpthomas.hourglass.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

subdir ('data')
subdir ('po')
subdir ('src/Daemon')

meson.add_install_script('meson/post_install.py')
