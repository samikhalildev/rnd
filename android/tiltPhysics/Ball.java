package greencell.tiltPhysics;

import android.view.View;
import android.graphics.Paint;
import android.graphics.Canvas;
import android.graphics.Color;


/**
 * A ball that is influenced by 2d forces.
 */
public class Ball {
    public boolean active = true;
    public int radius = 100;
    public double mass = 1.0;
    public int color = Color.rgb(255, 0, 0);
    public double netForce = 0;

    public Vector2d pos = new Vector2d(720, 1054);
    public Vector2d vel = new Vector2d(0, 0);
    public Vector2d acc = new Vector2d(0, 0);
    public Vector2d gravity = new Vector2d(0, 0);

    private View parent = null;

    public Ball(View view) {
        this.parent = view;
    }

    /*
     * Adds a force to its acceleration.
     */
    public void applyForce(Vector2d force) {
        Vector2d forceCopy = force.copy();
        forceCopy.div(this.mass);
        this.acc.add(forceCopy);
    }

    /*
     * Checks if this ball is colliding against supplied ball.
     * If they are, their velocities will change and their positions will
     * offset to stop touching.
     */
    public void doCollision(Ball otherBall) {
        // First determine if there is a collision
        double dist = this.pos.distance(otherBall.pos);
        boolean isColliding = dist < (this.radius + otherBall.radius);
        if (! isColliding) {
            return;
        }

        // Offset so they aren't touching anymore
        Vector2d difference = otherBall.pos.copy();
        difference.sub(this.pos);
        difference.normalize();
        double penetrationAmount = dist - (this.radius + otherBall.radius);
        difference.mult(penetrationAmount / 2.0);
        this.pos.add(difference);
        otherBall.pos.sub(difference);

        // Change this velocity
        double mag = this.vel.mag();
        Vector2d newVel = this.pos.copy();
        newVel.sub(otherBall.pos);
        newVel.normalize();
        newVel.mult(mag * 0.9);
        this.vel = newVel;

        // Change other velocity
        double otherMag = otherBall.vel.mag();
        Vector2d newOtherVel = otherBall.pos.copy();
        newOtherVel.sub(this.pos);
        newOtherVel.normalize();
        newOtherVel.mult(otherMag * 0.9);
        otherBall.vel = newOtherVel;

        // Force both balls back into bounds
        this.limitToBounds();
        otherBall.limitToBounds();
    }

    /*
     * Clamps the supplied position to the screen's boundaries.
     */
    public void clampToScreen(Vector2d pos) {
        double screenLeft = 0+this.radius;
        double screenRight = this.parent.getWidth()-this.radius;
        double screenTop = 0+this.radius;
        double screenBottom = this.parent.getHeight()-this.radius;
        pos.x = Math.max(Math.min(pos.x, screenRight), screenLeft);
        pos.y = Math.max(Math.min(pos.y, screenBottom), screenTop);
    }

    /*
     * If this ball is out of bounds, it clamps its position to the screen,
     * changes its velocity accordingly, then adds friction.
     */
    public void limitToBounds() {
        double oldPosX = this.pos.x;
        double oldPosY = this.pos.y;

        this.clampToScreen(this.pos);

        if (oldPosX != this.pos.x) {
            this.vel.x *= -1;
        }

        if (oldPosY != this.pos.y) {
            this.vel.y *= -1;
        }

        // If it was out of bounds, add some friction
        if (oldPosX != this.pos.x || oldPosY != this.pos.y) {
            Vector2d friction = new Vector2d(this.vel.x, this.vel.y);
            friction.normalize();
            friction.mult(-1);
            friction.mult(0.2); // Random friction coefficient
            this.applyForce(friction);
        }
    }

    /*
     * Simulates an iteration of the ball going through the physics engine.
     */
    public void sim() {
        // Add gravity
        Vector2d gravityCopy = gravity.copy();
        gravityCopy.mult(0.75);
        this.applyForce(gravityCopy);

        // Add air drag
        Vector2d drag = new Vector2d(this.vel.x, this.vel.y);
        double dragMag = drag.mag();
        drag.normalize();
        drag.mult(-1);
        double dragCoefficient = 0.002;
        drag.mult((dragCoefficient * dragMag * dragMag * this.mass));
        this.applyForce(drag);

        this.vel.add(this.acc);

        // Calculate net force by getting distance of current and last positions
        Vector2d newPos = this.pos.copy();
        newPos.add(this.vel);
        this.clampToScreen(newPos);
        this.netForce = newPos.distance(this.pos);

        // Kill energy if its net force is low enough
        if (this.netForce > 0.1) {
            this.pos.add(this.vel);
        } else {
            this.vel.mult(0);
        }

        this.acc.mult(0);
    }

    /*
     * Draws this ball onto the screen.
     * An update to the view needs to be called.
     */
    public void draw(Paint paint, Canvas canvas) {
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(this.color);
        canvas.drawCircle((float) this.pos.x, (float) this.pos.y, this.radius, paint);

        paint.setStyle(Paint.Style.STROKE);
        paint.setColor(Color.BLACK);
        paint.setStrokeWidth(10);
        canvas.drawCircle((float) this.pos.x, (float) this.pos.y, this.radius, paint);
    }
}