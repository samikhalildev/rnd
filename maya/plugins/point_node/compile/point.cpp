/*
Author: Jason Labbe

A custom locator that tries to mimic 3DsMax's point helper drawing shapes.

Bugs:
	- Drawing for viewport 2.0 not implemented.

Benchmarks:
	Locators
		8000 nodes: 70 fps
		8000 nodes in v2.0: 500 fps

	Points
		8000 nodes with cross: 11 fps

Notes:
	As far as I can tell performance drops when using glVertex3f method.

	To further speed up frame rate, hide their visibility.
	Switching display to 0 will improve speed, but won't be as fast.
*/

#include "point.h"

MTypeId Point::id(0x00000900);

MObject Point::input_display;
MObject Point::input_box;
MObject Point::input_cross;
MObject Point::input_tick;
MObject Point::input_axis;
MObject Point::input_color;

MColorArray Point::colors;


Point::Point() {
}

void Point::postConstructor() {
	MObject self = thisMObject();
	MFnDependencyNode fn_node(self);
	fn_node.setName("pointShape#");
}

Point::~Point() {
}

void* Point::creator() {
	return new Point();
}

MStatus Point::initialize() {
	MFnNumericAttribute nAttr;

	input_display = nAttr.create("display", "display", MFnNumericData::kInt, 1);
	nAttr.setKeyable(true);
	nAttr.setMin(0);
	nAttr.setMax(1);
	addAttribute(input_display);

	input_box = nAttr.create("box", "box", MFnNumericData::kInt, 0);
	nAttr.setKeyable(true);
	nAttr.setMin(0);
	nAttr.setMax(1);
	addAttribute(input_box);
	
	input_cross = nAttr.create("cross", "cross", MFnNumericData::kInt, 1);
	nAttr.setKeyable(true);
	nAttr.setMin(0);
	nAttr.setMax(1);
	addAttribute(input_cross);

	input_tick = nAttr.create("tick", "tick", MFnNumericData::kInt, 0);
	nAttr.setKeyable(true);
	nAttr.setMin(0);
	nAttr.setMax(1);
	addAttribute(input_tick);

	input_axis = nAttr.create("axis", "axis", MFnNumericData::kInt, 0);
	nAttr.setKeyable(true);
	nAttr.setMin(0);
	nAttr.setMax(1);
	addAttribute(input_axis);
	
	MFnEnumAttribute eAttr;

	input_color = eAttr.create("color", "color", MFnData::kNumeric);
	
	eAttr.addField("Black", 0);
	eAttr.addField("Grey", 1);
	eAttr.addField("White", 2);
	eAttr.addField("Red", 3);
	eAttr.addField("Light red", 4);
	eAttr.addField("Dark red", 5);
	eAttr.addField("Green", 6);
	eAttr.addField("Light green", 7);
	eAttr.addField("Dark green", 8);
	eAttr.addField("Blue", 9);
	eAttr.addField("Light blue", 10);
	eAttr.addField("Dark blue", 11);
	eAttr.addField("Purple", 12);
	eAttr.addField("Magenta", 13);
	eAttr.addField("Brown", 14);
	eAttr.addField("Yellow", 15);
	eAttr.addField("Dark yellow", 16);
	eAttr.addField("Orange", 17);

	eAttr.setDefault(8);
	eAttr.setKeyable(true);
	eAttr.setStorable(true);
	addAttribute(input_color);

	colors.append(MColor(0.0f, 0.0f, 0.0f)); // black
	colors.append(MColor(0.5f, 0.5f, 0.5f)); // grey
	colors.append(MColor(1.0f, 1.0f, 1.0f)); // white
	colors.append(MColor(1.0f, 0.0f, 0.0f)); // red
	colors.append(MColor(1.0f, 0.6899999976158142f, 0.6899999976158142f)); // light_red
	colors.append(MColor(0.5f, 0.0f, 0.0f)); // dark_red
	colors.append(MColor(0.0f, 1.0f, 0.0f)); // green
	colors.append(MColor(0.5f, 1.0f, 0.5f)); // light_green
	colors.append(MColor(0.0f, 0.25f, 0.0f)); // dark_green
	colors.append(MColor(0.1889999955892563f, 0.6299999952316284f, 0.6299999952316284f)); // blue
	colors.append(MColor(0.3919999897480011f, 0.8629999756813049f, 1.0f)); // light_blue
	colors.append(MColor(0.0f, 0.01600000075995922f, 0.37599998712539673f)); // dark_blue
	colors.append(MColor(0.25f, 0.0f, 0.25f)); // purple
	colors.append(MColor(1.0f, 0.0f, 1.0f)); // magenta
	colors.append(MColor(0.75f, 0.2f, 0.0f)); // brown
	colors.append(MColor(1.0f, 1.0f, 0.0f)); // yellow
	colors.append(MColor(0.62117999792099f, 0.6299999952316284f, 0.1889999955892563f)); // dark_yellow
	colors.append(MColor(1.0f, 0.5f, 0.0f)); // orange

	return MS::kSuccess;
}

void Point::draw(M3dView& view, const MDagPath& mdag_path, 
				 M3dView::DisplayStyle display_style, 
				 M3dView::DisplayStatus display_status) {
	
	MObject self = thisMObject();
	
	int display = MPlug(self, input_display).asInt();
	if (display == 0) {
		return;
	}

	int use_box = MPlug(self, input_box).asInt();
	int use_cross = MPlug(self, input_cross).asInt();
	int use_tick = MPlug(self, input_tick).asInt();
	int use_axis = MPlug(self, input_axis).asInt();
	int color_index = MPlug(self, input_color).asInt();
	
	float tx = MPlug(self, Point::localPositionX).asFloat();
	float ty = MPlug(self, Point::localPositionY).asFloat();
	float tz = MPlug(self, Point::localPositionZ).asFloat();

	float sx = MPlug(self, Point::localScaleX).asFloat();
	float sy = MPlug(self, Point::localScaleY).asFloat();
	float sz = MPlug(self, Point::localScaleZ).asFloat();
	
	MColor color;
	switch (display_status) {
	case M3dView::kActive:
		color = MColor(1.0f, 1.0f, 1.0f);
		break;
	case M3dView::kLead:
		color = MColor(0.26f, 1.0f, 0.64f);
		break;
	case M3dView::kActiveAffected:
		color = MColor(0.783999979496f, 0.0f, 0.783999979496f);
		break;
	case M3dView::kTemplate:
		color = MColor(0.469999998808f, 0.469999998808f, 0.469999998808f);
		break;
	case M3dView::kActiveTemplate:
		color = MColor(1.0f, 0.689999997616f, 0.689999997616f);
		break;
	default:
		color = colors[color_index];
	}
	
	view.beginGL();
	
	if (use_axis == 1) {
		view.setDrawColor(MColor(1.0, 0, 0));
		view.drawText("x", MPoint(sx + tx, ty, tz), M3dView::kCenter);

		view.setDrawColor(MColor(0, 1.0, 0));
		view.drawText("y", MPoint(tx, sy + ty, tz), M3dView::kCenter);

		view.setDrawColor(MColor(0, 0, 1.0));
		view.drawText("z", MPoint(tx, ty, sz + tz), M3dView::kCenter);
	}

	glPushAttrib(GL_CURRENT_BIT);
	glEnable(GL_BLEND);
	glBegin(GL_LINES);

	if (use_box == 1) {
		glColor3f(color.r, color.g, color.b);

		// Top
		glVertex3f(-sx + tx, sy + ty, -sz + tz);
		glVertex3f(sx + tx, sy + ty, -sz + tz);

		glVertex3f(sx + tx, sy + ty, -sz + tz);
		glVertex3f(sx + tx, sy + ty, sz + tz);

		glVertex3f(sx + tx, sy + ty, sz + tz);
		glVertex3f(-sx + tx, sy + ty, sz + tz);

		glVertex3f(-sx + tx, sy + ty, sz + tz);
		glVertex3f(-sx + tx, sy + ty, -sz + tz);

		// Bottom
		glVertex3f(-sx + tx, -sy + ty, -sz + tz);
		glVertex3f(sx + tx, -sy + ty, -sz + tz);

		glVertex3f(sx + tx, -sy + ty, -sz + tz);
		glVertex3f(sx + tx, -sy + ty, sz + tz);

		glVertex3f(sx + tx, -sy + ty, sz + tz);
		glVertex3f(-sx + tx, -sy + ty, sz + tz);

		glVertex3f(-sx + tx, -sy + ty, sz + tz);
		glVertex3f(-sx + tx, -sy + ty, -sz + tz);

		// Left
		glVertex3f(-sx + tx, -sy + ty, -sz + tz);
		glVertex3f(-sx + tx, sy + ty, -sz + tz);

		glVertex3f(-sx + tx, sy + ty, -sz + tz);
		glVertex3f(-sx + tx, sy + ty, sz + tz);

		glVertex3f(-sx + tx, sy + ty, sz + tz);
		glVertex3f(-sx + tx, -sy + ty, sz + tz);

		glVertex3f(-sx + tx, -sy + ty, sz + tz);
		glVertex3f(-sx + tx, -sy + ty, -sz + tz);

		// Right
		glVertex3f(sx + tx, -sy + ty, -sz + tz);
		glVertex3f(sx + tx, sy + ty, -sz + tz);

		glVertex3f(sx + tx, sy + ty, -sz + tz);
		glVertex3f(sx + tx, sy + ty, sz + tz);

		glVertex3f(sx + tx, sy + ty, sz + tz);
		glVertex3f(sx + tx, -sy + ty, sz + tz);

		glVertex3f(sx + tx, -sy + ty, sz + tz);
		glVertex3f(sx + tx, -sy + ty, -sz + tz);
	}

	if (use_cross == 1) {
		glColor3f(color.r, color.g, color.b);

		glVertex3f(tx, -sy + ty, tz);
		glVertex3f(tx, sy + ty, tz);

		glVertex3f(-sx + tx, ty, tz);
		glVertex3f(sx + tx, ty, tz);

		glVertex3f(tx, ty, -sz + tz);
		glVertex3f(tx, ty, sz + tz);
	}

	if (use_tick == 1) {
		glColor3f(color.r, color.g, color.b);

		glVertex3f((-sx*0.05f) + tx, (sy*0.05f) + ty, tz);
		glVertex3f((sx*0.05f) + tx, (-sy*0.05f) + ty, tz);

		glVertex3f((sx*0.05f) + tx, (sy*0.05f) + ty, tz);
		glVertex3f((-sx*0.05f) + tx, (-sy*0.05f) + ty, tz);

		glVertex3f(tx, (sy*0.05f) + ty, (-sz*0.05f) + tz);
		glVertex3f(tx, (-sy*0.05f) + ty, (sz*0.05f) + tz);

		glVertex3f(tx, (sy*0.05f) + ty, (sz*0.05f) + tz);
		glVertex3f(tx, (-sy*0.05f) + ty, (-sz*0.05f) + tz);

		glVertex3f((sx*0.05f) + tx, ty, (-sz*0.05f) + tz);
		glVertex3f((-sx*0.05f) + tx, ty, (sz*0.05f) + tz);

		glVertex3f((sx*0.05f) + tx, ty, (sz*0.05f) + tz);
		glVertex3f((-sx*0.05f) + tx, ty, (-sz*0.05f) + tz);
	}

	if (use_axis == 1) {
		glColor3f(color.r, color.g, color.b);

		if (display_status == M3dView::kDormant) {
			glColor3f(1.0f, 0.0f, 0.0f);
		}
		glVertex3f(tx, ty, tz);
		glVertex3f(sx + tx, ty, tz);

		if (display_status == M3dView::kDormant) {
			glColor3f(0.0f, 1.0f, 0.0f);
		}
		glVertex3f(tx, ty, tz);
		glVertex3f(tx, sy + ty, tz);

		if (display_status == M3dView::kDormant) {
			glColor3f(0.0f, 0.0f, 1.0f);
		}
		glVertex3f(tx, ty, tz);
		glVertex3f(tx, ty, sz + tz);
	}

	glEnd();
	glDisable(GL_BLEND);
	glPopAttrib();

	view.endGL();
}
