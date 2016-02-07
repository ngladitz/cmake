if(MSVC AND NOT "$ENV{WIX}" STREQUAL "")
  add_subdirectory(CustomAction)
endif()

if(CMAKE_BUILD_TYPE)
    set(CUSTOM_ACTION_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/custom_action_dll.wxs")
else()
    set(CUSTOM_ACTION_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/custom_action_dll-$<CONFIG>.wxs")
endif()

file(GENERATE
  OUTPUT "${CUSTOM_ACTION_OUTPUT}"
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/custom_action_dll.wxs.in"
)
