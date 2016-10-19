#ifndef UPPERCASE_H
#define UPPERCASE_H

#include <QObject>
#include <lunar.h>
#include <julian_day.h>
#include <rise_set.h>
#include <transform.h>
#include <utility.h>
#include <solar.h>

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


class Uppercase : public QObject
{
    Q_OBJECT
public:
    explicit Uppercase(QObject *parent = 0);

signals:

public slots:
    QString uppercase(const QString& in);
    double testC(double x);
    double getX();
    double getY();
    double getZ();

public:
    double JD;
    struct ln_rect_posn moon;
    struct ln_equ_posn equ;
    struct ln_lnlat_posn solarEcl;
    struct ln_lnlat_posn lunarEcl;
    struct ln_lnlat_posn observer;
    struct ln_rst_time rst;
    struct ln_zonedate rise, transit, set;
    vector3D moonPosition;
    eclCoords solarCoords;
    eclCoords moonCoords;

    void setObserver(double latitude, double longitude);
    void setJD(double JD);
    void computeMoonPosition();
    eclCoords getSolarCoords();
    eclCoords getMoonCoords();
    float getJulianFromUnix( int unixSecs );
};

#endif // UPPERCASE_H
