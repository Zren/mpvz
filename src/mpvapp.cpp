#include "mpvapp.h"

// Qt
#include <QCommandLineParser>
#include <QQmlContext>
#include <QWindow>

AppObj::AppObj(QObject *parent)
	: QObject(parent)
{
}

AppObj::~AppObj() {
}

void AppObj::dragWindow(QWindow* window) {
	if (window) {
		#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
		window->startSystemMove();
		#endif
	}
}



MpvApp::MpvApp(QObject *parent)
	: QObject(parent)
	, m_engine()
{
}

MpvApp::~MpvApp() {
}


void MpvApp::parseArgs() {
	QCommandLineParser parser;
	parser.setApplicationDescription("mpvz");
	// parser.addHelpOption();
	// parser.addVersionOption();

	// QCommandLineOption sizeOpt("size", tr("Main window size."), "w,h");
	// QCommandLineOption posOpt("pos", tr("Main window position."), "x,y");

	// parser.addOption(sizeOpt);
	// parser.addOption(posOpt);
	parser.addPositionalArgument("urls", tr("URLs to open, optionally."), "[urls...]");

	parser.process(QCoreApplication::arguments());

	// validCliSize = parser.isSet(sizeOpt) && Helpers::sizeFromString(cliSize, parser.value(sizeOpt));
	// validCliPos = parser.isSet(posOpt) && Helpers::pointFromString(cliPos, parser.value(posOpt));
	m_customFiles = parser.positionalArguments();
}

bool MpvApp::init() {
	QQmlContext *context = m_engine.rootContext();
	AppObj *appObj = new AppObj();
	appObj->m_urls = m_customFiles;
	context->setContextProperty(QStringLiteral("app"), appObj);

	m_engine.load(QUrl(QStringLiteral("qrc:///qml/MainWindow.qml")));
	if (m_engine.rootObjects().isEmpty())
		return false;

	// m_mpvObject = m_engine.findChild<MpvObject*>("mpvObject");
	// if (m_mpvObject) {
	// 	m_mpvObject->loadFile(m_customFiles);
	// }
	return true;
}

int MpvApp::run() {
	return qApp->exec();
}

