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
	var position : Vec3;

	var objectMatrix : Mat4;
	var invViewMatrix(get, never) : Mat4;

	var camera : SimpleLookMatrix;

	function get_invViewMatrix() return camera.invViewMatrix;

	function new()
	{
		camera = new SimpleLookMatrix();
	}

	static var sensitivity = 0.2;
	static var speed = 2.0;

	function handleInputs()
	{
		var fmove = Input.getKey(Input.Key.KEY_W) - Input.getKey(Input.Key.KEY_S);
		var smove = Input.getKey(Input.Key.KEY_D) - Input.getKey(Input.Key.KEY_A);

		camera.addAngles(Input.mouseDeltaX * sensitivity, Input.mouseDeltaY * sensitivity);
		camera.updateMatrix();

		camera.move(fmove * speed * Engine.delta, smove * speed * Engine.delta);
		camera.completeMatrix();
	}

	function update()
	{
		
	}
}