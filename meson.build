project('com.github.sgpthomas.hourglass',
    'vala', 'c',
    version: '3.0.0',
    meson_version: '>=0.57.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

conf_data = configuration_data()
conf_data.set('EXEC_NAME', meson.project_name())
conf_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

asresources = gnome.compile_resources(
    'as-resources',
    'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

sources = files(
    'src' / 'Dialogs' / 'MultiSelectPopover.vala',
    'src' / 'Dialogs' / 'NewAlarmDialog.vala',
    'src' / 'Objects' / 'Counter.vala',
    'src' / 'Objects' / 'Region.vala',
    'src' / 'Objects' / 'RegionStore.vala',
    'src' / 'Views' / 'AbstractView.vala',
    'src' / 'Views' / 'AlarmView.vala',
    'src' / 'Views' / 'StopwatchView.vala',
    'src' / 'Views' / 'TimerView.vala',
    'src' / 'Views' / 'WorldClockView.vala',
    'src' / 'Widgets' / 'Alarm.vala',
    'src' / 'Window' / 'MainWindow.vala',
    'src' / 'Hourglass.vala',
    'src' / 'Utils.vala'
)

subdir ('src' / 'Daemon')

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
    link_args: ['-X', '-lm'],
    install: true,
)

install_data(
    'data' / meson.project_name() + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

subdir ('data')
subdir ('po')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)
