project('com.github.manexim.home', 'vala', 'c')

gtk_plus_3_dep = dependency('gtk+-3.0')
json_glib_1_dep = dependency('json-glib-1.0')
posix_dep = meson.get_compiler('vala').find_library('posix')
gee_dep = dependency('gee-0.8')
granite_dep = dependency('granite')

subdir('data')
subdir('src')
