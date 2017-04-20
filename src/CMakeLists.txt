#define app source files
set (APP_SOURCES
    Hourglass.vala
    Config.vala
)

#define app source files : dialogs
set (APP_SOURCES ${APP_SOURCES}
    Dialogs/MultiSelectPopover.vala
    Dialogs/NewAlarmDialog.vala
)

#define app source files : services
set (APP_SOURCES ${APP_SOURCES}
    Services/DBusManager.vala
    Services/Settings.vala
    Services/StyleManager.vala
)

#define app source files : widgets
set (APP_SOURCES ${APP_SOURCES}
    Widgets/Alarm.vala
    Widgets/AlarmTimeWidget.vala
    Widgets/Counter.vala
    Widgets/Spacer.vala
    Widgets/StopwatchTimeWidget.vala
    Widgets/TimerTimeWidget.vala
    Widgets/TimeSpinner.vala
    Widgets/TimeWidget.vala
)

#define app source files : window
set (APP_SOURCES ${APP_SOURCES}
    Window/MainWindow.vala
)

#compiling sources
vala_precompile (VALA_C ${EXEC_NAME}
    ${APP_SOURCES}

#packages to compile with hourglass
PACKAGES
    ${SOURCE_DEPS}
)

#automatically generate .pot template files
set (_pot_file ${CMAKE_SOURCE_DIR}/po/${PROJECT_NAME}.pot)
add_custom_command (OUTPUT ${_pot_file}
    COMMAND xgettext --output=${_pot_file} ${APP_SOURCES}
    DEPENDS ${APP_SOURCES}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Extract translatable messages to ${_pot_file}")
add_custom_target (pot_file ALL DEPENDS ${_pot_file})

#make executable
add_executable(${EXEC_NAME} ${VALA_C})

#install binaries
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
