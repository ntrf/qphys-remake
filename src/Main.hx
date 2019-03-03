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

import math.Mat4;
import opengl.GL;
import glfw.GLFW;

class Main
{
	public static var mainWindow : Window;

	public static var player : Player;

	public static var projectionMatrix : Mat4;

	static function handleInput()
	{
		// Make sure mouse movement was handled
		Input.updateMouse();

		// Let player handle the input data
		player.handleInputs();
	}

	public static var runningTime = 0.0;
	public static var deltaTime : Single;

	public static var baseShader : Shader;

	public static var baseMap : MapData;

	static function updateWorld()
	{
		
	}

	static function main()
	{
		GLFW.init();

		mainWindow = new Window();
		mainWindow.init();

		Engine.resetTimer();
		Input.resetMouse();

		player = new Player();

		baseShader = new Shader();
		baseShader.loadShaders("../data/vert.glsl", "../data/frag.glsl");
		baseShader.compile();

		baseMap = new MapData();
		baseMap.load();
		baseMap.makegl();

		projectionMatrix = new Mat4();

		Input.captureMouse(true);

		while (!mainWindow.win.shouldClose()) {
			GLFW.pollEvents();

			//1. Update delta time
			Engine.updateTimer();

			//2. Run world update
			handleInput();
			
			//3. Render world
			var fbsize = mainWindow.win.getFramebufferSize();
			GL.glViewport(0, 0, fbsize[0], fbsize[1]);
			var aspect = fbsize[0] / fbsize[1];
			Mat4.perspective(projectionMatrix, 80.0 / 180.0 * Math.PI,
				aspect, 0.01, 100.0); 

			GL.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT | GL.GL_STENCIL_BUFFER_BIT);

			GL.glUseProgram(baseShader.program);
			baseShader.setProjection(projectionMatrix, player.camera.invViewMatrix);

			baseMap.bind();
			GL.glDrawElementsOffset(GL.GL_TRIANGLES, 61485, GL.GL_UNSIGNED_INT, 0);

			mainWindow.swap();
		}

		mainWindow.win.destroy();
		GLFW.terminate();
	}
}