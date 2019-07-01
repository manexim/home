sources = [
    'config/Constants.vala',
    'controllers/DeviceController.vala',
    'controllers/DevicesController.vala',
    'lifx/Controller.vala',
    'lifx/Lamp.vala',
    'lifx/Packet.vala',
    'lifx/Service.vala',
    'models/Device.vala',
    'models/Lamp.vala',
    'models/Hub.vala',
    'models/Thing.vala',
    'pages/HueBridgeOnboardingPage.vala',
    'pages/DevicePage.vala',
    'pages/LoadingPage.vala',
    'philips/hue/Bridge.vala',
    'philips/hue/BridgeController.vala',
    'philips/hue/Controller.vala',
    'philips/hue/Lamp.vala',
    'philips/hue/Service.vala',
    'services/Settings.vala',
    'types/Power.vala',
    'utils/Buffer.vala',
    'utils/History.vala',
    'utils/Platform.vala',
    'views/DevicesView.vala',
    'views/Overview.vala',
    'views/WelcomeView.vala',
    'widgets/Carousel.vala',
    'widgets/CarouselItem.vala',
    'widgets/Overlay.vala',
    'MainWindow.vala'
]

executable(
    meson.project_name(),
    sources + ['Application.vala'],
    dependencies: [
        gtk_plus_3_dep,
        json_glib_1_dep,
        posix_dep,
        gee_dep,
        granite_dep,
        soup_dep,
        xml_dep,
        uuid_dep
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
            granite_dep,
            soup_dep,
            xml_dep,
            uuid_dep
        ]
    )
    test(
        '_'.join(test_name.split('/')),
        test_exe
    )
endforeach
