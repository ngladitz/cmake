include(CPackProperties.cmake)

function(test_property FILE NAME EXPECTED_VALUE)
  get_property(ACTUAL_VALUE INSTALL "${FILE}" PROPERTY "${NAME}")

  if(NOT "${ACTUAL_VALUE}" STREQUAL "${EXPECTED_VALUE}")
    message(FATAL_ERROR "${NAME}@${FILE}: property mismatch expected [${EXPECTED_VALUE}] actual [${ACTUAL_VALUE}]")
  endif()
endfunction()

test_property("foo/test.cpp" CPACK_TEST_PROP PROP_VALUE)
