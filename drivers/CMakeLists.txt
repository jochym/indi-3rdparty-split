cmake_minimum_required(VERSION 2.6)

PROJECT(libindi-3rdparty CXX C)
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake_modules/")
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake_modules/")
include(GNUInstallDirs)

## Some files like libnova.h and libusb.h are in in subdirectories of the include directory
## For the CMAKE Modules, they find the subdirectory, so then something like ln_types.h should be #include ln_types.h
## But some packages and drivers write their header files like this: #include libnova/ln_types.h
## On Linux, this is fine since the top include directory such as /usr/include is already included and therefore
## <libnova/ln_types.h> is resolved. But on Mac it its not already in the path and has to be explicitly added.

if (APPLE)
    ##This one is needed for homebrew
include_directories( "/usr/local/include")
    ## This one is needed for Craft
include_directories("${CMAKE_INSTALL_PREFIX}/include")
endif(APPLE)

set(LIBRARIES_FOUND TRUE)

include(CMakeCommon)

# Clang Format support
IF (UNIX OR APPLE)
    SET(FORMAT_CODE OFF CACHE BOOL "Enable Clang Format")
    IF (FORMAT_CODE MATCHES ON)
        FILE(GLOB_RECURSE ALL_SOURCE_FILES *.c *.cpp *.h)

        FOREACH(SOURCE_FILE ${ALL_SOURCE_FILES})
            STRING(FIND ${SOURCE_FILE} ${CMAKE_SOURCE_DIR} DIR_FOUND)
            IF (NOT ${DIR_FOUND} EQUAL 0)
                LIST(REMOVE_ITEM ALL_SOURCE_FILES ${SOURCE_FILE})
            ENDIF ()
            # Don't apply the format for 3rd party libraries
            STRING(FIND ${SOURCE_FILE} libapogee DIR1_FOUND)
            STRING(FIND ${SOURCE_FILE} libfishcamp DIR2_FOUND)
            STRING(FIND ${SOURCE_FILE} libfli DIR3_FOUND)
            STRING(FIND ${SOURCE_FILE} libqhy DIR4_FOUND)
            STRING(FIND ${SOURCE_FILE} libqsi DIR5_FOUND)
            STRING(FIND ${SOURCE_FILE} libsbig DIR6_FOUND)
            STRING(FIND ${SOURCE_FILE} fxload DIR7_FOUND)
            STRING(FIND ${SOURCE_FILE} libinovasdk DIR8_FOUND)
            IF (NOT ${DIR1_FOUND} EQUAL -1 OR NOT ${DIR2_FOUND} EQUAL -1 OR NOT ${DIR3_FOUND} EQUAL -1 OR NOT ${DIR4_FOUND} EQUAL -1 OR
                NOT ${DIR5_FOUND} EQUAL -1 OR NOT ${DIR6_FOUND} EQUAL -1 OR NOT ${DIR7_FOUND} EQUAL -1 OR NOT ${DIR8_FOUND} EQUAL -1 OR
                NOT ${DIR9_FOUND} EQUAL -1)
                LIST(REMOVE_ITEM ALL_SOURCE_FILES ${SOURCE_FILE})
            ENDIF ()
        ENDFOREACH ()

        FIND_PROGRAM(CLANGFORMAT_EXE NAMES clang-format-5.0)
        IF (CLANGFORMAT_EXE)
            ADD_CUSTOM_TARGET(clang-format COMMAND ${CLANGFORMAT_EXE} -style=file -i ${ALL_SOURCE_FILES})
        ENDIF ()
    ENDIF ()
ENDIF ()

# Option to build the 3rd Party libraries instead of the 3rd Party drivers.
# This is by default OFF, so you must set the option to build them.
# It is a good idea to run with this option before the 3rd Party build so all the libraries are built first.
option(BUILD_LIBS "Build 3rd Party Libraries, not 3rd Party Drivers" Off)

# Define standard set of drivers to build (default linux target)
option(WITH_EQMOD "Install EQMod Driver" On)
option(WITH_STARBOOK "Install Starbook Driver" On)
option(WITH_NSE "Install Nexstar Evo Driver" On)
option(WITH_SX "Install StarLight Xpress Driver" On)
option(WITH_MAXDOME "Install MaxDomeII Driver" On)
option(WITH_NEXDOME "Install NexDome Driver" On)
option(WITH_SPECTRACYBER "Install Spectracyber Driver" On)
option(WITH_CLOUDWATCHER "Install AAG Cloud Watcher Driver" On)
option(WITH_MI "Install Moravian Driver" On)
option(WITH_FLI "Install FLI Driver" On)
option(WITH_SBIG "Install SBIG Driver" On)
option(WITH_INOVAPLX "Install i.Nova PLx Driver" On)
option(WITH_APOGEE "Install Apogee Driver" On)
option(WITH_FFMV "Install Point Grey FireFly MV Driver" On)
option(WITH_QHY "Install QHY Driver" On)
option(WITH_SSAG "Install Star Shoot Driver" On)
option(WITH_GPHOTO "Install GPhoto Driver" On)
option(WITH_QSI "Install QSI Driver" On)
option(WITH_DUINO "Install Ariduino Driver" On)
option(WITH_FISHCAMP "Install Fishcamp Driver" On)
option(WITH_GPSD "Install GPSD Driver" On)
option(WITH_GIGE "Install GiGE machine vision Driver" Off)
option(WITH_DSI "Install Meade DSI Driver" On)
option(WITH_ASICAM "Install ZWO Optics ASI Driver" On)
option(WITH_MGEN "Install MGen Autoguider" On)
option(WITH_LIMESDR "Install LIME-SDR Receiver" On)
option(WITH_RTLSDR "Install RTL-SDR Receiver" On)
option(WITH_RADIOSIM "Install RadioSim Receiver" On)
option(WITH_GPSNMEA "Install GPS NMEA Driver" On)
option(WITH_ARMADILLO "Install Armadillo & Platypus Driver" On)
option(WITH_FXLOAD "Install FX3 compatible fxload tool" Off)
option(WITH_NIGHTSCAPE "Install Nightscape 8300 Driver" On)
option(WITH_ATIK "Install Atik Driver" On)
option(WITH_TOUPCAM "Install Toupcam Driver" On)
option(WITH_ALTAIRCAM "Install Altair Driver" On)
option(WITH_AVALON "Install Avalon StarGO Driver" On)
option(WITH_BEEFOCUS "Install Bee Focuser Driver" On)

find_package(FFmpeg)

if (FFMPEG_FOUND)
    message(STATUS "Since FFMPEG was found, INDI Webcam Driver can be built")
    option(WITH_WEBCAM "Install INDI Webcam Driver based on FFMPEG" On)
ELSE(FFMPEG_FOUND)
    message(STATUS "Since an up to date FFMPEG was not found, INDI Webcam Driver will not be built")
    option(WITH_WEBCAM "Install INDI Webcam Driver based on FFMPEG" Off)
ENDIF(FFMPEG_FOUND)

# Add/remove cases for OSX
IF (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(WITH_INOVAPLX Off)
    set(WITH_GIGE Off)
    set(WITH_FXLOAD Off)
    set(WITH_SBIG Off)
    set(WITH_DSI Off)
ENDIF ()
# Disable apogee, qhy and mi with gcc 4.8 and earlier versions
IF (CMAKE_COMPILER_IS_GNUCXX AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.9)
    SET(WITH_APOGEE Off)
    SET(WITH_QHY Off)
    SET(WITH_MI Off)
ENDIF ()

# If the Build Libs option is selected, it will just build the required libraries.
# This should be run before the main 3rd Party Drivers build, so the drivers can find the libraries.
IF (BUILD_LIBS)

#libaltaircam
if (WITH_ALTAIRCAM)
add_subdirectory(libaltaircam)
endif (WITH_ALTAIRCAM)

#libapogee
if (WITH_APOGEE)
add_subdirectory(libapogee)
endif(WITH_APOGEE)

#libatik
if (WITH_ATIK)
add_subdirectory(libatik)
endif (WITH_ATIK)

#libfishcamp
if (WITH_FISHCAMP)
add_subdirectory(libfishcamp)
endif(WITH_FISHCAMP)

#libfli
if (WITH_FLI)
add_subdirectory(libfli)
endif(WITH_FLI)

#libinovasdk
if (WITH_INOVAPLX)
add_subdirectory(libinovasdk)
endif (WITH_INOVAPLX)

#libqhy
if (WITH_QHY)
add_subdirectory(libqhy)
endif (WITH_QHY)

#libqsi
if (WITH_QSI)
add_subdirectory(libqsi)
endif (WITH_QSI)

#libsbig
if (WITH_SBIG)
add_subdirectory(libsbig)
endif (WITH_SBIG)

#libtoupcam
if (WITH_TOUPCAM)
add_subdirectory(libtoupcam)
endif (WITH_TOUPCAM)

# This is the main 3rd Party build.  It runs if the Build Libs option is not selected.
ELSE(BUILD_LIBS)

## EQMod
if (WITH_EQMOD)
add_subdirectory(indi-eqmod)
endif(WITH_EQMOD)

## Starbook
if (WITH_STARBOOK)
add_subdirectory(indi-starbook)
endif(WITH_STARBOOK)

## Stalight Xpress
if (WITH_SX)
add_subdirectory(indi-sx)
endif(WITH_SX)

## Maxdome II
if (WITH_MAXDOME)
add_subdirectory(indi-maxdomeii)
endif(WITH_MAXDOME)

## NexDome
if (WITH_NEXDOME)
add_subdirectory(indi-nexdome)
endif(WITH_NEXDOME)

## SpectraCyber
if (WITH_SPECTRACYBER)
add_subdirectory(indi-spectracyber)
endif(WITH_SPECTRACYBER)

## Cloud Watcher
if (WITH_CLOUDWATCHER)
add_subdirectory(indi-aagcloudwatcher)
endif (WITH_CLOUDWATCHER)

## Nexstar Evo
if (WITH_NSE)
add_subdirectory(indi-nexstarevo)
endif (WITH_NSE)

## GPhoto
if (WITH_GPHOTO)
add_subdirectory(indi-gphoto)
endif(WITH_GPHOTO)

## QSI
if (WITH_QSI)
find_package(QSI)
if (QSI_FOUND)
add_subdirectory(indi-qsi)
else (QSI_FOUND)
add_subdirectory(libqsi)
SET(LIBRARIES_FOUND FALSE)
endif (QSI_FOUND)
endif (WITH_QSI)

## SBIG
if (WITH_SBIG)
find_package(SBIG)
if (SBIG_FOUND)
add_subdirectory(indi-sbig)
else (SBIG_FOUND)
add_subdirectory(libsbig)
SET(LIBRARIES_FOUND FALSE)
endif (SBIG_FOUND)
endif (WITH_SBIG)

## ATIK
if (WITH_ATIK)
find_package(ATIK)
if (ATIK_FOUND)
add_subdirectory(indi-atik)
else (ATIK_FOUND)
add_subdirectory(libatik)
SET(LIBRARIES_FOUND FALSE)
endif (ATIK_FOUND)
endif (WITH_ATIK)

## TOUPCAM
if (WITH_TOUPCAM)
find_package(TOUPCAM)
if (TOUPCAM_FOUND)
add_subdirectory(indi-toupcam)
else (TOUPCAM_FOUND)
add_subdirectory(libtoupcam)
SET(LIBRARIES_FOUND FALSE)
endif (TOUPCAM_FOUND)
endif (WITH_TOUPCAM)

## ALTAIR
if (WITH_ALTAIRCAM)
find_package(ALTAIRCAM)
if (ALTAIRCAM_FOUND)
add_subdirectory(indi-altaircam)
else (ALTAIRCAM_FOUND)
add_subdirectory(libaltaircam)
SET(LIBRARIES_FOUND FALSE)
endif (ALTAIRCAM_FOUND)
endif (WITH_ALTAIRCAM)

## Bee Focuser
if (WITH_BEEFOCUS)
add_subdirectory(indi-beefocus)
endif(WITH_BEEFOCUS)


## INOVA
if (WITH_INOVAPLX)
find_package(INOVASDK)
if (INOVASDK_FOUND)
add_subdirectory(indi-inovaplx)
else (INOVASDK_FOUND)
add_subdirectory(libinovasdk)
SET(LIBRARIES_FOUND FALSE)
endif (INOVASDK_FOUND)
endif (WITH_INOVAPLX)

## FLI
if (WITH_FLI)
find_package(FLI)
if (FLI_FOUND)
add_subdirectory(indi-fli)
else (FLI_FOUND)
add_subdirectory(libfli)
SET(LIBRARIES_FOUND FALSE)
endif (FLI_FOUND)
endif(WITH_FLI)

## Apogee
if (WITH_APOGEE)
find_package(APOGEE)
if (APOGEE_FOUND)
add_subdirectory(indi-apogee)
else (APOGEE_FOUND)
add_subdirectory(libapogee)
SET(LIBRARIES_FOUND FALSE)
endif (APOGEE_FOUND)
endif(WITH_APOGEE)

## Point Grey FireFly MV
if (WITH_FFMV)
add_subdirectory(indi-ffmv)
endif (WITH_FFMV)

## Moravian
if (WITH_MI)
add_subdirectory(indi-mi)
endif (WITH_MI)

## Arduino
if (WITH_DUINO)
add_subdirectory(indi-duino)
endif (WITH_DUINO)

## Fishcamp
if (WITH_FISHCAMP)
find_package(FISHCAMP)
if (FISHCAMP_FOUND)
add_subdirectory(indi-fishcamp)
else (FISHCAMP_FOUND)
add_subdirectory(libfishcamp)
SET(LIBRARIES_FOUND FALSE)
endif(FISHCAMP_FOUND)
endif(WITH_FISHCAMP)

## ASI
if (WITH_ASICAM)
add_subdirectory(asi-common)
add_subdirectory(indi-asi)
endif(WITH_ASICAM)

## DSI
if (WITH_DSI)
add_subdirectory(indi-dsi)
endif(WITH_DSI)

## QHY
if (WITH_QHY)
find_package(QHY)
if (QHY_FOUND)
add_subdirectory(indi-qhy)
else (QHY_FOUND)
add_subdirectory(libqhy)
SET(LIBRARIES_FOUND FALSE)
endif (QHY_FOUND)
endif (WITH_QHY)

## Star Shoot Auto Guider
if (WITH_SSAG)
add_subdirectory(indi-ssag)
endif (WITH_SSAG)

## GPSD
if (WITH_GPSD)
add_subdirectory(indi-gpsd)
endif (WITH_GPSD)

## GPS NMEA
if (WITH_GPSNMEA)
add_subdirectory(indi-gpsnmea)
endif(WITH_GPSNMEA)

## GIGE
if (WITH_GIGE)
add_subdirectory(indi-gige)
endif (WITH_GIGE)

# MGen
if (WITH_MGEN)
add_subdirectory(indi-mgen)
endif (WITH_MGEN)

# RadioSim
if (WITH_RADIOSIM)
add_subdirectory(indi-radiosim)
endif (WITH_RADIOSIM)

## RTL-SDR
if (WITH_RTLSDR)
find_package(RTLSDR)
if (RTLSDR_FOUND)
add_subdirectory(indi-rtlsdr)
else (RTLSDR_FOUND)
SET(LIBRARIES_FOUND FALSE)
endif (RTLSDR_FOUND)
endif (WITH_RTLSDR)

## LIME-SDR
if (WITH_LIMESDR)
find_package(LIMESUITE)
if (LIMESUITE_FOUND)
add_subdirectory(indi-limesdr)
else (LIMESUITE_FOUND)
SET(LIBRARIES_FOUND FALSE)
endif (LIMESUITE_FOUND)
endif (WITH_LIMESDR)

if (WITH_ARMADILLO)
add_subdirectory(indi-armadillo-platypus)
endif(WITH_ARMADILLO)

if (WITH_FXLOAD)
add_subdirectory(fxload)
endif()

if (WITH_WEBCAM)
add_subdirectory(indi-webcam)
endif()

if (WITH_NIGHTSCAPE)
add_subdirectory(indi-nightscape)
endif(WITH_NIGHTSCAPE)

# Avalon StarGO
if (WITH_AVALON)
add_subdirectory(indi-avalon)
endif(WITH_AVALON)


# Check if libraries are found. If not, we must build them, install them, THEN run CMake again to build and instal the drivers. If all the libraraies are installed, then we build and install the drivers only now.
if (LIBRARIES_FOUND)
message(STATUS "############################################################################")
message(STATUS "######### All libraries are found. Building all INDI 3rd party drivers now.")
message(STATUS "############################################################################")
else (LIBRARIES_FOUND)
message(STATUS "####################################################################################################################################")
message(STATUS "Not all libraries found, you must build and install all libraries first:")

if (WITH_QSI AND NOT QSI_FOUND)
message(STATUS "libqsi was not found and will now be built. Please install libqsi first before running cmake again to install indi-qsi.")
endif (WITH_QSI AND NOT QSI_FOUND)

if (WITH_QHY AND NOT QHY_FOUND)
message(STATUS "libqhy was not found and will now be built. Please install libqhy first before running cmake again to install indi-qhy.")
endif (WITH_QHY AND NOT QHY_FOUND)

if (WITH_SBIG AND NOT SBIG_FOUND)
message(STATUS "libsbigudrv was not found and will now be built. Please install libsbigudrv first before running cmake again to install indi-sbig.")
endif (WITH_SBIG AND NOT SBIG_FOUND)

if (WITH_ATIK AND NOT ATIK_FOUND)
message(STATUS "libatik was not found and will now be built. Please install libatik first before running cmake again to install indi-atik.")
endif (WITH_ATIK AND NOT ATIK_FOUND)

if (WITH_TOUPCAM AND NOT TOUPCAM_FOUND)
message(STATUS "libtoupcam was not found and will now be built. Please install libtoupcam first before running cmake again to install indi-toupcam.")
endif (WITH_TOUPCAM AND NOT TOUPCAM_FOUND)

if (WITH_ALTAIRCAM AND NOT ALTAIRCAM_FOUND)
message(STATUS "libaltair was not found and will now be built. Please install libaltair first before running cmake again to install indi-altair.")
endif (WITH_ALTAIRCAM AND NOT ALTAIRCAM_FOUND)

if (WITH_INOVAPLX AND NOT INOVASDK_FOUND)
message(STATUS "libinovasdk was not found and will now be built. Please install libinovasdk first before running cmake again to install indi-inovaplx.")
endif (WITH_INOVAPLX AND NOT INOVASDK_FOUND)

if (WITH_FLI AND NOT FLI_FOUND)
message(STATUS "libfli was not found and will now be built. Please install libfli first before running cmake again to install indi-fli.")
endif (WITH_FLI AND NOT FLI_FOUND)

if (WITH_APOGEE AND NOT APOGEE_FOUND)
message(STATUS "libapogee was not found and will now be built. Please install libapogee first before running cmake again to install indi-apogee.")
endif (WITH_APOGEE AND NOT APOGEE_FOUND)

if (WITH_FISHCAMP AND NOT FISHCAMP_FOUND)
message(STATUS "libfishcamp was not found and will now be built. Please install libfishcamp first before running cmake again to install indi-fishcamp.")
endif (WITH_FISHCAMP AND NOT FISHCAMP_FOUND)

if (WITH_LIMESDR AND NOT LIMESDR_FOUND)
message(STATUS "liblimesuite was not found. Please install liblimesuite first before running cmake again to install indi-limesdr.")
endif (WITH_LIMESDR AND NOT LIMESDR_FOUND)

if (WITH_RTLSDR AND NOT RTLSDR)
message(STATUS "librtlsdr was not found. Please install librtlsdr first before running cmake again to install indi-rtlsdr.")
endif (WITH_RTLSDR AND NOT RTLSDR)

message(STATUS "####################################################################################################################################")
endif (LIBRARIES_FOUND)

ENDIF(BUILD_LIBS)

