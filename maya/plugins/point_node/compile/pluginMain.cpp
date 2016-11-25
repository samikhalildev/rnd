#include "point.h"
#include <maya/MFnPlugin.h>

MStatus initializePlugin(MObject obj) {
	MStatus status;
	MFnPlugin fn_plugin(obj, "Jason Labbe", "1.0", "Any");
	status = fn_plugin.registerNode("point", 
									Point::id, 
									Point::creator, 
									Point::initialize, 
									MPxNode::kLocatorNode);

	CHECK_MSTATUS_AND_RETURN_IT(status);

	return MS::kSuccess;
}

MStatus uninitializePlugin(MObject obj) {
	MStatus status;
	MFnPlugin fn_plugin(obj);
	fn_plugin.deregisterNode(Point::id);

	CHECK_MSTATUS_AND_RETURN_IT(status);

	return MS::kSuccess;
}