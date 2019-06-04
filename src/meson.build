sources = [
    'config/Constants.vala',
    'lifx/Service.vala',
    'models/Lamp.vala',
    'models/Thing.vala',
    'utils/Buffer.vala',
    'utils/Platform.vala'
]

executable(
    meson.project_name(),
    sources + ['Application.vala'],
    dependencies: [
        gtk_plus_3_dep,
        posix_dep
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
            posix_dep,
        ]
    )
    test(
        '_'.join(test_name.split('/')),
        test_exe
    )
endforeach
