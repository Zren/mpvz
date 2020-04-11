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
		xcb_window_t windowId = window->winId();

		QPoint position(0, 0);
		QPoint rootPosition(0, 0);

		//--- From: KDE's BreezeSizeGrip.cpp
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

		//--- From: KDE's XWindowTasksModel::requestMove
		// https://github.com/KDE/plasma-workspace/blob/c06d8975d5bf9032c2c1e4050468cfc19891fffe/libtaskmanager/xwindowtasksmodel.cpp#L784
		// https://github.com/KDE/kwindowsystem/blob/master/src/platforms/xcb/netwm.cpp
		// https://github.com/KDE/kwindowsystem/blob/d3bc79da92564bfda0337f16ad5c2f72c0327edf/src/platforms/xcb/netwm.cpp#L1583
		// https://github.com/KDE/kwindowsystem/blob/d3bc79da92564bfda0337f16ad5c2f72c0327edf/src/platforms/xcb/netwm.cpp#L361
		
		// NETRootInfo ri(QX11Info::connection(), NET::WMMoveResize);
		// ri.moveResizeRequest(window, geom.center().x(), geom.center().y(), NET::Move);

		// mask = netwm_sendevent_mask;
		// xcb_window_t destination = windowId; // root
		// xcb_window_t window = windowId;
		// message = p->atom(_NET_WM_MOVERESIZE);
		// const uint32_t data[5] = {
		// 	uint32_t(x_root),
		// 	uint32_t(y_root),
		// 	uint32_t(direction),
		// 	0,
		// 	0
		// };

		// xcb_client_message_event_t event;
		// event.response_type = XCB_CLIENT_MESSAGE;
		// event.format = 32;
		// event.sequence = 0;
		// event.window = window;
		// event.type = message;
		// for (int i = 0; i < 5; i++) {
		// 	event.data.data32[i] = data[i];
		// }
		// xcb_send_event( connection, false, windowId, mask, (const char *) &event );

		//---
		// https://code.qt.io/cgit/qt/qtbase.git/tree/src/plugins/platforms/xcb/qxcbwindow.cpp?h=dev#n2374
		// QPoint globalPos(0, 0);

		// const xcb_atom_t moveResize = connection->atom(QXcbAtom::_NET_WM_MOVERESIZE);
		// xcb_client_message_event_t xev;
		// xev.response_type = XCB_CLIENT_MESSAGE;
		// xev.type = moveResize;
		// xev.sequence = 0;
		// xev.window = xcb_window();
		// xev.format = 32;
		// xev.data.data32[0] = globalPos.x();
		// xev.data.data32[1] = globalPos.y();
		// xev.data.data32[2] = 8; // move
		// xev.data.data32[3] = XCB_BUTTON_INDEX_1;
		// xev.data.data32[4] = 0;
		// xcb_ungrab_pointer(connection->xcb_connection(), XCB_CURRENT_TIME);
		// xcb_send_event(
		// 	connection->xcb_connection(),
		// 	false,
		// 	xcb_window(), // xcbScreen()->root(),
		// 	XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY,
		// 	(const char *)&xev
		// );

		//---


		//---
		// https://phabricator.kde.org/D11573
		// https://codereview.qt-project.org/c/qt/qtbase/+/219277
		// TODO: Qt 5.15

		// QPlatformWindow *platformWindow = window->handle();
		// if (platformWindow) {
		// 	platformWindow->startSystemMove(window->mapFromGlobal(position));
		// }
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

