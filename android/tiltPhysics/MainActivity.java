/*
 * Custom physics engine to simulate balls falling based on where the phone is tilted.
 *
 * Author: Jason Labbe
 *
 * Bugs: - Balls may begin to jitter if too many are stacked.
 */

package greencell.tiltPhysics;

import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.hardware.Sensor;

import java.util.ArrayList;
import java.util.List;


public class MainActivity extends AppCompatActivity {
    public List<Ball> balls = new ArrayList<>();
    public Ball newBall = null;
    public Vector2d gravity = new Vector2d(0, 0);
    final float[] sensorGravityValues = new float[3];

    private void doNextFrame() {
        for (Ball ball : balls) {
            if (! ball.active) {
                continue;
            }

            ball.gravity.set(gravity.x, gravity.y);
            ball.sim();
            ball.limitToBounds();
        }

        for (Ball ball : balls) {
            if (! ball.active) {
                continue;
            }

            for (Ball otherBall : balls) {
                if (ball == otherBall) {
                    continue;
                }
                ball.doCollision(otherBall);
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(new MainView(this));
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        SensorManager sensorManager = (SensorManager)this.getSystemService(SENSOR_SERVICE);
        final SensorEventListener mEventListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                if (event.sensor.getType() == Sensor.TYPE_GRAVITY) {
                    System.arraycopy(event.values, 0, sensorGravityValues, 0, 3);
                    gravity.set(-sensorGravityValues[0], sensorGravityValues[1]);
                }
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {}
        };

        sensorManager.registerListener(mEventListener, sensorManager.getDefaultSensor(Sensor.TYPE_GRAVITY), SensorManager.SENSOR_DELAY_NORMAL);
    }

    public class MainView extends View {
        public MainView(Context context) {
            super(context);
            this.setOnTouchListener(eventOnTouch);
        }

        public OnTouchListener eventOnTouch = new OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    newBall = new Ball(v);
                    newBall.radius = 40;
                    newBall.mass = newBall.radius / 100.0;
                    newBall.pos.set(event.getX(), event.getY());
                    newBall.active = false;
                    balls.add(newBall);
                } else if (event.getAction() == MotionEvent.ACTION_MOVE) {
                    Vector2d userPos = new Vector2d(event.getX(), event.getY());
                    double userSize = newBall.pos.distance(userPos) / 5.0;
                    int size = (int)Math.max(40, userSize);
                    double mass = size / 100.0;
                    newBall.radius = size;
                    newBall.mass = mass;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    newBall.active = true;
                    newBall = null;
                }
                return true;
            }
        };

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);

            Paint paint = new Paint();
            paint.setStyle(Paint.Style.FILL);
            paint.setColor(Color.WHITE);

            doNextFrame();

            for (Ball ball : balls) {
                ball.draw(paint, canvas);
            }
            invalidate();
        }
    }
}