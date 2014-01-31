
#=============================================================================
# Copyright 2002-2009 Kitware, Inc.
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

# This module is shared by multiple languages; use include blocker.
if(__COMPILER_GNU)
  return()
endif()
set(__COMPILER_GNU 1)

macro(__compiler_gnu lang)
  # Feature flags.
  set(CMAKE_${lang}_VERBOSE_FLAG "-v")
  set(CMAKE_${lang}_COMPILE_OPTIONS_PIC "-fPIC")
  if(NOT CMAKE_${lang}_COMPILER_VERSION VERSION_LESS 3.4)
    set(CMAKE_${lang}_COMPILE_OPTIONS_PIE "-fPIE")
  endif()
  if(NOT CMAKE_${lang}_COMPILER_VERSION VERSION_LESS 4.2)
    set(CMAKE_${lang}_COMPILE_OPTIONS_VISIBILITY "-fvisibility=")
  endif()
  set(CMAKE_SHARED_LIBRARY_${lang}_FLAGS "-fPIC")
  set(CMAKE_SHARED_LIBRARY_CREATE_${lang}_FLAGS "-shared")
  set(CMAKE_${lang}_COMPILE_OPTIONS_SYSROOT "--sysroot=")

  # Older versions of gcc (< 4.5) contain a bug causing them to report a missing
  # header file as a warning if depfiles are enabled, causing check_header_file
  # tests to always succeed.  Work around this by disabling dependency tracking
  # in try_compile mode.
  get_property(_IN_TC GLOBAL PROPERTY IN_TRY_COMPILE)
  if(NOT _IN_TC OR CMAKE_FORCE_DEPFILES)
    # distcc does not transform -o to -MT when invoking the preprocessor
    # internally, as it ought to.  Work around this bug by setting -MT here
    # even though it isn't strictly necessary.
    set(CMAKE_DEPFILE_FLAGS_${lang} "-MMD -MT <OBJECT> -MF <DEPFILE>")
  endif()

  # Initial configuration flags.
  set(CMAKE_${lang}_FLAGS_INIT "")
  set(CMAKE_${lang}_FLAGS_DEBUG_INIT "-g")
  set(CMAKE_${lang}_FLAGS_MINSIZEREL_INIT "-Os -DNDEBUG")
  set(CMAKE_${lang}_FLAGS_RELEASE_INIT "-O3 -DNDEBUG")
  set(CMAKE_${lang}_FLAGS_RELWITHDEBINFO_INIT "-O2 -g -DNDEBUG")
  set(CMAKE_${lang}_CREATE_PREPROCESSED_SOURCE "<CMAKE_${lang}_COMPILER> <DEFINES> <FLAGS> -E <SOURCE> > <PREPROCESSED_SOURCE>")
  set(CMAKE_${lang}_CREATE_ASSEMBLY_SOURCE "<CMAKE_${lang}_COMPILER> <DEFINES> <FLAGS> -S <SOURCE> -o <ASSEMBLY_SOURCE>")
  if(NOT APPLE)
    set(CMAKE_INCLUDE_SYSTEM_FLAG_${lang} "-isystem ")
  endif()

  # LTO/IPO
  if(NOT CMAKE_GCC_AR OR NOT CMAKE_GCC_RANLIB)
    if(IS_ABSOLUTE "${CMAKE_${lang}_COMPILER}")
      string(REGEX MATCH "^([0-9]+.[0-9]+)" _version
        "${CMAKE_${lang}_COMPILER_VERSION}")
      get_filename_component(_dir "${CMAKE_${lang}_COMPILER}" DIRECTORY)

      find_program(CMAKE_GCC_AR NAMES
        "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ar"
        "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ar-${_version}"
      )

      find_program(CMAKE_GCC_RANLIB NAMES
        "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ranlib"
        "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ranlib-${_version}"
      )
    endif()
  endif()

  if(CMAKE_GCC_AR AND CMAKE_GCC_RANLIB)
    set(__lto_flags -flto)

    if(NOT CMAKE_${lang}_COMPILER_VERSION VERSION_LESS 4.7)
      list(APPEND __lto_flags -fno-fat-lto-objects)
    endif()

    if(NOT DEFINED CMAKE_${lang}_PASSED_LTO_TEST)
      set(__output_dir "${CMAKE_PLATFORM_INFO_DIR}/LtoTest${lang}")
      file(MAKE_DIRECTORY "${__output_dir}")
      set(__output_base "${__output_dir}/lto-test-${lang}")

      execute_process(
        COMMAND ${CMAKE_COMMAND} -E echo "void foo() {}"
        COMMAND ${CMAKE_${lang}_COMPILER} ${__lto_flags} -c -xc -
          -o ${__output_base}.o
        RESULT_VARIABLE __result
        ERROR_QUIET
        OUTPUT_QUIET
      )

      if("${__result}" STREQUAL "0")
        execute_process(
          COMMAND ${CMAKE_GCC_AR} cr ${__output_base}.a ${__output_base}.o
          COMMAND ${CMAKE_GCC_RANLIB} ${__output_base}.a
          RESULT_VARIABLE __result
          ERROR_QUIET
          OUTPUT_QUIET
        )
      endif()

      if("${__result}" STREQUAL "0")
        execute_process(
          COMMAND ${CMAKE_COMMAND} -E echo "void foo(); int main() {foo();}"
          COMMAND ${CMAKE_${lang}_COMPILER} ${__lto_flags} -xc -
            -x none ${__output_base}.a -o ${__output_base}
          RESULT_VARIABLE __result
          ERROR_QUIET
          OUTPUT_QUIET
        )
      endif()

      if("${__result}" STREQUAL "0")
        set(__lto_found TRUE)
      endif()

      set(CMAKE_${lang}_PASSED_LTO_TEST
        ${__lto_found} CACHE INTERNAL
        "If the compiler passed a simple LTO test compile")
    endif()

    if(CMAKE_${lang}_PASSED_LTO_TEST)

      set(CMAKE_${lang}_COMPILE_OPTIONS_IPO ${__lto_flags})

      set(CMAKE_${lang}_ARCHIVE_CREATE_IPO
        "${CMAKE_GCC_AR} cr <TARGET> <LINK_FLAGS> <OBJECTS>"
      )

      set(CMAKE_${lang}_ARCHIVE_APPEND_IPO
        "${CMAKE_GCC_AR} r <TARGET> <LINK_FLAGS> <OBJECTS>"
      )

      set(CMAKE_${lang}_ARCHIVE_FINISH_IPO
        "${CMAKE_GCC_RANLIB} <TARGET>"
      )
    endif()
  endif()
endmacro()
