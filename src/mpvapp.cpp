#include "mpvapp.h"
// #include "mpvobject.h"

#include <QCommandLineParser>

MpvApp::MpvApp(QObject *parent) :
	QObject(parent),
	m_engine()
{
}

MpvApp::~MpvApp() {
}


void MpvApp::parseArgs() {
	QCommandLineParser parser;
	// parser.setApplicationDescription(tr("Media Player Classic Qute Theater"));
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
	m_engine.load(QUrl(QStringLiteral("qrc:///qml/MainWindow.qml")));
	if (m_engine.rootObjects().isEmpty())
		return false;

	// m_mpvObject = m_engine.findChild<MpvObject*>("mpvObject");
	return true;
}

int MpvApp::run() {
	return qApp->exec();
}

