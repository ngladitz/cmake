
cmake_minimum_required(VERSION 3.0)

project(CompileFeatures)

if (NOT CMAKE_CXX_COMPILE_FEATURES)
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp"
    "int main(int,char**) { return 0; }\n"
  )
  add_executable(CompileFeatures "${CMAKE_CURRENT_BINARY_DIR}/dummy.cpp")
  return()
endif()

macro(run_test feature lang)
  if (";${CMAKE_${lang}_COMPILE_FEATURES};" MATCHES ${feature})
    add_library(test_${feature} OBJECT ${feature})
    set_property(TARGET test_${feature}
      PROPERTY COMPILE_FEATURES "${feature}"
    )
  else()
    list(APPEND ${lang}_non_features ${feature})
  endif()
endmacro()

get_property(cxx_features GLOBAL PROPERTY CMAKE_CXX_KNOWN_FEATURES)
foreach(feature ${cxx_features})
  run_test(${feature} CXX)
endforeach()

if (CMAKE_CXX_COMPILER_ID STREQUAL GNU
    AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
  list(REMOVE_ITEM CXX_non_features
    cxx_alignof
  )
endif()

set(CXX_ext cpp)
set(CXX_standard_flag 11)
foreach(lang CXX)
  if (CMAKE_${lang}_COMPILE_FEATURES)
    foreach(feature ${${lang}_non_features})
      message("Testing feature : ${feature}")
      try_compile(${feature}_works
        "${CMAKE_CURRENT_BINARY_DIR}/${feature}_test"
        "${CMAKE_CURRENT_SOURCE_DIR}/feature_test.${${lang}_ext}"
        COMPILE_DEFINITIONS "-DTEST=${CMAKE_CURRENT_SOURCE_DIR}/${feature}.${${lang}_ext}"
        CMAKE_FLAGS "-DCMAKE_${lang}_STANDARD=${${lang}_standard_flag}"
        OUTPUT_VARIABLE OUTPUT
      )
      if (${feature}_works)
        message(SEND_ERROR
          "Feature ${feature} expected not to work for ${lang} ${CMAKE_${lang}_COMPILER_ID}-${CMAKE_${lang}_COMPILER_VERSION}.
  Update the supported features or blacklist it.\n${OUTPUT}")
      else()
        message("Testing feature : ${feature} -- Fails, as expected.")
      endif()
    endforeach()
  endif()
endforeach()

add_executable(CompileFeatures main.cpp)
set_property(TARGET CompileFeatures
  PROPERTY COMPILE_FEATURES "cxx_auto_type"
)
set_property(TARGET CompileFeatures
  PROPERTY CXX_STANDARD_REQUIRED TRUE
)

add_executable(GenexCompileFeatures main.cpp)
set_property(TARGET GenexCompileFeatures
  PROPERTY COMPILE_FEATURES "$<1:cxx_auto_type>;$<0:not_a_feature>"
)

add_library(iface INTERFACE)
set_property(TARGET iface
  PROPERTY INTERFACE_COMPILE_FEATURES "cxx_auto_type"
)
add_executable(IfaceCompileFeatures main.cpp)
target_link_libraries(IfaceCompileFeatures iface)
