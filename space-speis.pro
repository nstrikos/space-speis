TEMPLATE = app

QT += qml quick widgets

CONFIG += c++11

INCLUDEPATH += $$PWD/lib/libnova

SOURCES += main.cpp \
    lib/libnova/aberration.c \
    lib/libnova/airmass.c \
    lib/libnova/angular_separation.c \
    lib/libnova/apparent_position.c \
    lib/libnova/asteroid.c \
    lib/libnova/comet.c \
    lib/libnova/dynamical_time.c \
    lib/libnova/earth.c \
    lib/libnova/elliptic_motion.c \
    lib/libnova/heliocentric_time.c \
    lib/libnova/hyperbolic_motion.c \
    lib/libnova/julian_day.c \
    lib/libnova/jupiter.c \
    lib/libnova/lunar.c \
    lib/libnova/mars.c \
    lib/libnova/mercury.c \
    lib/libnova/neptune.c \
    lib/libnova/nutation.c \
    lib/libnova/parabolic_motion.c \
    lib/libnova/parallax.c \
    lib/libnova/pluto.c \
    lib/libnova/precession.c \
    lib/libnova/proper_motion.c \
    lib/libnova/refraction.c \
    lib/libnova/rise_set.c \
    lib/libnova/saturn.c \
    lib/libnova/sidereal_time.c \
    lib/libnova/solar.c \
    lib/libnova/transform.c \
    lib/libnova/uranus.c \
    lib/libnova/utility.c \
    lib/libnova/venus.c \
    lib/libnova/vsop87.c \
    lunarcomputer.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    lib/libnova/libnova/aberration.h \
    lib/libnova/libnova/airmass.h \
    lib/libnova/libnova/angular_separation.h \
    lib/libnova/libnova/apparent_position.h \
    lib/libnova/libnova/asteroid.h \
    lib/libnova/libnova/comet.h \
    lib/libnova/libnova/dynamical_time.h \
    lib/libnova/libnova/earth.h \
    lib/libnova/libnova/elliptic_motion.h \
    lib/libnova/libnova/heliocentric_time.h \
    lib/libnova/libnova/hyperbolic_motion.h \
    lib/libnova/libnova/julian_day.h \
    lib/libnova/libnova/jupiter.h \
    lib/libnova/libnova/libnova.h \
    lib/libnova/libnova/ln_types.h \
    lib/libnova/libnova/lunar.h \
    lib/libnova/libnova/mars.h \
    lib/libnova/libnova/mercury.h \
    lib/libnova/libnova/neptune.h \
    lib/libnova/libnova/nutation.h \
    lib/libnova/libnova/parabolic_motion.h \
    lib/libnova/libnova/parallax.h \
    lib/libnova/libnova/pluto.h \
    lib/libnova/libnova/precession.h \
    lib/libnova/libnova/proper_motion.h \
    lib/libnova/libnova/refraction.h \
    lib/libnova/libnova/rise_set.h \
    lib/libnova/libnova/saturn.h \
    lib/libnova/libnova/sidereal_time.h \
    lib/libnova/libnova/solar.h \
    lib/libnova/libnova/transform.h \
    lib/libnova/libnova/uranus.h \
    lib/libnova/libnova/utility.h \
    lib/libnova/libnova/venus.h \
    lib/libnova/libnova/vsop87.h \
    lunarcomputer.h

DISTFILES +=

