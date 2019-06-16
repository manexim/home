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
    'com.github.manexim.home.lightbulb-symbolic',
    'com.github.manexim.home.lightbulb.lifx-symbolic',
    'com.github.manexim.home.logo.lifx-symbolic',
    'com.github.manexim.home.logo.philips.hue-symbolic'
]

foreach icon : symbolic_icons
    install_data(
        join_paths('icons', 'symbolic', icon + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps')
    )
endforeach

install_data(
    meson.project_name() + '.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications')
)

install_data(
    meson.project_name() + '.appdata.xml',
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)


install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)
