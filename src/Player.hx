/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2019 Anton Nesterov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import math.Vec3;
import math.Mat4;

@:publicFields
class Player
{
	var position : Vec3 = new Vec3(0, 40, 0);
	var velocity : Vec3 = new Vec3();

	var objectMatrix : Mat4;
	var invViewMatrix(get, never) : Mat4;

	var camera : SimpleLookMatrix;

	var bbox : Physics.BBox;

	function get_invViewMatrix() return camera.invViewMatrix;

	function new()
	{
		camera = new SimpleLookMatrix();
		bbox = { min : new Vec3(-16, -36, -16), max: new Vec3(16, 36, 16) };
	}

	static var cameraOffset = new Vec3(0, 64.0 - 36.0, 0);

	static var sensitivity = 0.2;
	static var speed = 900.0;

	static var gravity = 600.0;

	static var maxspeed = 320.0;
	static var accel = 10.0;
	static var airaccel = 1.0;

	static var noclipspeed = 1000.0;
	static var noclipaccel = 100.0;

	static var jumpspeed = 200.0;

	static var friction = 4.0;
	static var stopvelocity = 100.0;

	function accelerateNoclip(fmove : Single, smove : Single)
	{
		var wishAccel = new Vec3();
		wishAccel.mulAcc(camera.viewMatrix.right, smove * speed);
		wishAccel.mulAcc(camera.viewMatrix.backward, -fmove * speed);

		var wishSpeed = wishAccel.length();
		if (wishSpeed > 0) {
			wishAccel.mulScalar(1.0 / wishSpeed);
		}

		if (wishSpeed > noclipspeed) {
			wishSpeed = noclipspeed;
		}

		var g2 = wishSpeed - wishAccel.dot(velocity);
		var g1 = Engine.delta * noclipaccel * wishSpeed;

		//trace('wishSpeed = $wishSpeed   g2 = $g2  g1 = $g1');

		if (g1 > g2) {
			g1 = g2;
		}

		if (g2 <= 0.0) {
			g1 = 0.0;
		}

		velocity.mulAcc(wishAccel, g1);
	}

	function accelerate(fmove : Single, smove : Single, aa : Single)
	{
		var fwdView = new Vec3(camera.viewMatrix.right.z, 0, -camera.viewMatrix.right.x);

		var wishAccel = new Vec3();
		wishAccel.mulAcc(camera.viewMatrix.right, smove * speed);
		wishAccel.mulAcc(fwdView, fmove * speed);

		var wishSpeed = wishAccel.length();
		if (wishSpeed > 0) {
			wishAccel.mulScalar(1.0 / wishSpeed);
		}

		if (wishSpeed > maxspeed) {
			wishSpeed = maxspeed;
		}

		var g2 = wishSpeed - wishAccel.dot(velocity);
		var g1 = Engine.delta * aa * wishSpeed;

		//trace('wishSpeed = $wishSpeed   g2 = $g2  g1 = $g1');

		if (g1 > g2) {
			g1 = g2;
		}

		if (g2 <= 0.0) {
			g1 = 0.0;
		}

		velocity.mulAcc(wishAccel, g1);
	}

	var gravityEnabled = true;

	var debounce = false;

	function tryPlayerMove()
	{
		var timeLeft = Engine.delta;

		var tr : Physics.TraceResult = { startsolid: false };

		var end = new Vec3();

		var it = 4;

		while (--it >= 0) {
			end.copy(position);
			end.mulAcc(velocity, timeLeft);
			var res = Physics.traceBox(bbox, position, end, tr);

			if (res >= 1.0) {
				position.copy(end);
				return;
			}

			// improve precision
			res -= 1e-5;

			// consume some time
			timeLeft *= (1.0 - res);

			if (timeLeft < 1e-3)
				return;

			// calc the new end position
			position.lepr(end, res);

			//### has to handle multiple surfaces

			// our new velocity
			var clip = 1e-5 - tr.planeNormal.dot(velocity);
			velocity.mulAcc(tr.planeNormal, clip);
		}
	}

	function applyFriction()
	{
		var velocityLen = velocity.length();
		if (velocityLen < 0.1) {
			velocity.set();
		} else {
			var d = stopvelocity / velocityLen;
			if (d < 1.0)
				d = 1.0;
			d *= Engine.delta * friction;
			if (d > 1.0) {
				velocity.set();
			} else {
				velocity.mulScalar(1.0 - d);
			}
		}
	}

	function handleInputs()
	{
		if (Input.getKey(Input.Key.KEY_2) > 0) {
			if (!debounce) {
				debounce = true;
				gravityEnabled = !gravityEnabled;
			}
		} else {
			debounce = false;
		}

		var fmove = Input.getKey(Input.Key.KEY_W) - Input.getKey(Input.Key.KEY_S);
		var smove = Input.getKey(Input.Key.KEY_D) - Input.getKey(Input.Key.KEY_A);

		var jump = Input.getKey(Input.Key.KEY_SPACE);

		camera.addAngles(Input.mouseDeltaX * sensitivity, Input.mouseDeltaY * sensitivity);
		camera.updateMatrix();

		var onGround = Physics.checkGround(bbox, position);

		//trace('speed = ${Math.sqrt(velocity.x * velocity.x + velocity.z * velocity.z)}');

		if (!gravityEnabled) {
			applyFriction();

			accelerateNoclip(fmove, smove);

			position.mulAcc(velocity, Engine.delta);
		} else {
			if (onGround) {
				//### this needs to be rewriten when brushes are real
				velocity.y = 0.0;

				if (jump > 0) {
					velocity.y += jumpspeed;
				}

				applyFriction();

			} else {
				velocity.y -= 0.5 * gravity * Engine.delta;
			}

			// accelerate
			accelerate(fmove, smove, if (onGround) accel else airaccel);

			// integrate position
			tryPlayerMove();

			onGround = Physics.checkGround(bbox, position);

			if (!onGround) {
				velocity.y -= 0.5 * gravity * Engine.delta;
			}
		}
		
		var camPos = position.clone();
		camPos.add(cameraOffset);
		camera.viewMatrix.position = camPos;
		camera.completeMatrix();
	}

	function update()
	{
		
	}
}