"""
Author: Jason Labbe

Locator node that tries to mimic 3Ds Max's point helper display style.

Bugs:
    - Default name isn't set on creation.
"""

import maya.OpenMayaMPx as OpenMayaMPx
import maya.OpenMaya as OpenMaya
import maya.OpenMayaUI as OpenMayaUI
import maya.OpenMayaRender as OpenMayaRender


gl_renderer = OpenMayaRender.MHardwareRenderer.theRenderer()
gl_FT = gl_renderer.glFunctionTable()
commandName = 'point'


class Point(OpenMayaMPx.MPxLocatorNode):
    kPluginNodeId = OpenMaya.MTypeId(0x90000002)
    input_box = OpenMaya.MObject()
    input_cross = OpenMaya.MObject()
    input_tick = OpenMaya.MObject()
    input_axis = OpenMaya.MObject()
    input_color = OpenMaya.MObject()
    
    def __init__(self):
        OpenMayaMPx.MPxLocatorNode.__init__(self)
        self._size = 1.0
        self._colors = [(0, 0, 0), # black
                        (0.5, 0.5, 0.5), # grey
                        (1.0, 1.0, 1.0), # white
                        (1.0, 0, 0), # red
                        (1.0, 0.6899999976158142, 0.6899999976158142), # light_red
                        (0.5, 0, 0), # dark_red
                        (0, 1.0, 0), # green
                        (0.5, 1.0, 0.5), # light_green
                        (0, 0.25, 0),# dark_green
                        (0.1889999955892563, 0.6299999952316284, 0.6299999952316284), # blue
                        (0.3919999897480011, 0.8629999756813049, 1.0), # light_blue
                        (0.0, 0.01600000075995922, 0.37599998712539673), # dark_blue
                        (0.25, 0, 0.25), # purple
                        (1.0, 0, 1.0), # magenta
                        (0.75, 0.2, 0), # brown
                        (1.0, 1.0, 0), # yellow
                        (0.62117999792099, 0.6299999952316284, 0.1889999955892563), # dark_yellow
                        (1.0, 0.5, 0)] # orange
    
    def draw(self, view, mdag_path, display_style, display_status):
        use_box = OpenMaya.MPlug(self.thisMObject(), Point.input_box).asInt()
        use_cross = OpenMaya.MPlug(self.thisMObject(), Point.input_cross).asInt()
        use_tick = OpenMaya.MPlug(self.thisMObject(), Point.input_tick).asInt()
        use_axis = OpenMaya.MPlug(self.thisMObject(), Point.input_axis).asInt()
        color_index = OpenMaya.MPlug(self.thisMObject(), Point.input_color).asInt()
        
        local_position = OpenMaya.MFnDependencyNode(self.thisMObject()).findPlug("localPosition")
        tx = local_position.child(0).asFloat()
        ty = local_position.child(1).asFloat()
        tz = local_position.child(2).asFloat()
        
        local_scale = OpenMaya.MFnDependencyNode(self.thisMObject()).findPlug("localScale")
        sx = local_scale.child(0).asFloat()
        sy = local_scale.child(1).asFloat()
        sz = local_scale.child(2).asFloat()
        
        if display_status == OpenMayaUI.M3dView.kActive:
            color = OpenMaya.MColor(1.0, 1.0, 1.0)
        elif display_status == OpenMayaUI.M3dView.kLead:
            color = OpenMaya.MColor(0.26, 1.0, 0.64)
        elif display_status == OpenMayaUI.M3dView.kActiveAffected:
            color = OpenMaya.MColor(0.783999979496, 0, 0.783999979496)
        elif display_status == OpenMayaUI.M3dView.kTemplate:
            color = OpenMaya.MColor(0.469999998808, 0.469999998808, 0.469999998808)
        elif display_status == OpenMayaUI.M3dView.kActiveTemplate:
            color = OpenMaya.MColor(1.0, 0.689999997616, 0.689999997616)
        else:
            color = OpenMaya.MColor(self._colors[color_index][0], 
                                    self._colors[color_index][1], 
                                    self._colors[color_index][2])
        
        view.beginGL()
        
        if use_axis == 1:
            view.setDrawColor( OpenMaya.MColor(1.0, 0, 0) )
            view.drawText("x", OpenMaya.MPoint(sx+tx, ty, tz), OpenMayaUI.M3dView.kCenter)
            
            view.setDrawColor( OpenMaya.MColor(0, 1.0, 0) )
            view.drawText("y", OpenMaya.MPoint(tx, sy+ty, tz), OpenMayaUI.M3dView.kCenter)
            
            view.setDrawColor( OpenMaya.MColor(0, 0, 1.0) )
            view.drawText("z", OpenMaya.MPoint(tx, ty, sz+tz), OpenMayaUI.M3dView.kCenter)
        
        gl_FT.glPushAttrib(OpenMayaRender.MGL_CURRENT_BIT)
        gl_FT.glPushAttrib(OpenMayaRender.MGL_ALL_ATTRIB_BITS)
        gl_FT.glEnable(OpenMayaRender.MGL_BLEND)
        
        gl_FT.glBegin(OpenMayaRender.MGL_LINES)
        
        if use_box == 1:
            gl_FT.glColor3f(color.r, color.g, color.b)
            
            # Top
            gl_FT.glVertex3f(-sx+tx, sy+ty, -sz+tz)
            gl_FT.glVertex3f(sx+tx, sy+ty, -sz+tz)
            
            gl_FT.glVertex3f(sx+tx, sy+ty, -sz+tz)
            gl_FT.glVertex3f(sx+tx, sy+ty, sz+tz)
            
            gl_FT.glVertex3f(sx+tx, sy+ty, sz+tz)
            gl_FT.glVertex3f(-sx+tx, sy+ty, sz+tz)
            
            gl_FT.glVertex3f(-sx+tx, sy+ty, sz+tz)
            gl_FT.glVertex3f(-sx+tx, sy+ty, -sz+tz)
            
            # Bottom
            gl_FT.glVertex3f(-sx+tx, -sy+ty, -sz+tz)
            gl_FT.glVertex3f(sx+tx, -sy+ty, -sz+tz)
            
            gl_FT.glVertex3f(sx+tx, -sy+ty, -sz+tz)
            gl_FT.glVertex3f(sx+tx, -sy+ty, sz+tz)
            
            gl_FT.glVertex3f(sx+tx, -sy+ty, sz+tz)
            gl_FT.glVertex3f(-sx+tx, -sy+ty, sz+tz)
            
            gl_FT.glVertex3f(-sx+tx, -sy+ty, sz+tz)
            gl_FT.glVertex3f(-sx+tx, -sy+ty, -sz+tz)
            
            # Left
            gl_FT.glVertex3f(-sx+tx, -sy+ty, -sz+tz)
            gl_FT.glVertex3f(-sx+tx, sy+ty, -sz+tz)
            
            gl_FT.glVertex3f(-sx+tx, sy+ty, -sz+tz)
            gl_FT.glVertex3f(-sx+tx, sy+ty, sz+tz)
            
            gl_FT.glVertex3f(-sx+tx, sy+ty, sz+tz)
            gl_FT.glVertex3f(-sx+tx, -sy+ty, sz+tz)
            
            gl_FT.glVertex3f(-sx+tx, -sy+ty, sz+tz)
            gl_FT.glVertex3f(-sx+tx, -sy+ty, -sz+tz)
            
            # Right
            gl_FT.glVertex3f(sx+tx, -sy+ty, -sz+tz)
            gl_FT.glVertex3f(sx+tx, sy+ty, -sz+tz)
            
            gl_FT.glVertex3f(sx+tx, sy+ty, -sz+tz)
            gl_FT.glVertex3f(sx+tx, sy+ty, sz+tz)
            
            gl_FT.glVertex3f(sx+tx, sy+ty, sz+tz)
            gl_FT.glVertex3f(sx+tx, -sy+ty, sz+tz)
            
            gl_FT.glVertex3f(sx+tx, -sy+ty, sz+tz)
            gl_FT.glVertex3f(sx+tx, -sy+ty, -sz+tz)
        
        if use_cross == 1:
            gl_FT.glColor3f(color.r, color.g, color.b)
            
            gl_FT.glVertex3f(tx, -sy+ty, tz)
            gl_FT.glVertex3f(tx, sy+ty, tz)
            
            gl_FT.glVertex3f(-sx+tx, ty, tz)
            gl_FT.glVertex3f(sx+tx, ty, tz)
            
            gl_FT.glVertex3f(tx, ty, -sz+tz)
            gl_FT.glVertex3f(tx, ty, sz+tz)
        
        if use_tick == 1:
            gl_FT.glColor3f(color.r, color.g, color.b)
            
            gl_FT.glVertex3f((-sx*0.05)+tx, (sy*0.05)+ty, tz)
            gl_FT.glVertex3f((sx*0.05)+tx, (-sy*0.05)+ty, tz)
            
            gl_FT.glVertex3f((sx*0.05)+tx, (sy*0.05)+ty, tz)
            gl_FT.glVertex3f((-sx*0.05)+tx, (-sy*0.05)+ty, tz)
            
            gl_FT.glVertex3f(tx, (sy*0.05)+ty, (-sz*0.05)+tz)
            gl_FT.glVertex3f(tx, (-sy*0.05)+ty, (sz*0.05)+tz)
            
            gl_FT.glVertex3f(tx, (sy*0.05)+ty, (sz*0.05)+tz)
            gl_FT.glVertex3f(tx, (-sy*0.05)+ty, (-sz*0.05)+tz)
            
            gl_FT.glVertex3f((sx*0.05)+tx, ty, (-sz*0.05)+tz)
            gl_FT.glVertex3f((-sx*0.05)+tx, ty, (sz*0.05)+tz)
            
            gl_FT.glVertex3f((sx*0.05)+tx, ty, (sz*0.05)+tz)
            gl_FT.glVertex3f((-sx*0.05)+tx, ty, (-sz*0.05)+tz)
        
        if use_axis == 1:
            gl_FT.glColor3f(color.r, color.g, color.b)
            
            if display_status == OpenMayaUI.M3dView.kDormant:
                gl_FT.glColor3f(1.0, 0, 0)
            gl_FT.glVertex3f(tx, ty, tz)
            gl_FT.glVertex3f(sx+tx, ty, tz)
            
            if display_status == OpenMayaUI.M3dView.kDormant:
                gl_FT.glColor3f(0, 1.0, 0)
            gl_FT.glVertex3f(tx, ty, tz)
            gl_FT.glVertex3f(tx, sy+ty, tz)
            
            if display_status == OpenMayaUI.M3dView.kDormant:
                gl_FT.glColor3f(0, 0, 1.0)
            gl_FT.glVertex3f(tx, ty, tz)
            gl_FT.glVertex3f(tx, ty, sz+tz)
            
        gl_FT.glEnd()
        
        gl_FT.glDisable(OpenMayaRender.MGL_BLEND)
        gl_FT.glPopAttrib()
        gl_FT.glPopAttrib()
        
        view.endGL()


def nodeCreator():
    return OpenMayaMPx.asMPxPtr( Point() )


def nodeInitializer():
    nAttr = OpenMaya.MFnNumericAttribute()
    
    Point.input_box = nAttr.create("box", "box", OpenMaya.MFnNumericData.kInt, 0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_box)
    
    Point.input_cross = nAttr.create("cross", "cross", OpenMaya.MFnNumericData.kInt, 1)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_cross)
    
    Point.input_tick = nAttr.create("tick", "tick", OpenMaya.MFnNumericData.kInt, 0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_tick)
    
    Point.input_axis = nAttr.create("axis", "axis", OpenMaya.MFnNumericData.kInt, 0)
    nAttr.setKeyable(True)
    nAttr.setMin(0)
    nAttr.setMax(1)
    Point.addAttribute(Point.input_axis)
    
    eAttr = OpenMaya.MFnEnumAttribute()
    
    Point.input_color = eAttr.create("temp", "temp", OpenMaya.MFnData.kNumeric)
    colors = ["Black",
              "Grey",
              "White",
              "Red",
              "Light red",
              "Dark red",
              "Green",
              "Light green",
              "Dark green",
              "Blue",
              "Light blue",
              "Dark blue",
              "Purple",
              "Magenta",
              "Brown",
              "Yellow",
              "Dark yellow",
              "Orange"]
    for i, name in enumerate(colors):
        eAttr.addField(name, i)
    eAttr.setDefault(colors.index("Dark green"))
    eAttr.setKeyable(True)
    eAttr.setStorable(True)
    Point.addAttribute(Point.input_color)


def initializePlugin(obj):
    plugin = OpenMayaMPx.MFnPlugin(obj, 'Jason Labbe', '1.0', 'Any')
    try:
        print 'Loading point node'
        plugin.registerNode(commandName, 
                            Point.kPluginNodeId, 
                            nodeCreator, 
                            nodeInitializer,
                            OpenMayaMPx.MPxNode.kLocatorNode)
    except:
        raise RuntimeError, 'Failed to register node: {0}'.format(commandName)


def uninitializePlugin(obj):
    plugin = OpenMayaMPx.MFnPlugin(obj)
    try:
        plugin.deregisterNode(Point.kPluginNodeId)
    except:
        raise RuntimeError, 'Failed to register node: {0}'.format(commandName)
