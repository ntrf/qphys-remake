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

import opengl.GL;
import glfw.GLFW;
import glew.GLEW;

class Window
{
	public var win : glfw.Window;

	public function new() {}

	public function init()
	{
		GLFW.hint(GLFW.CLIENT_API, ClientApi.OpenGL);
		GLFW.hint(GLFW.OPENGL_FORWARD_COMPAT, 1);
		GLFW.hint(GLFW.OPENGL_PROFILE, OpenGLProfile.Core);
		GLFW.hint(GLFW.CONTEXT_VERSION_MAJOR, 3);
		GLFW.hint(GLFW.CONTEXT_VERSION_MINOR, 3);

		win = glfw.Window.createWindow(1280, 720, "Reclaim engine");

		win.makeCurrent();

		GLEW.init();

		GL.glClearColor(0.1, 1.0, 0.3, 0.0);
		GL.glEnable(GL.GL_DEPTH_TEST);

		// I don't think i'll use this
		var vaos = [0];
		GL.glGenVertexArrays(1, vaos);
		GL.glBindVertexArray(vaos[0]);
	}

	public function swap()
	{
		win.swapBuffers();
	}
}