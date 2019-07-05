icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )

    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

symbolic_icons = [
    'com.github.manexim.home.icon.bridge.philips.hue-symbolic',
    'com.github.manexim.home.icon.fan-symbolic',
    'com.github.manexim.home.icon.lamp0-symbolic',
    'com.github.manexim.home.icon.lamp1-symbolic',
    'com.github.manexim.home.icon.lamp2-symbolic',
    'com.github.manexim.home.icon.lamp3-symbolic',
    'com.github.manexim.home.icon.lamp4-symbolic',
    'com.github.manexim.home.icon.lightbulb-symbolic',
    'com.github.manexim.home.icon.lightbulb.lifx-symbolic',
    'com.github.manexim.home.icon.lightbulb.philips.hue-symbolic',
    'com.github.manexim.home.icon.television-symbolic',
    'com.github.manexim.home.icon.thing-symbolic',
    'com.github.manexim.home.icon.spot-symbolic',
    'com.github.manexim.home.logo.lifx-symbolic',
    'com.github.manexim.home.logo.philips.hue-symbolic'
]

foreach icon : symbolic_icons
    install_data(
        join_paths('icons', 'symbolic', icon + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps')
    )
endforeach

i18n.merge_file(
    input: meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

asresources = gnome.compile_resources(
    'as-resources', meson.project_name() + '.gresource.xml',
    source_dir: '.',
    c_name: 'as'
)
