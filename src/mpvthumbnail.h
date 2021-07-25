#pragma once

// own
#include "mpvobject.h"


class MpvThumbnail : public MpvObject
{
public:
	MpvThumbnail(QQuickItem *parent = nullptr);
	virtual ~MpvThumbnail();
};
