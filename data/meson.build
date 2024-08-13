icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'icons' / i + 'x' + i / 'apps' / meson.project_name() + '.png',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps'
    )
endforeach

install_data(
    'icons' / 'scalable' / 'apps' / meson.project_name() + '.svg',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
)

appstream_conf = configuration_data()
appstream_conf.set('VERSION', meson.project_version())
appstream_file_in = configure_file(
    input: meson.project_name() + '.metainfo.xml.in.in',
    output: meson.project_name() + '.metainfo.xml.in',
    configuration: appstream_conf
)

appstream_file = i18n.merge_file(
    input: appstream_file_in,
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

desktop_conf = configuration_data()
desktop_conf.set('EXEC_NAME', meson.project_name())
desktop_file_in = configure_file(
    input: meson.project_name() + '.desktop.in.in',
    output: meson.project_name() + '.desktop.in',
    configuration: desktop_conf
)

i18n.merge_file(
    input: desktop_file_in,
    output: meson.project_name() + '.desktop',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

asresources = gnome.compile_resources(
    'as-resources',
    meson.project_name() + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)
