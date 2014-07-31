set(DUMMY_OUT ${RunCMake_TEST_BINARY_DIR}/dummy.out)

if(NOT EXISTS ${DUMMY_OUT})
  message(FATAL_ERROR "dummy.out should have been generated [${CMAKE_CURRENT_BINARY_DIR}]")
endif()

file(REMOVE ${DUMMY_OUT})

if(EXISTS ${DUMMY_OUT})
  message(FATAL_ERROR "dummy.out should have been removed")
endif()

execute_process(COMMAND ${CMAKE_COMMAND} --build ${RunCMake_TEST_BINARY_DIR}
  RESULT_VARIABLE RESULT
  ERROR_VARIABLE ERROR
)

if(NOT RESULT STREQUAL "0")
  message(FATAL_ERROR
    "implicitly rerunning cmake failed [${RESULT}] [${ERROR}]")
endif()

if(NOT EXISTS ${DUMMY_OUT})
  message(FATAL_ERROR "dummy.out should have been re-generated")
endif()
