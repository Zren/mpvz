#include "mpvapp.h"

// Xcb
#include <xcb/xproto.h>
#include <xcb/xcb.h>

// Qt
#include <QCommandLineParser>
#include <QQmlContext>
#include <QX11Info>
#include <QWindow>

AppObj::AppObj(QObject *parent)
	: QObject(parent)
{
}

AppObj::~AppObj() {
}

void AppObj::dragWindow(QWindow* window) {
	if (window) {
		WId windowId = window->winId();

		QPoint position(0, 0);
		QPoint rootPosition(0, 0);

		//--- From: BreezeSizeGrip.cpp
		// button release event
		auto connection( QX11Info::connection() );
		xcb_button_release_event_t releaseEvent;
		memset(&releaseEvent, 0, sizeof(releaseEvent));

		releaseEvent.response_type = XCB_BUTTON_RELEASE;
		releaseEvent.event =  windowId;
		releaseEvent.child = XCB_WINDOW_NONE;
		releaseEvent.root = QX11Info::appRootWindow();
		releaseEvent.event_x = position.x();
		releaseEvent.event_y = position.y();
		releaseEvent.root_x = rootPosition.x();
		releaseEvent.root_y = rootPosition.y();
		releaseEvent.detail = XCB_BUTTON_INDEX_1;
		releaseEvent.state = XCB_BUTTON_MASK_1;
		releaseEvent.time = XCB_CURRENT_TIME;
		releaseEvent.same_screen = true;
		xcb_send_event( connection, false, windowId, XCB_EVENT_MASK_BUTTON_RELEASE, reinterpret_cast<const char*>(&releaseEvent));

		xcb_ungrab_pointer( connection, XCB_TIME_CURRENT_TIME );
		//---
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
	m_engine.load(QUrl(QStringLiteral("qrc:///qml/MainWindow.qml")));
	if (m_engine.rootObjects().isEmpty())
		return false;

	QQmlContext *context = m_engine.rootContext();
	AppObj *appObj = new AppObj();
	appObj->m_urls = m_customFiles;
	context->setContextProperty(QStringLiteral("app"), appObj);

	// m_mpvObject = m_engine.findChild<MpvObject*>("mpvObject");
	// if (m_mpvObject) {
	// 	m_mpvObject->loadFile(m_customFiles);
	// }
	return true;
}

int MpvApp::run() {
	return qApp->exec();
}

