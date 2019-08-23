icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i + 'x' + i, 'apps', meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
endforeach

install_data(
    meson.project_name() + '.svg',
    install_dir: join_paths(get_option('datadir'), 'pixmaps')
)

css_files = ['elements', 'text']

foreach c : css_files
    install_data(
        join_paths('style', c + '.css'),
        install_dir: join_paths(get_option('datadir'), meson.project_name(), 'style')
    )
endforeach

i18n.merge_file(
    input: 'com.github.sgpthomas.hourglass.appdata.xml.in',
    output: 'com.github.sgpthomas.hourglass.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

i18n.merge_file(
    input: 'com.github.sgpthomas.hourglass.desktop.in',
    output: 'com.github.sgpthomas.hourglass.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
    input: 'com.github.sgpthomas.hourglass-daemon.desktop.in',
    output: 'com.github.sgpthomas.hourglass-daemon.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths('etc', 'xdg', 'autostart')
)
