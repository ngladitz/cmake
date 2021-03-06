cmake_minimum_required(VERSION 3.0.0)
project(WriteCompilerDetectionHeader)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

include(WriteCompilerDetectionHeader)

get_property(cxx_known_features GLOBAL PROPERTY CMAKE_CXX_KNOWN_FEATURES)

write_compiler_detection_header(
  FILE "${CMAKE_CURRENT_BINARY_DIR}/test_compiler_detection.h"
  PREFIX TEST
  COMPILERS GNU
  VERSION 3.1
  PROLOG "// something"
  EPILOG "// more"
  FEATURES
    ${cxx_known_features}
)

if (NOT CMAKE_CXX_COMPILE_FEATURES)
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp"
    "int main(int,char**) { return 0; }\n"
  )
  add_executable(WriteCompilerDetectionHeader "${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp")

  include(CheckCXXSourceCompiles)
  check_cxx_source_compiles("#include \"${CMAKE_CURRENT_BINARY_DIR}/test_compiler_detection.h\"\nint main() { return 0; }\n"
    file_include_works
  )
  if (file_include_works)
    message(SEND_ERROR "Inclusion of ${CMAKE_CURRENT_BINARY_DIR}/test_compiler_detection.h was expected to cause an error, but did not.")
  endif()
  return()
endif()

macro(set_defines target true_defs false_defs)
  set(defines)
  foreach(def ${true_defs})
    list(APPEND defines ${def}=1)
  endforeach()
  foreach(def ${false_defs})
    list(APPEND defines ${def}=0)
  endforeach()
  target_compile_definitions(${target}
    PRIVATE
      ${defines}
  )
endmacro()

if (CMAKE_CXX_COMPILER_ID STREQUAL GNU)
  # False for C++98 mode.
  list(APPEND false_defs EXPECTED_COMPILER_CXX_DELEGATING_CONSTRUCTORS)
  list(APPEND false_defs EXPECTED_COMPILER_CXX_VARIADIC_TEMPLATES)
endif()

add_executable(WriteCompilerDetectionHeader main.cpp)
set_property(TARGET WriteCompilerDetectionHeader PROPERTY CXX_STANDARD 98)
set_defines(WriteCompilerDetectionHeader "${true_defs}" "${false_defs}")

if(MSVC)
  return() # MSVC has only one mode.
endif()

# Since GNU 4.7
if (";${CMAKE_CXX_COMPILE_FEATURES};" MATCHES ";cxx_delegating_constructors;")
  list(APPEND true_defs EXPECTED_COMPILER_CXX_DELEGATING_CONSTRUCTORS)
  list(REMOVE_ITEM false_defs EXPECTED_COMPILER_CXX_DELEGATING_CONSTRUCTORS)
endif()

# Since GNU 4.4
if (";${CMAKE_CXX_COMPILE_FEATURES};" MATCHES ";cxx_variadic_templates;")
  list(APPEND true_defs EXPECTED_COMPILER_CXX_VARIADIC_TEMPLATES)
  list(REMOVE_ITEM false_defs EXPECTED_COMPILER_CXX_VARIADIC_TEMPLATES)
endif()

add_executable(WriteCompilerDetectionHeader_11 main.cpp)
set_property(TARGET WriteCompilerDetectionHeader_11 PROPERTY CXX_STANDARD 11)
set_defines(WriteCompilerDetectionHeader_11 "${true_defs}" "${false_defs}")
