#ifndef MPVAPP_H
#define MPVAPP_H

#include "mpvobject.h"
#include <QQmlApplicationEngine>

class MpvApp : public QObject {
	Q_OBJECT
public:
	explicit MpvApp(QObject *parent = nullptr);
	virtual ~MpvApp();

	void parseArgs();
	bool init();
	int run();

signals:
	void windowsRestored();

private:
	QQmlApplicationEngine m_engine;
	MpvObject *m_mpvObject = nullptr;
	QStringList m_customFiles;

};

#endif
