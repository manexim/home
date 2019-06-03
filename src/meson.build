sources = [
    'config/Constants.vala',
    'lifx/Service.vala'
]

executable(
    meson.project_name(),
    sources + ['Application.vala'],
    dependencies: [
        gtk_plus_3_dep
    ],
    install: true
)

tests = []

foreach test_name : tests
    test_exe = executable(
        '_'.join(test_name.split('/')),
        sources + [test_name + '.test.vala'],
        dependencies: [
            gtk_plus_3_dep,
            json_glib_1_dep,
            posix_dep,
            gee_dep
        ]
    )
    test(
        '_'.join(test_name.split('/')),
        test_exe
    )
endforeach
