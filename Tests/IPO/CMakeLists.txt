cmake_minimum_required (VERSION 2.8)
project(IPO C)

message("======== IPO specific variables ======")
get_cmake_property(variables VARIABLES)
foreach(variable ${variables})
  if("${variable}xxx" MATCHES "_IPOxxx")
    message("${variable}: [${${variable}}]")
  endif()
endforeach()

set_property(DIRECTORY PROPERTY INTERPROCEDURAL_OPTIMIZATION 1)

add_subdirectory(../COnly COnly)
add_subdirectory(../CxxOnly CxxOnly)
