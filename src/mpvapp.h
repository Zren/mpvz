#pragma once

#include "mpvobject.h"

// Qt
#include <QQmlApplicationEngine>


class AppObj : public QObject {
	Q_OBJECT
	
	friend class MpvApp;

	Q_PROPERTY(QStringList urls READ urls)

public:
	explicit AppObj(QObject *parent = nullptr);
	virtual ~AppObj();

	QStringList urls() { return m_urls; };

	Q_INVOKABLE void dragWindow(QWindow* window);

protected:
	QStringList m_urls;

};



class MpvApp : public QObject {
	Q_OBJECT
public:
	explicit MpvApp(QObject *parent = nullptr);
	virtual ~MpvApp();

	void parseArgs();
	bool init();
	int run();

	QStringList urls() { return m_customFiles; };

signals:
	void windowsRestored();

private:
	QQmlApplicationEngine m_engine;
	MpvObject *m_mpvObject = nullptr;
	QStringList m_customFiles;

};
