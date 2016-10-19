#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "lunarcomputer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    LunarComputer lunarComputer;
    lunarComputer.setObserver(37.98, 23.74);

    engine.rootContext()->setContextProperty("_performCalculations", &lunarComputer);
    engine.rootContext()->setContextProperty("_getLunarX", &lunarComputer);
    engine.rootContext()->setContextProperty("_getLunarY", &lunarComputer);
    engine.rootContext()->setContextProperty("_getLunarZ", &lunarComputer);


    return app.exec();
}
