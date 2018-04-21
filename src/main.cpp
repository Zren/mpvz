#include "mpvobject.h"

#include <stdexcept>
#include <clocale>

#include <QGuiApplication>
#include <QtQuick/QQuickWindow>
#include <QtQuick/QQuickView>
#include <QQmlApplicationEngine>
#include <QQmlContext>


int main(int argc, char **argv) {
	QGuiApplication app(argc, argv);
	QGuiApplication::setApplicationDisplayName("mpvz");

	QCoreApplication::setApplicationVersion(QT_VERSION_STR);

	// Qt sets the locale in the QGuiApplication constructor, but libmpv
	// requires the LC_NUMERIC category to be set to "C", so change it back.
	std::setlocale(LC_NUMERIC, "C");

	qmlRegisterType<MpvObject>("mpvz", 1, 0, "MpvObject");

	QQuickView view;
	view.setResizeMode(QQuickView::SizeRootObjectToView);
	view.setSource(QUrl("qrc:///qml/MpvPlayer.qml"));
	view.show();

	// QQmlApplicationEngine engine;
	// QQmlContext *context = engine.rootContext();
	// // context->setContextProperty(QStringLiteral("mpv"), mpvObject);
	
	// engine.load(QUrl(QStringLiteral("qrc:///qml/MainWindow.qml")));
	// if (engine.rootObjects().isEmpty())
	// 	return -1;

	return app.exec();
}
