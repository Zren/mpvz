// own
#include "mpvapp.h"
#include "mpvobject.h"
#include "mpvthumbnail.h"

// std
#include <stdexcept>
#include <clocale>

// Qt
#include <QApplication>
#include <QGuiApplication>
#include <QIcon>
// #include <QtQuick/QQuickWindow>
// #include <QtQuick/QQuickView>
// #include <QQmlApplicationEngine>
// #include <QQmlContext>


int main(int argc, char **argv) {
	QApplication app(argc, argv);
	QGuiApplication::setApplicationDisplayName("mpvz");
	QGuiApplication::setOrganizationDomain("zren.github.io");
	QGuiApplication::setOrganizationName("mpvz");

	QGuiApplication::setApplicationVersion(QT_VERSION_STR);

	app.setWindowIcon(QIcon(":icons/Tethys/play.png"));

	// Qt sets the locale in the QGuiApplication constructor, but libmpv
	// requires the LC_NUMERIC category to be set to "C", so change it back.
	std::setlocale(LC_NUMERIC, "C");

	qmlRegisterType<MpvObject>("mpvz", 1, 0, "MpvObject");
	qmlRegisterType<MpvThumbnail>("mpvz", 1, 0, "MpvThumbnail");

	// QQuickView view;
	// view.setResizeMode(QQuickView::SizeRootObjectToView);
	// view.setSource(QUrl("qrc:///qml/MpvPlayer.qml"));
	// view.show();

	MpvApp mpvApp;
	mpvApp.parseArgs();
	if (!mpvApp.init()) {
		return -1;
	}
	return mpvApp.run();

	// QQmlApplicationEngine engine;
	// // QQmlContext *context = engine.rootContext();
	// // context->setContextProperty(QStringLiteral("mpv"), mpvObject);
	
	// engine.load(QUrl(QStringLiteral("qrc:///qml/MainWindow.qml")));
	// if (engine.rootObjects().isEmpty())
	// 	return -1;

	// MpvObject *mpvObject = engine.findChild<MpvObject*>("mpvObject");

	// QTimer::singleShot(50, this, &App::windowsRestored);

	// QString filepath = QStringLiteral("test.mkv");
	// mpvObject->command(QStringList() << "loadfile" << filepath);
	// mpvObject->command(QStringList() << "loadfile" << "test.mkv");



	// // if (mpvObject) {
	// 	QVariant returnedValue;
	// 	QVariant msg = "test.mkv";
	// 	QMetaObject::invokeMethod(mpvObject, "loadfile",
	// 			Q_RETURN_ARG(QVariant, returnedValue),
	// 			Q_ARG(QVariant, msg));
	// // }

	// return app.exec();
}
