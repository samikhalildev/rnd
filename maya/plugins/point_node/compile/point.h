#ifndef POINT_H
#define POINT_H

#include <maya/MPxLocatorNode.h>
#include <maya/MFnNumericAttribute.h>
#include <maya/MFnEnumAttribute.h>
#include <maya/MFnDependencyNode.h>
#include <maya/MPlug.h>
#include <maya/MDataBlock.h>
#include <maya/MGlobal.h>
#include <maya/MTypeId.h>
#include <maya/MColorArray.h>

#include <iostream>
#include <string>
#include <vector>

class Point : public MPxLocatorNode {
public:
	Point();
	virtual void postConstructor();
	virtual ~Point();

	static void* creator();

	virtual void draw(M3dView&, const MDagPath&, 
						M3dView::DisplayStyle, M3dView::DisplayStatus);

	static MTypeId id;

	static MStatus initialize();

	static MObject input_display;
	static MObject input_box;
	static MObject input_cross;
	static MObject input_tick;
	static MObject input_axis;
	static MObject input_color;

private:
	static MColorArray colors;
};

#endif