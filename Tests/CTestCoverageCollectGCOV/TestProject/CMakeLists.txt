cmake_minimum_required(VERSION 3.2)

project(TestProject CXX)

include(CTest)

add_executable(myexecutable
  main.cpp
  3rdparty/foo.cpp
  extra/extra.cpp
)

set_property(SOURCE main.cpp APPEND PROPERTY LABELS SourceLabel)
set_property(TARGET myexecutable APPEND PROPERTY LABELS TargetLabel)

add_custom_command(TARGET myexecutable
  POST_BUILD
  COMMAND ${CMAKE_COMMAND} -
    -DTARGET=myexecutable
    "-DSOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}"
    "-DSOURCES=$<TARGET_PROPERTY:myexecutable,SOURCES>"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/fake_compile_time_gcno.cmake"
  VERBATIM
)

add_test(NAME mytest
  COMMAND ${CMAKE_COMMAND}
    "-DMYEXECUTABLE=$<TARGET_FILE:myexecutable>"
    "-DTARGETDIR=${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/myexecutable.dir"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/fake_run_time_gcda.cmake"
)

set_property(TEST mytest APPEND PROPERTY LABELS TestLabel)
