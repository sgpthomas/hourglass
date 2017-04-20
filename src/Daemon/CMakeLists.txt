#define daemon source files
set (DAEMON_SOURCES
    AlarmManager.vala
    HourglassDaemon.vala
    HourglassServer.vala
    NotificationManager.vala
    Settings.vala
)

#compiling sources
vala_precompile (VALA_C ${DAEMON_EXEC_NAME}
    ${DAEMON_SOURCES}

#packages to compile with hourglass
PACKAGES
    ${DAEMON_DEPS}
)

#make executable
add_executable(${DAEMON_NAME} ${VALA_C})

#install binaries
install (TARGETS ${DAEMON_NAME} RUNTIME DESTINATION bin)    
