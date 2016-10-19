#include "lunarcomputer.h"

LunarComputer::LunarComputer(QObject *parent) :
    QObject(parent)
{
}

void LunarComputer::setObserver(double latitude, double longitude)
{
    observer.lat = latitude;
    observer.lng = longitude;
}

void LunarComputer::performCalculations(double unixMilliSecs)
{
    setJulianFromUnix(unixMilliSecs);
    computeLunarPosition();
    computeLunarCoordinates();
}

void LunarComputer::setJulianFromUnix( double unixMilliSecs )
{
   double unixSecs = unixMilliSecs / 1000.0;
   JD = (double)(2440587.5 + (double)(unixSecs  / (double) 86400.0));
}

void LunarComputer::computeLunarPosition()
{
    ln_get_lunar_geo_posn (JD, &moon, 0);
    moonPosition.X = moon.X;
    moonPosition.Y = moon.Y;
    moonPosition.Z = moon.Z;
}

void LunarComputer::computeLunarCoordinates()
{
    ln_get_lunar_ecl_coords (JD, &lunarEcl, 0);
    moonCoords.lat = lunarEcl.lat;
    moonCoords.lng = lunarEcl.lng;
    //qDebug() << moonCoords.lng << moonCoords.lat << ln_get_lunar_earth_dist(JD);
}

double LunarComputer::getLunarX()
{
    return moonPosition.X;
}

double LunarComputer::getLunarY()
{
    return moonPosition.Y;
}

double LunarComputer::getLunarZ()
{
    return moonPosition.Z;
}

double LunarComputer::getLunarLongitude()
{
    return moonCoords.lng;
}

double LunarComputer::getLunarDistance()
{
    return ln_get_lunar_earth_dist(JD);
}

eclCoords LunarComputer::getSolarCoords()
{
    ln_get_solar_ecl_coords(JD, &solarEcl);
    solarCoords.lat = solarEcl.lat;
    solarCoords.lng = solarEcl.lng;

    return solarCoords;
}
