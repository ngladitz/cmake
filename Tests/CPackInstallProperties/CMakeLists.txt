cmake_minimum_required(VERSION 3.0)

project(CPackInstallProperties)

add_executable(mytest test.cpp)

set_property(INSTALL foo/test.cpp PROPERTY CPACK_TEST_PROP PROP_VALUE)

include(CPack)

configure_file(runtest.cmake runtest.cmake COPYONLY)
