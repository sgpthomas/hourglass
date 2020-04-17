icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i + 'x' + i, 'apps', 'hourglass.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
endforeach

install_data(
    'hourglass.svg',
    install_dir: join_paths(get_option('datadir'), 'pixmaps')
)

css_files = ['elements', 'text']

foreach c : css_files
    install_data(
        join_paths('style', c + '.css'),
        install_dir: join_paths(get_option('datadir'), gettext_name, 'style')
    )
endforeach

i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

desktop_in = configure_file(
    input: meson.project_name() + '.desktop.in.in',
    output: meson.project_name() + '.desktop.in',
    configuration: conf_data
)

i18n.merge_file(
    input: desktop_in,
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

daemon_desktop_in = configure_file(
    input: meson.project_name() + '-daemon.desktop.in.in',
    output: meson.project_name() + '-daemon.desktop.in',
    configuration: conf_data
)

i18n.merge_file(
    input: daemon_desktop_in,
    output: meson.project_name() + '-daemon.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)
