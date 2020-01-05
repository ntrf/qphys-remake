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

import reclaim.Engine;
import reclaim.math.Mat4;
import opengl.GL;
import glfw.GLFW;

class Main
{
	public static var mainWindow : Window;

	public static var player : Player;

	static function handleInput()
	{
		// Make sure mouse movement was handled
		Input.updateMouse();

		// Let player handle the input data
		player.handleInputs();
	}

	static function onchar(char : Int)
	{
		console.onchar(char);
	}
	static function onkey(key : Int, scancode : Int, action : Int, mods : Int)
	{
		if (action == KeyState.PRESS || action == KeyState.REPEAT)
			console.onkey(key);
	}	

	public static var runningTime = 0.0;
	public static var deltaTime : Single;

	public static var baseShader : reclaim.graphics.Shader;

	public static var baseMap : MapData;

	public static var console : reclaim.console.Console;

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

		mainWindow.win.setCharCallback(onchar);
		mainWindow.win.setKeyCallback(onkey);

		player = new Player();

		baseShader = new reclaim.graphics.Shader();
		baseShader.loadShaders("../data/vert.glsl", "../data/frag.glsl");
		baseShader.compile();

		var camIndex = GL.glGetUniformBlockIndex(baseShader.program, "CameraBlock");
		GL.glUniformBlockBinding(baseShader.program, camIndex, 1);

		baseMap = new MapData();
		baseMap.load();
		baseMap.makegl();

		var mainView = new reclaim.graphics.ViewData();

		//### Encapsulate UBO
		var ubos = [0];
		GL.glGenBuffers(1, ubos);
		var camUBO = ubos[0];
		GL.glBindBuffer(GL.GL_UNIFORM_BUFFER, camUBO);
		GL.glBufferDataEmpty(GL.GL_UNIFORM_BUFFER, mainView.payloadSize, GL.GL_DYNAMIC_DRAW);

		Input.captureMouse(true);

		console = new reclaim.console.Console();
		console.init();

		console.addCommand("quit", (args : Array< String >) -> mainWindow.win.setShouldClose(true));

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
			mainView.configPerspective(player.camera.invViewMatrix, aspect, 80.0 / 180.0 * Math.PI,
				0.1, 10000.0);
			//### Encapsulate UBO
			mainView.upload(camUBO);

			GL.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT | GL.GL_STENCIL_BUFFER_BIT);

			GL.glUseProgram(baseShader.program);
			GL.glBindBufferBase(GL.GL_UNIFORM_BUFFER, 1, camUBO);

			baseMap.bind();
			GL.glDrawElementsOffset(GL.GL_TRIANGLES, 61485, GL.GL_UNSIGNED_INT, 0);


			console.render(fbsize[0], fbsize[1]);

			mainWindow.swap();
		}

		mainWindow.win.destroy();
		GLFW.terminate();
	}
}