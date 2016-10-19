#ifndef UPPERCASE_H
#define UPPERCASE_H

#include <QObject>
#include <libnova/lunar.h>
#include <libnova/julian_day.h>
#include <libnova/rise_set.h>
#include <libnova/transform.h>
#include <libnova/utility.h>
#include <libnova/solar.h>

#include <QDebug>

class vector3D
{
public:
    double X;
    double Y;
    double Z;
};

class eclCoords
{
public:
    double lat;
    double lng;
};


class LunarComputer : public QObject
{
    Q_OBJECT
public:
    explicit LunarComputer(QObject *parent = 0);

signals:

public slots:
    void performCalculations(double unixMilliSecs);
    double getLunarX();
    double getLunarY();
    double getLunarZ();
    double getLunarLongitude();
    double getLunarDistance();

public:
    double JD;
    struct ln_rect_posn moon;
    struct ln_equ_posn equ;
    struct ln_lnlat_posn solarEcl;
    struct ln_lnlat_posn lunarEcl;
    struct ln_lnlat_posn observer;
    struct ln_rst_time rst;
    vector3D moonPosition;
    eclCoords solarCoords;
    eclCoords moonCoords;

    void setObserver( double latitude, double longitude );
    void computeLunarPosition();
    void computeLunarCoordinates();
    eclCoords getSolarCoords();
    void setJulianFromUnix( double unixMilliSecs );
};

#endif // UPPERCASE_H
