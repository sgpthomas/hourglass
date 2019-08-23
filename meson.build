project('hourglass', 'vala', 'c', version: '1.1.1')

i18n = import('i18n')
add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

executable(
    meson.project_name(),
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
