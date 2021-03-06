"""
Spring dynamics

To do:
    - Auto-create locator at object to steer to.
    - Work with rotations.
"""

import numpy
import maya.cmds as cmds
import maya.OpenMaya as OpenMaya


def obj_to_vector(obj):
    pos = cmds.xform(obj, q=True, ws=True, t=True)
    return OpenMaya.MVector(pos[0], pos[1], pos[2])


def map(value, in_min, in_max, out_min, out_max):
    return numpy.interp(value, [in_min, in_max], [out_min, out_max])


class DynamicObj():
    
    def __init__(self, obj, parent, max_force):
        self.obj = obj
        self.parent = parent
        self.max_force = max_force
        self.max_vel = 2
        
        self.pos = obj_to_vector(obj)
        self.vel = OpenMaya.MVector(0, 0, 0)
        self.acc = OpenMaya.MVector(0, 0, 0)
    
    def move(self):
        # Figure out how much force it should use.
        dist_threshold = 20
        
        end_pos = obj_to_vector(self.parent)
        end_pos -= self.pos
        distance = end_pos.length()
        
        force = map(min(distance, dist_threshold), 0, dist_threshold, 0, self.max_force)
        
        # Move towards target.
        push = obj_to_vector(self.parent)
        push -= self.pos
        push.normalize()
        push *= force
        self.acc += push
        
        self.vel *= 0.9
        
        # Limit velocity.
        if self.vel.length() > self.max_vel:
            self.vel.normalize()
            self.vel *= self.max_vel
        
        # Move it.
        self.vel += self.acc
        self.pos += self.vel
        self.acc *= 0
        
    def update_obj(self):
        cmds.xform(self.obj, ws=True, t=[self.pos.x, self.pos.y, self.pos.z])
                     
        cmds.setKeyframe("{0}.t".format(self.obj))


def sim(dyn_obj, start_frame, end_frame, steps=1):
    for f in range(start_frame, end_frame):
        cmds.currentTime(f)
        
        dyn_obj.move()
        
        if f % steps == 0:
            dyn_obj.update_obj()


dyn_obj = DynamicObj("pCone1", "locator1", 5)
sim(dyn_obj, 1, 300, steps=1)
