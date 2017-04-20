#install files needed for hourglass
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/hourglass.desktop DESTINATION ${DATADIR}/applications)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/hourglass-daemon.desktop DESTINATION /etc/xdg/autostart)
install (DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/style/ DESTINATION ${PKG_DATADIR}/style)
install (DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/icons/ DESTINATION ${DATADIR}/icons/hicolor)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/hourglass.svg DESTINATION ${DATADIR}/pixmaps)
