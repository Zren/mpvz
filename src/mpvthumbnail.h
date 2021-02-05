#pragma once

// own
#include "mpvobject.h"


class MpvThumbnail : public MpvObject
{
public:
	MpvThumbnail(QQuickItem * parent = 0);
	virtual ~MpvThumbnail();
};
