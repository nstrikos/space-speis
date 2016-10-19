#include "uppercase.h"

Uppercase::Uppercase(QObject *parent) :
    QObject(parent)
{
}

QString Uppercase::uppercase(const QString &in)
{
    qDebug() << "c++: " << in;
    return in.toUpper();
}

double Uppercase::testC(double x)
{
    //setJD(getJulianFromUnix(x));
    //qDebug() << x / 1000.0;
    getJulianFromUnix(x / 1000.0);
    computeMoonPosition();
    //qDebug() << JD << moonPosition.X << moonPosition.Y << moonPosition.Z;
    //qDebug() << x;
    return moonPosition.X;
}

void Uppercase::setObserver(double latitude, double longitude)
{
    observer.lat = latitude;
    observer.lng = longitude;
}

void Uppercase::setJD(double JD)
{
    this->JD = JD;
}

void Uppercase::computeMoonPosition()
{
    ln_get_lunar_geo_posn (JD, &moon, 0);
    moonPosition.X = moon.X;
    moonPosition.Y = moon.Y;
    moonPosition.Z = moon.Z;
    getMoonCoords();
}

eclCoords Uppercase::getSolarCoords()
{
    ln_get_solar_ecl_coords(JD, &solarEcl);
    solarCoords.lat = solarEcl.lat;
    solarCoords.lng = solarEcl.lng;

    return solarCoords;
}

eclCoords Uppercase::getMoonCoords()
{
    ln_get_lunar_ecl_coords (JD, &lunarEcl, 0);
    moonCoords.lat = lunarEcl.lat;
    moonCoords.lng = lunarEcl.lng;
    //qDebug() << moonCoords.lng << moonCoords.lat << ln_get_lunar_earth_dist(JD);
    return moonCoords;
}

double Uppercase::getX()
{
    return moonPosition.X;
}

double Uppercase::getY()
{
    return moonPosition.Y;
}

double Uppercase::getZ()
{
    return moonPosition.Z;
}

float Uppercase::getJulianFromUnix( int unixSecs )
{
   JD = (double)(2440587.5 + (double)(unixSecs  / (double) 86400.0));
   return (double)(2440587.5 + (double)(unixSecs / (double) 86400.0));
}
