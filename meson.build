project('com.github.manexim.home', 'vala', 'c')

add_project_arguments(
    ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
    language: 'vala'
)

gtk_plus_3_dep = dependency('gtk+-3.0')
json_glib_1_dep = dependency('json-glib-1.0')
posix_dep = meson.get_compiler('vala').find_library('posix')
gee_dep = dependency('gee-0.8')
granite_dep = dependency('granite')
soup_dep = dependency('libsoup-2.4')
xml_dep = dependency('libxml-2.0')
uuid_dep = dependency('uuid')

subdir('data')
subdir('src')

meson.add_install_script('meson/post_install.py')
