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

class SimpleLookMatrix
{
	public var position(default, null) : Vec3;

	public var viewMatrix(default, null) : Mat4;
	public var invViewMatrix(default, null) : Mat4;

	public var yaw : Single = 0.0;
	public var pitch : Single = 0.0;

	public function new()
	{
		position = new Vec3();
		viewMatrix = new Mat4();
		invViewMatrix = new Mat4();
	}

	static final pitchLimit = Math.PI * 0.5 - 1e-4;

	public function addAngles(y : Single, p : Single)
	{
		yaw += y / 180.0 * Math.PI;
		pitch += p / 180.0 * Math.PI;

		if (pitch > pitchLimit) pitch = pitchLimit;
		if (pitch < -pitchLimit) pitch = -pitchLimit;
	}

	public function updateMatrix()
	{
		var cosX : Single = Math.cos(yaw);
		var sinX : Single = Math.sin(yaw);
		var cosY : Single = Math.cos(pitch);
		var sinY : Single = Math.sin(pitch);

		var dx = new Vec3(cosX, 0, sinX); // right axis
		var dy = new Vec3(sinY * sinX , cosY, -sinY * cosX); // up axis
		var dz = new Vec3(-cosY * sinX, sinY, cosY * cosX); // forward axis (backward for GL)

		viewMatrix.right = dx;
		viewMatrix.up = dy;
		viewMatrix.backward = dz;
	}

	public function move(fwd : Single, right : Single)
	{
		position.mulAcc(viewMatrix.right, -right);
		position.mulAcc(viewMatrix.backward, fwd);

		viewMatrix.position = position;
	}

	public function completeMatrix()
	{
		//### i probably shouldn't do this here
		Mat4.invert(invViewMatrix, viewMatrix);

		//trace(invViewMatrix);
		//trace(viewMatrix);
	}
}
