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




// MpvObject() constructor
#define WATCH_PROP_BOOL(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_FLAG);
#define WATCH_PROP_DOUBLE(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_DOUBLE);
#define WATCH_PROP_INT(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_INT64);
#define WATCH_PROP_STRING(p) \
	mpv_observe_property(mpv, 0, p, MPV_FORMAT_STRING);


// MpvObject::handle_mpv_event()
#define HANDLE_PROP_BOOL(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		bool value = *(bool *)prop->data; \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_INT(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		int64_t value = getProperty(p).toInt(); \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_DOUBLE(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		double value = *(double *)prop->data; \
		Q_EMIT varName##Changed(value); \
	}
#define HANDLE_PROP_STRING(p, varName) \
	(strcmp(prop->name, p) == 0) { \
		QString value = getProperty(p).toString(); \
		Q_EMIT varName##Changed(value); \
	}
