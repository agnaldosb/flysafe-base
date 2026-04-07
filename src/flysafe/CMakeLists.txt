build_lib(
  LIBNAME flysafe
  SOURCE_FILES
    model/flysafe-tag.cc
    model/flysafe-statistics.cc
    model/flysafe-onoff.cc
    model/flysafe-packet-sink.cc
    helper/utils.cc
  HEADER_FILES
    model/flysafe-tag.h
    model/flysafe-statistics.h
    model/flysafe-onoff.h
    model/flysafe-packet-sink.h
    helper/utils.h
  LIBRARIES_TO_LINK ${libnetwork}
                    ${libinternet}
  TEST_SOURCES
    test/flysafe-test-suite.cc
)
