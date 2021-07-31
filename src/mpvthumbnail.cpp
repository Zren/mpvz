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
	setOption("hwdec", "no");
	setOption("aid", "no"); // No audio track
	setOption("sid", "no"); // Hide subs
	setOption("hr-seek", "no"); // Don't use precise seek
	setOption("sstep", "10"); // Step every 10 seconds
	setOption("pause", "yes"); // Init paused
	setOption("really-quiet", "yes"); // No stdout

	// From bomi
	// https://github.com/ashinan/bomi/blob/master/src/bomi/video/videopreview.cpp#L32
	setOption("audio-file-auto", "no");
	setOption("sub-auto", "no");
	setOption("osd-level", "0");
	// setOption("quiet", "yes");
	setOption("title", "\"\"");
	setOption("audio-pitch-correction", "no");
	setOption("keep-open", "always");
	setOption("vd-lavc-skiploopfilter", "all"); // Skips the loop filter (AKA deblocking) during H.264 decoding.
	setOption("use-text-osd", "no");
	setOption("audio-display", "no");
}

MpvThumbnail::~MpvThumbnail() {

}
