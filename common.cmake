option(shared "build libtorrent as a shared library" OFF)
option(static_runtime "build libtorrent with static runtime" ON)
option(tcmalloc "link against google performance tools tcmalloc" OFF)
option(pool-allocators "Uses a pool allocator for disk and piece buffers" OFF)
option(encryption "link against openssl and enable encryption" OFF)
option(dht "enable support for Mainline DHT" ON)
option(resolve-countries "enable support for resolving countries from peer IPs" OFF)
option(unicode "enable unicode support" ON)
option(deprecated-functions "enable deprecated functions for backwards compatibility" OFF)
option(exceptions "build with exception support" ON)
option(logging "build with logging" OFF)
option(build_tests "build tests" OFF)

set(CMAKE_CONFIGURATION_TYPES Debug Release RelWithDebInfo)

if (NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release FORCE)
endif()

# add_definitions() doesn't seem to let you say wich build type to apply it to
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DTORRENT_DEBUG")
if(UNIX)
	set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Os -g")
	set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
endif()

if (build_tests)
	# this will make some internal functions available in the
	# DLL interface, for the tests to access
	add_definitions(-DTORRENT_EXPORT_EXTRA)
endif (build_tests)

if (encryption)
	#list(APPEND sources mpi pe_crypto)
	if(NOT DEFINED OPENSSL_INCLUDE_DIR OR NOT DEFINED OPENSSL_LIBRARIES)
		FIND_PACKAGE(OpenSSL REQUIRED)
	endif()
	add_definitions(-DTORRENT_USE_OPENSSL)
	include_directories(${OPENSSL_INCLUDE_DIR})
else()
	add_definitions(-DTORRENT_DISABLE_ENCRYPTION)
	#list(APPEND sources sha1)
endif (encryption)

if (NOT logging)
	add_definitions(-DTORRENT_DISABLE_LOGGING)
endif()

if (dht)
	#foreach(s ${kademlia_sources})
	#	list(APPEND sources2 src/kademlia/${s})
	#endforeach(s)
	#foreach(s ${ed25519_sources})
	#	list(APPEND sources2 ed25519/src/${s})
	#endforeach(s)
else()
	add_definitions(-DTORRENT_DISABLE_DHT)
endif()

if (shared)
	add_definitions(-DTORRENT_BUILDING_SHARED)
	#add_library(torrent-rasterbar SHARED ${sources2})
	if(NOT MSVC)
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden -fvisibility-inlines-hidden")
	endif()
else()
	if(static_runtime)
		# fix /MT flag:
		set(CompilerFlags
				CMAKE_CXX_FLAGS
				CMAKE_CXX_FLAGS_DEBUG
				CMAKE_CXX_FLAGS_RELWITHDEBINFO
				CMAKE_CXX_FLAGS_RELEASE
				CMAKE_C_FLAGS
				CMAKE_C_FLAGS_DEBUG
				CMAKE_CXX_FLAGS_RELWITHDEBINFO
				CMAKE_C_FLAGS_RELEASE
				)
		foreach(CompilerFlag ${CompilerFlags})
			string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
		endforeach()
	endif()
	#add_library(torrent-rasterbar STATIC ${sources2})
endif()

# Boost
if(NOT DEFINED Boost_INCLUDE_DIR OR NOT DEFINED Boost_LIBRARIES)
	FIND_PACKAGE(Boost REQUIRED COMPONENTS system chrono random)
endif()
include_directories(${Boost_INCLUDE_DIR})
#target_link_libraries(torrent-rasterbar ${Boost_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})

# this works around a bug in asio in boost-1.39
#add_definitions(-DBOOST_ASIO_HASH_MAP_BUCKETS=1021  -D__USE_W32_SOCKETS -DWIN32_LEAN_AND_MEAN )

if(NOT static_runtime)
	add_definitions(-DBOOST_SYSTEM_DYN_LINK -DBOOST_CHRONO_DYN_LINK -DBOOST_RANDOM_DYN_LINK)
endif()

if (WIN32)
	#target_link_libraries(torrent-rasterbar wsock32 ws2_32)
	add_definitions(-D_WIN32_WINNT=0x0600)
	# prevent winsock1 to be included
	add_definitions(-DWIN32_LEAN_AND_MEAN)
	if (MSVC)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP") # multicore compilation
	endif()
endif()

#if (encryption)
#	target_link_libraries(torrent-rasterbar ${OPENSSL_LIBRARIES})
#endif()

if (NOT pool-allocators)
	add_definitions(-DTORRENT_DISABLE_POOL_ALLOCATOR)
endif()

if (NOT resolve-countries)
	add_definitions(-DTORRENT_DISABLE_RESOLVE_COUNTRIES)
endif()

if (unicode)
	add_definitions(-DUNICODE -D_UNICODE)
endif()

if (NOT deprecated-functions)
	add_definitions(-DTORRENT_NO_DEPRECATE)
endif()

if (exceptions)
	if (MSVC)
		add_definitions(/EHsc)
	else (MSVC)
		add_definitions(-fexceptions)
	endif (MSVC)
else()
	if (MSVC)
		add_definitions(-D_HAS_EXCEPTIONS=0)
	else (MSVC)
		add_definitions(-fno-exceptions)
	endif (MSVC)
endif()

if (MSVC)
# disable bogus deprecation warnings on msvc8
	add_definitions(-D_SCL_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_DEPRECATE)
# these compiler settings just makes the compiler standard conforming
	add_definitions(/Zc:wchar_t /Zc:forScope)
# for multi-core compilation
	add_definitions(/MP)

#$(SolutionDir)<toolset>msvc,<variant>release:<linkflags>/OPT:ICF=5
#$(SolutionDir)<toolset>msvc,<variant>release:<linkflags>/OPT:REF
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
	add_definitions(-Wno-c++11-extensions)
	add_definitions(-fcolor-diagnostics)
endif()

add_definitions(-D_FILE_OFFSET_BITS=64)
add_definitions(-DBOOST_EXCEPTION_DISABLE)
add_definitions(-DBOOST_ASIO_ENABLE_CANCELIO)

#if (tcmalloc)
#	target_link_libraries(torrent-rasterbar tcmalloc)
#endif()
