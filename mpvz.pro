QT += qml quick

HEADERS += src/mpvapp.h \
	src/mpvobject.h
SOURCES += src/main.cpp \
	src/mpvapp.cpp \
	src/mpvobject.cpp

CONFIG += c++14
CONFIG += debug

LIBS += -lmpv

RESOURCES += src/res.qrc

OTHER_FILES += src/qml/MainWindow.qml \
	src/qml/MpvPlayer.qml

