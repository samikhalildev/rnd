package greencell.tiltPhysics;

import java.util.Arrays;
import java.util.List;


/**
 * Simple class to deal with 2d vector operations.
 */
public class Vector2d {
    double x = 0;
    double y = 0;

    public Vector2d(double xValue, double yValue) {
        this.x = xValue;
        this.y = yValue;
    }

    public void add(Vector2d vector) {
        this.x += vector.x;
        this.y += vector.y;
    }

    public void sub(Vector2d vector) {
        this.x -= vector.x;
        this.y -= vector.y;
    }

    public void mult(double scalar) {
        this.x *= scalar;
        this.y *= scalar;
    }

    public void div(double scalar) {
        if (scalar != 0) {
            this.x /= scalar;
            this.y /= scalar;
        }
    }

    public List<Double> get() {
        return Arrays.asList(this.x, this.y);
    }

    public void set(double xValue, double yValue) {
        this.x = xValue;
        this.y = yValue;
    }

    public double mag() {
        return Math.sqrt( (this.x * this.x) + (this.y * this.y) );
    }

    public void normalize() {
        double length = this.mag();
        this.div(length);
    }

    public double distance(Vector2d vector) {
        return Math.sqrt( ( (vector.x - this.x) * (vector.x - this.x) ) + ( (vector.y - this.y) * (vector.y - this.y) ) );
    }

    public double dot(Vector2d vector) {
        return (this.x * vector.x)+(this.y * vector.y);
    }

    public Vector2d copy() {
        return new Vector2d(this.x, this.y);
    }
}