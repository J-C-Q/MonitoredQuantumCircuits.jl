# To use SymEngine from another CMake project include the following in your
# `CMakeLists.txt` file

#    `find_package(SymEngine CONFIG)`

# You can give the path to the SymEngine installation directory if it was
# installed to a non standard location by,

#    `find_package(SymEngine CONFIG Paths /path/to/install/dir)`

# Alternatively, you can give the path to the build directory.

# Variable exported are
# SYMENGINE_BUILD_TYPE         - Cofiguration Type Debug or Release
# SYMENGINE_INCLUDE_DIRS       - Header file directories
# SYMENGINE_LIBRARIES          - SymEngine libraries and dependency libraries to link against
# SYMENGINE_FOUND              - Set to yes
# SYMENGINE_CXX_FLAGS_RELEASE  - C++ flags for Release configuration
# SYMENGINE_CXX_FLAGS_DEBUG    - C++ flags for Debug configuration
# SYMENGINE_C_FLAGS_RELEASE    - C flags for Release configuration
# SYMENGINE_C_FLAGS_DEBUG      - C flags for Debug configuration

# An example project would be,
#
# cmake_minimum_required(VERSION 2.8)
# find_package(symengine CONFIG)
# set(CMAKE_CXX_FLAGS_RELEASE ${SYMENGINE_CXX_FLAGS_RELEASE})
#
# include_directories(${SYMENGINE_INCLUDE_DIRS})
# add_executable(example main.cpp)
# target_link_libraries(example ${SYMENGINE_LIBRARIES})
#

cmake_minimum_required(VERSION 2.8.12)

if (POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()

if (POLICY CMP0057)
  cmake_policy(SET CMP0057 NEW) # needed for llvm >= 16
endif ()

set(SYMENGINE_CXX_FLAGS "-std=c++11 -fvisibility-inlines-hidden -fmessage-length=0 -march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/symengine_1709760459768/work=/usr/local/src/conda/symengine-0.11.2 -fdebug-prefix-map=/files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env=/usr/local/src/conda-prefix -fPIC -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS")
set(SYMENGINE_CXX_FLAGS_RELEASE "-Wall -Wextra -Wno-unused-parameter -fno-common -O3 -funroll-loops -DNDEBUG -Wno-unknown-pragmas")
set(SYMENGINE_CXX_FLAGS_DEBUG "-Wall -Wextra -Wno-unused-parameter -fno-common -g -ggdb -Wno-unknown-pragmas")
set(SYMENGINE_C_FLAGS "-march=nocona -mtune=haswell -ftree-vectorize -fPIC -fstack-protector-strong -fno-plt -O2 -ffunction-sections -pipe -isystem /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include -fdebug-prefix-map=/home/conda/feedstock_root/build_artifacts/symengine_1709760459768/work=/usr/local/src/conda/symengine-0.11.2 -fdebug-prefix-map=/files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env=/usr/local/src/conda-prefix")
set(SYMENGINE_C_FLAGS_RELEASE "-O3 -DNDEBUG")
set(SYMENGINE_C_FLAGS_DEBUG "-g")

# ... for the build tree
get_filename_component(SYMENGINE_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

set(SYMENGINE_BUILD_TREE no)

if(NOT TARGET symengine)
    include("${SYMENGINE_CMAKE_DIR}/SymEngineTargets.cmake")
endif()
set_target_properties(symengine PROPERTIES INTERFACE_LINK_LIBRARIES "")

if(SYMENGINE_BUILD_TREE)
    set(SYMENGINE_INSTALL_CMAKE_DIR "${SYMENGINE_CMAKE_DIR}")
    set(SYMENGINE_INCLUDE_DIRS /home/conda/feedstock_root/build_artifacts/symengine_1709760459768/work;/home/conda/feedstock_root/build_artifacts/symengine_1709760459768/work/build;/home/conda/feedstock_root/build_artifacts/symengine_1709760459768/work/symengine/utilities/cereal/include ${SYMENGINE_CMAKE_DIR})
    if (TARGET teuchos)
        set(SYMENGINE_INCLUDE_DIRS ${SYMENGINE_INCLUDE_DIRS} ${SYMENGINE_CMAKE_DIR}/symengine/utilities/teuchos)
    endif()
else()
    set(SYMENGINE_INSTALL_CMAKE_DIR "/files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/lib/cmake/symengine")
    set(SYMENGINE_INCLUDE_DIRS "${SYMENGINE_CMAKE_DIR}/../../../include")
    if (NOT no)
        set(SYMENGINE_INCLUDE_DIRS ${SYMENGINE_INCLUDE_DIRS}
            "${SYMENGINE_CMAKE_DIR}/../../../include/symengine/utilities/cereal/include")
    endif()
endif()



set(SYMENGINE_FLINT_LIBRARIES /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/lib/libflint.so)
set(SYMENGINE_FLINT_INCLUDE_DIRS /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include;/files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include/flint)
set(HAVE_SYMENGINE_FLINT True)
set(SYMENGINE_MPC_LIBRARIES /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/lib/libmpc.so)
set(SYMENGINE_MPC_INCLUDE_DIRS /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include)
set(HAVE_SYMENGINE_MPC True)
set(SYMENGINE_MPFR_LIBRARIES /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/lib/libmpfr.so)
set(SYMENGINE_MPFR_INCLUDE_DIRS /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include)
set(HAVE_SYMENGINE_MPFR True)
set(SYMENGINE_GMP_LIBRARIES /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/lib/libgmp.so)
set(SYMENGINE_GMP_INCLUDE_DIRS /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include)
set(HAVE_SYMENGINE_GMP True)
set(SYMENGINE_LLVM_LIBRARIES )
set(SYMENGINE_LLVM_INCLUDE_DIRS /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/include)
set(HAVE_SYMENGINE_LLVM True)

set(SYMENGINE_LLVM_COMPONENTS )

if (NOT "${SYMENGINE_LLVM_COMPONENTS}" STREQUAL "")
    find_package(LLVM REQUIRED ${SYMENGINE_LLVM_COMPONENTS} HINTS /files/home/part8/qpreiss/Bookworm/Documents/MonitoredQuantumCircuits/.CondaPkg/env/lib/cmake/llvm)
    llvm_map_components_to_libnames(llvm_libs_direct ${SYMENGINE_LLVM_COMPONENTS})
    llvm_expand_dependencies(llvm_libs ${llvm_libs_direct})
    set(SYMENGINE_LIBRARIES ${SYMENGINE_LIBRARIES} ${llvm_libs})
else()
    set(SYMENGINE_LLVM_INCLUDE_DIRS)
endif()

if (TARGET gmp)
    # Avoid defining targets again
    set(SYMENGINE_SKIP_DEPENDENCIES yes CACHE BOOL "Skip finding dependencies")
else()
    set(SYMENGINE_SKIP_DEPENDENCIES no CACHE BOOL "Skip finding dependencies")
endif()

foreach(PKG FLINT;MPC;MPFR;GMP;LLVM)
    set(SYMENGINE_INCLUDE_DIRS ${SYMENGINE_INCLUDE_DIRS} ${SYMENGINE_${PKG}_INCLUDE_DIRS})
    set(SYMENGINE_LIBRARIES ${SYMENGINE_LIBRARIES} ${SYMENGINE_${PKG}_LIBRARIES})
endforeach()

#Use CMake provided find_package(BOOST) module
if (NOT "" STREQUAL "")
    set(SYMENGINE_INCLUDE_DIRS ${SYMENGINE_INCLUDE_DIRS} )
    set(SYMENGINE_LIBRARIES ${SYMENGINE_LIBRARIES} )
endif()

list(REMOVE_DUPLICATES SYMENGINE_INCLUDE_DIRS)

foreach(LIB "symengine")
    # Remove linking of dependencies to later add them as targets
    set_target_properties(${LIB} PROPERTIES IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "")
    set_target_properties(${LIB} PROPERTIES IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG "")
endforeach()

set(SYMENGINE_LIBRARIES symengine ${SYMENGINE_LIBRARIES})
set(SYMENGINE_BUILD_TYPE "Release")
set(SYMENGINE_FOUND yes)
