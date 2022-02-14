#pragma once

// MpvObject definition
#define READONLY_PROP_BOOL(p, varName) \
	public: \
		Q_PROPERTY(bool varName READ varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		bool varName() const { return getProperty(p).toBool(); } \
	Q_SIGNALS: \
		void varName##Changed(bool value);
#define WRITABLE_PROP_BOOL(p, varName) \
	public: \
		Q_PROPERTY(bool varName READ varName WRITE set_##varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		bool varName() const { return getProperty(p).toBool(); } \
		void set_##varName(bool value) { setProperty(p, value); } \
	Q_SIGNALS: \
		void varName##Changed(bool value);

#define READONLY_PROP_INT(p, varName) \
	public: \
		Q_PROPERTY(int varName READ varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		int varName() { return getProperty(p).toInt(); } \
	Q_SIGNALS: \
		void varName##Changed(int value);
#define WRITABLE_PROP_INT(p, varName) \
	public: \
		Q_PROPERTY(int varName READ varName WRITE set_##varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		int varName() { return getProperty(p).toInt(); } \
		void set_##varName(int value) { setProperty(p, value); } \
	Q_SIGNALS: \
		void varName##Changed(int value);

#define READONLY_PROP_DOUBLE(p, varName) \
	public: \
		Q_PROPERTY(double varName READ varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		double varName() { return getProperty(p).toDouble(); } \
	Q_SIGNALS: \
		void varName##Changed(double value);
#define WRITABLE_PROP_DOUBLE(p, varName) \
	public: \
		Q_PROPERTY(double varName READ varName WRITE set_##varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		double varName() { return getProperty(p).toDouble(); } \
		void set_##varName(double value) { setProperty(p, value); } \
	Q_SIGNALS: \
		void varName##Changed(double value);

#define READONLY_PROP_STRING(p, varName) \
	public: \
		Q_PROPERTY(QString varName READ varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		QString varName() { return getProperty(p).toString(); } \
	Q_SIGNALS: \
		void varName##Changed(QString value);
#define WRITABLE_PROP_STRING(p, varName) \
	public: \
		Q_PROPERTY(QString varName READ varName WRITE set_##varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		QString varName() { return getProperty(p).toString(); } \
		void set_##varName(QString value) { setProperty(p, value); } \
	Q_SIGNALS: \
		void varName##Changed(QString value);

#define READONLY_PROP_ARRAY(p, varName) \
	public: \
		Q_PROPERTY(QVariantList varName READ varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		QVariantList varName() { return getProperty(p).toList(); } \
	Q_SIGNALS: \
		void varName##Changed(QVariantList value);
#define WRITABLE_PROP_ARRAY(p, varName) \
	public: \
		Q_PROPERTY(QVariantList varName READ varName WRITE set_##varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		QVariantList varName() { return getProperty(p).toList(); } \
		void set_##varName(QVariantList value) { setProperty(p, value); } \
	Q_SIGNALS: \
		void varName##Changed(QVariantList value);

#define READONLY_PROP_MAP(p, varName) \
	public: \
		Q_PROPERTY(QVariantMap varName READ varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		QVariantMap varName() { return getProperty(p).toMap(); } \
	Q_SIGNALS: \
		void varName##Changed(QVariantMap value);
#define WRITABLE_PROP_MAP(p, varName) \
	public: \
		Q_PROPERTY(QVariantMap varName READ varName WRITE set_##varName NOTIFY varName##Changed) \
	public Q_SLOTS: \
		QVariantMap varName() { return getProperty(p).toMap(); } \
		void set_##varName(QVariantMap value) { setProperty(p, value); } \
	Q_SIGNALS: \
		void varName##Changed(QVariantMap value);




// MpvObject() constructor
#define WATCH_PROP_BOOL(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_FLAG);
#define WATCH_PROP_DOUBLE(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_DOUBLE);
#define WATCH_PROP_INT(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_INT64);
#define WATCH_PROP_STRING(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_STRING);
#define WATCH_PROP_ARRAY(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_NODE_ARRAY);
#define WATCH_PROP_MAP(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_NODE_MAP);


// MpvObject::handle_mpv_event()
#define HANDLE_PROP_NONE(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		int64_t value = 0; \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_BOOL(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		bool value = *(bool *)prop->data; \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_INT(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		int64_t value = *(int64_t *)prop->data; \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_DOUBLE(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		double value = *(double *)prop->data; \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_STRING(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		char* charValue = *(char**)prop->data; \
		QString value = QString::fromUtf8(charValue); \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_ARRAY(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		QVariantList value = getProperty(p).toList(); \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_MAP(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		QVariantMap value = getProperty(p).toMap(); \
		Q_EMIT varName##Changed(value); \
	}
