sources = [
    'config/Constants.vala',
    'controllers/ThingsController.vala',
    'lifx/LifxLampController.vala',
    'lifx/LifxLamp.vala',
    'lifx/Packet.vala',
    'lifx/Service.vala',
    'models/Lamp.vala',
    'models/Thing.vala',
    'pages/LampPage.vala',
    'pages/LoadingPage.vala',
    'services/Settings.vala',
    'types/Power.vala',
    'utils/Buffer.vala',
    'utils/Platform.vala',
    'views/ThingsView.vala',
    'views/WelcomeView.vala'
]

executable(
    meson.project_name(),
    sources + ['Application.vala', 'MainWindow.vala'],
    dependencies: [
        gtk_plus_3_dep,
        json_glib_1_dep,
        posix_dep,
        gee_dep,
        granite_dep
    ],
    install: true
)

tests = [
    'utils/Buffer'
]

foreach test_name : tests
    test_exe = executable(
        '_'.join(test_name.split('/')),
        sources + [test_name + '.test.vala'],
        dependencies: [
            gtk_plus_3_dep,
            json_glib_1_dep,
            posix_dep,
            gee_dep,
            granite_dep
        ]
    )
    test(
        '_'.join(test_name.split('/')),
        test_exe
    )
endforeach
