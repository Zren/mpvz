QT += qml quick x11extras widgets
CONFIG += c++14
CONFIG += debug

unix {
	isEmpty(PREFIX) {
		PREFIX=/usr
	}
	target.path = $$PREFIX/bin

	shortcut.files = mpvz.desktop
	shortcut.path = $$PREFIX/share/applications/

	logo.files = mpvz.png
	logo.path = $$PREFIX/share/icons/hicolor/48x48/apps/

	INSTALLS += target shortcut logo
}

LIBS += -lmpv -lxcb

HEADERS += \
	src/mpvhelpers.h \
	src/mpvapp.h \
	src/mpvobject.h \
	src/mpvthumbnail.h
SOURCES += \
	src/main.cpp \
	src/mpvapp.cpp \
	src/mpvobject.cpp \
	src/mpvthumbnail.cpp

RESOURCES += \
	src/res.qrc

DISTFILES += \
	mpvz.desktop
