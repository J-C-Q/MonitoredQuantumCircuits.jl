#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "symengine" for configuration "Release"
set_property(TARGET symengine APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(symengine PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libsymengine.so.0.11.2"
  IMPORTED_SONAME_RELEASE "libsymengine.so.0.11"
  )

list(APPEND _cmake_import_check_targets symengine )
list(APPEND _cmake_import_check_files_for_symengine "${_IMPORT_PREFIX}/lib/libsymengine.so.0.11.2" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
