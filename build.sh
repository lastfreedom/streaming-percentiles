#!/bin/sh

set -e

usage()
{
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -c, --clean          perform a clean build"
    echo "  -d, --debug          build a debug build (default)"
    echo "  -h, --help           print help and exit"
    echo "  -r, --release        build a release build"
    echo "  --skip-package       skip creating a package as part of build"
    echo "  --skip-tests         skip running tests as part of build"
    exit 1
}

CLEAN_BUILD=0
BUILD_TYPE=Debug
SKIP_TESTS=0
SKIP_PACKAGE=0

while :; do
    if [ $# -le 0 ]; then
        break
    fi

    lowerI="$(echo $1 | awk '{print tolower($0)}')"
    case $lowerI in
        -c|--clean)
            CLEAN_BUILD=1
            ;;

        -d|--debug)
            BUILD_TYPE=Debug
            ;;

        -\?|-h|--help)
            usage
            exit 1
            ;;

        -r|--release)
            BUILD_TYPE=RelWithDebInfo
            ;;

        --skip-package)
            SKIP_PACKAGE=1
            ;;

        --skip-tests)
            SKIP_TESTS=1
            ;;

        *)
            echo "Unrecognized option $1"
            exit 1
            ;;
    esac

    shift
done

PROJECT_BASE_DIR=${PWD}
TARGET_DIR=target/${BUILD_TYPE}

if [ -x "C:/Program Files/CMake/bin/cpack.exe" ]; then
  CPACK_EXE="C:/Program Files/CMake/bin/cpack.exe"
else
  CPACK_EXE=cpack
fi

echo "Building streaming-percentiles with the following settings:"
echo "  Build type: ${BUILD_TYPE}"
echo "  Clean build: ${CLEAN_BUILD}"
echo "  Skip tests: ${SKIP_TESTS}"
echo "  Skip package: ${SKIP_PACKAGE}"
echo "  Target directory: ${TARGET_DIR}"
echo

if [ $CLEAN_BUILD -eq 1 ]; then
  rm -rf ${TARGET_DIR}
fi
if [ ! -d ${TARGET_DIR} ]; then
  mkdir -p ${TARGET_DIR}
fi
cd ${TARGET_DIR}
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ${PROJECT_BASE_DIR}
cmake --build .
if [ $SKIP_TESTS -eq 0 ]; then
  env CTEST_OUTPUT_ON_FAILURE=1 ctest
fi
if [ $SKIP_PACKAGE -eq 0 ]; then
  "$CPACK_EXE"
fi
