include(runtest_info.cmake)

function(test_property FILE NAME EXPECTED_VALUE)
  get_property(ACTUAL_VALUE INSTALL "${FILE}" PROPERTY "${NAME}")

  if(NOT "${ACTUAL_VALUE}" STREQUAL "${EXPECTED_VALUE}")
    message(FATAL_ERROR "${NAME}@${FILE}: property mismatch expected [${EXPECTED_VALUE}] actual [${ACTUAL_VALUE}]")
  endif()
endfunction()

include(CPackProperties.cmake)

test_property("foo/test.cpp" CPACK_TEST_PROP PROP_VALUE)
test_property(${EXPECTED_MYTEST_NAME} CPACK_TEST_PROP2 PROP_VALUE2)
test_property("bar/test.cpp" CPACK_TEST_PROP ${EXPECTED_MYTEST_NAME})
test_property("multiple_values.txt" CPACK_TEST_PROP "value1;value2;value3")
test_property("append.txt" CPACK_TEST_PROP "value1;value2;value3")
test_property("replace.txt" CPACK_TEST_PROP "value2")
