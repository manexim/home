config_data = configuration_data()
config_data.set('APP_ID', meson.project_name())
config_data.set('APP_VERSION', meson.project_version())
config_data.set('GETTEXT_PACKAGE', meson.project_name())
config_data.set('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))

config_file = configure_file(
    input: 'Constants.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

sources = [
    'colors/HSB.vala',
    'colors/RGB.vala',
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
    'onboarding/AbstractOnboardingView.vala',
    'onboarding/FinishView.vala',
    'onboarding/LIFXView.vala',
    'onboarding/PhilipsHueView.vala',
    'onboarding/StartView.vala',
    'pages/AbstractDevicePage.vala',
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
    'views/OnboardingView.vala',
    'views/Overview.vala',
    'widgets/Carousel.vala',
    'widgets/CarouselItem.vala',
    'widgets/ColorPicker.vala',
    'widgets/IconPopover.vala',
    'widgets/Overlay.vala',
    'Flux/Actions.vala',
    'Flux/ActionType.vala',
    'Flux/HueMiddleware.vala',
    'Flux/LifxMiddleware.vala',
    'Flux/LoggingMiddleware.vala',
    'Flux/Payloads.vala',
    'Flux/Store.vala',
    'MainWindow.vala',
    config_file,
]

executable(
    meson.project_name(),
    sources + ['Application.vala'],
    asresources,
    dependencies: [
        gtk_plus_3_dep,
        json_glib_1_dep,
        libhandy_dep,
        posix_dep,
        gee_dep,
        granite_dep,
        soup_dep,
        xml_dep,
        uuid_dep,
        flux_dep,
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
            libhandy_dep,
            posix_dep,
            gee_dep,
            granite_dep,
            soup_dep,
            xml_dep,
            uuid_dep,
            flux_dep,
        ]
    )
    test(
        '_'.join(test_name.split('/')),
        test_exe
    )
endforeach
