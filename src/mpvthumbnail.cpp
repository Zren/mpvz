#include "mpvthumbnail.h"

// Qt
#include <QtQuick/QQuickItem>

// own
#include "mpvobject.h"
#include "qthelper.hpp"


MpvThumbnail::MpvThumbnail(QQuickItem *parent)
	: MpvObject(parent)
{
	setEnableAudio(false);
	setOption("sid", "no"); // Hide subs
	setOption("hr-seek", "no"); // Don't use precise seek
	setOption("sstep", "10"); // Step every 10 seconds
	setOption("pause", ""); // Init paused
}

MpvThumbnail::~MpvThumbnail() {

}
