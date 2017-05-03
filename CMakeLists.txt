# project name
project (hourglass)
enable_testing ()

#cmake version and stuff
cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

#some variables
set (GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
set (EXEC_NAME ${CMAKE_PROJECT_NAME})
set (DAEMON_EXEC_NAME ${CMAKE_PROJECT_NAME}-daemon)
set (DAEMON_NAME ${CMAKE_PROJECT_NAME}-daemon)
set (ICON_NAME ${CMAKE_PROJECT_NAME})
set (APP_NAME "Hourglass")
set (GENERIC_NAME "Timer")
set (RELEASE_NAME "Loki")
set (COMMENT "This clock application provides stopwatches, alarms, and timers.")
set (DAEMON_COMMENT "Daemon that deals with Hourglass's alarms.")
set (VERSION "1.0.7")
set (VERSION_INFO "Release")

#data directory stuff
include (GNUInstallDirs)
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DATADIR ${CMAKE_INSTALL_PREFIX}/share)
set (PKG_DATADIR ${DATADIR}/${CMAKE_PROJECT_NAME})
set (DOLLAR "$")  

# Add 'make dist' command for creating release tarball
set (CPACK_PACKAGE_VERSION ${VERSION})
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set (CPACK_SOURCE_IGNORE_FILES "/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")

include (CPack)
add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

#uninstall command / target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

#dependency variable
set (SOURCE_DEPS
     gtk+-3.0
     gee-0.8
     granite
)

set (DAEMON_DEPS
    glib-2.0
    gio-2.0
    granite
    libnotify
    libcanberra
)

#configuration file
configure_file (${CMAKE_SOURCE_DIR}/src/Config.vala.cmake ${CMAKE_SOURCE_DIR}/src/Config.vala)
configure_file (${CMAKE_SOURCE_DIR}/data/com.github.sgpthomas.hourglass.desktop.in ${CMAKE_SOURCE_DIR}/data/com.github.sgpthomas.hourglass.desktop)
configure_file (${CMAKE_SOURCE_DIR}/data/com.github.sgpthomas.hourglass-daemon.desktop.in ${CMAKE_SOURCE_DIR}/data/com.github.sgpthomas.hourglass-daemon.desktop)

#some definitions
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
add_definitions(-DVALA_VERSION="${VALA_SHORTVER}")
add_definitions(-w) # Disable gcc warnings

#find vala
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.28" MINIMUM)
include (ValaPrecompile)

#check for dependencies
find_package (PkgConfig)
pkg_check_modules (GTK+ REQUIRED
  gtk+-3.0>=3.18)
    
pkg_check_modules (DEPS REQUIRED ${SOURCE_DEPS})
pkg_check_modules (DEPS REQUIRED ${DAEMON_DEPS})

#needed to compile properly on launchpad
pkg_check_modules (LIBSOURCE REQUIRED
  libnotify
  libcanberra
)

#some other necessary things
set(NORMAL_CFLAGS ${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
set(NORMAL_LINK_DIRS ${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})
set(NORMAL_LIBRARIES ${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})

add_definitions (${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
link_libraries (${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})

#include source path
include_directories(${CMAKE_BINARY_DIR}/src)

#add subdirectories
add_subdirectory (src)
add_subdirectory (src/Daemon)
add_subdirectory (schemas)
add_subdirectory (po)
add_subdirectory (data)
