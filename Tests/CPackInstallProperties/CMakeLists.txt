cmake_minimum_required(VERSION 3.0)

project(CPackInstallProperties)

add_executable(mytest test.cpp)

# Simple property
set_property(INSTALL foo/test.cpp PROPERTY CPACK_TEST_PROP PROP_VALUE)

# Filename with genex
set_property(INSTALL $<TARGET_FILE_NAME:mytest> PROPERTY CPACK_TEST_PROP2 PROP_VALUE2)

# Value with genex
set_property(INSTALL bar/test.cpp PROPERTY CPACK_TEST_PROP $<TARGET_FILE_NAME:mytest>)

# Multiple values
set_property(INSTALL multiple_values.txt PROPERTY CPACK_TEST_PROP value1 value2 value3)

# Append
set_property(INSTALL append.txt PROPERTY CPACK_TEST_PROP value1)
set_property(INSTALL append.txt PROPERTY CPACK_TEST_PROP value2 value3 APPEND)

# Replace
set_property(INSTALL replace.txt PROPERTY CPACK_TEST_PROP value1)
set_property(INSTALL replace.txt PROPERTY CPACK_TEST_PROP value2)

include(CPack)

file(GENERATE OUTPUT runtest_info.cmake CONTENT [[
set(EXPECTED_MYTEST_NAME "$<TARGET_FILE_NAME:mytest>")
]])

configure_file(runtest.cmake runtest.cmake COPYONLY)
