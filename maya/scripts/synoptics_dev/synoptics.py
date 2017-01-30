"""
import sys

path = "C:\Users\GreenCell\workspace\python_scripts"

if path not in sys.path:
    sys.path.insert(0, path)
    
import synoptics
reload(synoptics)
"""

"""
To do:
    - Hold ctrl to move point.
    - Click on point to remove it.
    - Right-click to close shape.
"""

import shiboken

import maya.cmds as cmds
import maya.OpenMaya as OpenMaya
import maya.OpenMayaUI as OpenMayaUI

from PySide import QtGui
from PySide import QtCore


class ControlPoint(object):
    
    Linear = 0
    Bezier = 1
    
    def __init__(self, x, y, scene, point_type=0, size=10):
        self.point_size = size
        self.point_type = point_type
        self.color = QtGui.QColor(0, 255, 0)
        
        self.control = QtGui.QGraphicsRectItem(-size/2, -size/2, 
                                               size, size, 
                                               scene=scene)
        self.control.setPos(x, y)
        '''self.control.setFlags(QtGui.QGraphicsItem.ItemIsMovable | 
                              QtGui.QGraphicsItem.ItemIsSelectable)'''
        self.set_item_color(self.control, self.color)
        
        self.handle_1 = None
        self.handle_2 = None
        
        if self.point_type == ControlPoint.Bezier:
            self.create_handle()
    
    def remove_handles(self):
        self.point_type = ControlPoint.Linear
        
        all_items = [self.handle_1, self.handle_2]
        
        for item in all_items:
            if item is None:
                continue
            
            item.scene().removeItem(item)
            item = None
    
    def create_handles(self, size=8):
        self.remove_handles()
        
        self.point_type = ControlPoint.Bezier
        
        scene = self.control.scene()
        
        self.handle_1 = QtGui.QGraphicsEllipseItem(-size/2, -size/2, 
                                                   size, size, 
                                                   scene=scene, 
                                                   parent=self.control)
        self.set_item_color(self.handle_1, QtGui.QColor(255, 255, 0))
        
        self.handle_2 = QtGui.QGraphicsEllipseItem(-size/2, -size/2, 
                                                   size, size, 
                                                   scene=scene, 
                                                   parent=self.control)
        self.set_item_color(self.handle_2, QtGui.QColor(0, 255, 255))
    
    def set_item_color(self, item, color):
        item.setBrush(color)
        
        pen = QtGui.QPen()
        pen.setStyle(QtCore.Qt.NoPen)
        item.setPen(pen)

class Scene(QtGui.QGraphicsScene):
    
    def __init__(self, parent=None):
        super(Scene, self).__init__(parent)
    
    def drawForeground(self, painter, rect):
        view = self.views()[0]
        
        # Forces whole view to update instead of partial.
        view.viewport().update()
        
        painter.setRenderHint(QtGui.QPainter.Antialiasing)
        
        painter.begin(view)
        
        if view.points:
            pen = QtGui.QPen(QtCore.Qt.white, 2, QtCore.Qt.DashLine)
            painter.setPen(pen)
            
            for point in view.points:
                if point.point_type != ControlPoint.Bezier:
                    continue
                
                painter.drawLine(point.handle_1.scenePos().x(), point.handle_1.scenePos().y(), 
                                 point.handle_2.scenePos().x(), point.handle_2.scenePos().y());
        painter.end()
        
        return QtGui.QGraphicsScene.drawBackground(self, painter, rect)

class View(QtGui.QGraphicsView):
    
    def __init__(self, parent=None):
        super(View, self).__init__(parent)
        
        self.scene = Scene()
        self.setScene(self.scene)
        
        self.setRubberBandSelectionMode(QtCore.Qt.IntersectsItemShape)
        #self.setDragMode(QtGui.QGraphicsView.RubberBandDrag)
        
        self.item = None
        self.points = []
    
    def showEvent(self, event):
        self.setSceneRect(0, 0, 
                          self.viewport().width(), 
                          self.viewport().height())
        
        return QtGui.QGraphicsView.showEvent(self, event)
    
    def add_point(self, x, y):
        point = ControlPoint(x, y, self.scene, point_type=ControlPoint.Linear)
        
        self.points.append(point)
    
    def draw_item(self):
        if not self.points:
            return
        
        item_path = QtGui.QPainterPath(QtCore.QPointF(self.points[0].control.scenePos().x(), 
                                                      self.points[0].control.scenePos().y()))
        
        for i, point in enumerate(self.points):
            if i < len(self.points)-1:
                next_point = self.points[i+1]
                next_point_type = next_point.point_type
            else:
                if self.points[-1].point_type != ControlPoint.Linear:
                    continue
                next_point = self.points[0]
                next_point_type = ControlPoint.Linear
            
            if point.point_type == ControlPoint.Linear and next_point_type == ControlPoint.Linear:
                # Linear to linear.
                item_path.lineTo(point.control.scenePos().x(), 
                                 point.control.scenePos().y())
            elif point.point_type == ControlPoint.Linear and next_point_type == ControlPoint.Bezier:
                # Linear to bezier.
                item_path.lineTo(point.control.scenePos().x(), 
                                 point.control.scenePos().y())
                item_path.quadTo(next_point.handle_1.scenePos().x(), 
                                 next_point.handle_1.scenePos().y(), 
                                 next_point.control.scenePos().x(), 
                                 next_point.control.scenePos().y())
            elif point.point_type == ControlPoint.Bezier and next_point_type == ControlPoint.Linear:
                # Bezier to linear.
                item_path.quadTo(point.handle_2.scenePos().x(), 
                                 point.handle_2.scenePos().y(), 
                                 next_point.control.scenePos().x(), 
                                 next_point.control.scenePos().y())
            elif point.point_type == ControlPoint.Bezier and next_point_type == ControlPoint.Bezier:
                # Bezier to bezier.
                item_path.cubicTo(point.handle_2.scenePos().x(), 
                                  point.handle_2.scenePos().y(), 
                                  next_point.handle_1.scenePos().x(), 
                                  next_point.handle_1.scenePos().y(), 
                                  next_point.control.scenePos().x(), 
                                  next_point.control.scenePos().y())
        
        self.item.setPath(item_path)
        
        self.item.update()
    
    def get_closest_point(self, x, y):
        pos_1 = QtGui.QVector2D(x, y)
        for point in self.points:
            pos_2 = QtGui.QVector2D(point.control.pos().x(), 
                                    point.control.pos().y())
            pos_2 -= pos_1
            
            if pos_2.length() < point.point_size:
                return point
    
    def mousePressEvent(self, event):
        QtGui.QGraphicsView.mousePressEvent(self, event)
        
        #if event.modifiers() == QtCore.Qt.CTRL:
            #return
        
        scene_pos = self.mapToScene(event.pos().x(), 
                                    event.pos().y())
        
        x = scene_pos.x()
        y = scene_pos.y()
        
        #hit_point = self.get_closest_point(x, y)
        
        if self.scene.selectedItems():
            pass
        else:
            self.add_point(x, y)
            
            self.draw_item()
    
    def mouseReleaseEvent(self, event):
        if self.points:
            self.points[-1].control.setFlags(QtGui.QGraphicsItem.ItemIsMovable | 
                                             QtGui.QGraphicsItem.ItemIsSelectable)
            
        return QtGui.QGraphicsView.mouseReleaseEvent(self, event)
    
    def mouseMoveEvent(self, event):
        ret_value = QtGui.QGraphicsView.mouseMoveEvent(self, event)
        
        if not self.points:
            return ret_value
        
        if not self.scene.selectedItems():
            # Doesn't convert to bezier until it exceeds a distance from the control point.
            if self.points[-1].point_type == ControlPoint.Linear:
                scene_pos = self.mapToScene(event.pos().x(), 
                                            event.pos().y())
                
                pos_1 = QtGui.QVector2D(scene_pos.x(), 
                                        scene_pos.y())
                
                pos_2 = QtGui.QVector2D(self.points[-1].control.pos().x(), 
                                        self.points[-1].control.pos().y())
                
                pos_1 -= pos_2
                
                if pos_1.length() < 15:
                    return ret_value
            
            if self.points[-1].handle_1 is None:
                self.points[-1].create_handles()
            
            self.points[-1].handle_1.setPos(event.pos().x()-self.points[-1].control.pos().x(), 
                                            event.pos().y()-self.points[-1].control.pos().y())
            
            # Calculate other handle's position.
            control_vec = QtGui.QVector2D(self.points[-1].control.pos().x(), 
                                          self.points[-1].control.pos().y())
            
            handle_vec = QtGui.QVector2D(event.pos().x(), 
                                         event.pos().y())
            
            vec = handle_vec-control_vec
            
            other_handle_pos = control_vec-vec
            
            self.points[-1].handle_2.setPos(other_handle_pos.x()-self.points[-1].control.pos().x(), 
                                            other_handle_pos.y()-self.points[-1].control.pos().y())
        
        self.draw_item()
        
        return ret_value


class SynopticsDesigner(QtGui.QDialog):
    
    def __init__(self, parent=None):
        super(SynopticsDesigner, self).__init__(parent)
        
        maya_window_pointer = OpenMayaUI.MQtUtil.mainWindow()
        self.maya_main_window = shiboken.wrapInstance(long(maya_window_pointer), 
                                                      QtGui.QMainWindow)
        self.setParent(self.maya_main_window)
        
        self.setWindowFlags(QtCore.Qt.Window)
        
        self.setup_gui()
    
    def setup_gui(self):
        self.create_gui()
    
    def create_gui(self):
        self.view = View(parent=self)
        
        self.main_layout = QtGui.QVBoxLayout()
        self.main_layout.addWidget(self.view)
        self.setLayout(self.main_layout)
        
        self.setWindowTitle("Synoptics")
        self.resize(800, 800)
        
        self.view.item = QtGui.QGraphicsPathItem(scene=self.view.scene)
        '''self.view.item.setFlags(QtGui.QGraphicsItem.ItemIsMovable | 
                           QtGui.QGraphicsItem.ItemIsSelectable)'''
        self.view.item.setBrush(QtGui.QColor(255, 0, 0))


if __name__ == "synoptics":
    tool = SynopticsDesigner()
    tool.show()