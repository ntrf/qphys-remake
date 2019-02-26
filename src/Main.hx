
import glm.GLM;
import glm.Vec4;
import glm.Vec3;
import glm.Quat;
import glm.Mat4;
import glfw.Window;
import glfw.GLFW;

import opengl.GL;

class Main
{
	inline static var wkey = 87;
	inline static var akey = 65;
	inline static var skey = 83;
	inline static var dkey = 68;

	static var window : glfw.Window;

	static var levelData : Level;

	static var baseShader : Shader;

	static var prevMouseX = 0.0;
	static var prevMouseY = 0.0;

	static var player = new Player();

	static function resetMouse()
	{
		var move = window.getCursorPos();
		prevMouseX = move[0];
		prevMouseY = move[1];
	}

	static function updateCamera(dt : Float)
	{
		var fmove = ((window.getKey(wkey) != 0) ? 1.0 : 0.0) + ((window.getKey(skey) != 0) ? -1.0 : 0.0);
		var smove = ((window.getKey(akey) != 0) ? 1.0 : 0.0) + ((window.getKey(dkey) != 0) ? -1.0 : 0.0);

		var move = window.getCursorPos();
		var mdeltaX = move[0] - prevMouseX;
		var mdeltaY = move[1] - prevMouseY;
		prevMouseX = move[0];
		prevMouseY = move[1];

		player.updateInputs(dt, fmove, smove, mdeltaX, mdeltaY);
	}

	static function main()
	{
		if (GLFW.init() == 0) {
			throw "Error: failed to init GLFW";
		}

		GLFW.hint(GLFW.OPENGL_FORWARD_COMPAT, 1);
		GLFW.hint(GLFW.CLIENT_API, ClientApi.OpenGL);
		GLFW.hint(GLFW.OPENGL_PROFILE, OpenGLProfile.Core);
		GLFW.hint(GLFW.CONTEXT_VERSION_MAJOR, 3);
		GLFW.hint(GLFW.CONTEXT_VERSION_MINOR, 3);

		window = Window.createWindow(1280, 720, "Quake phys remake");

		var pos = window.getPos();
		pos[0] += 1920;
		window.setPos(pos[0], pos[1]);

		window.makeCurrent();

		levelData = new Level();
		levelData.load();

		glew.GLEW.init();

		GL.glClearColor(0.1, 1.0, 0.3, 0.0);

		baseShader = new Shader();
		baseShader.loadShaders("../data/vert.glsl", "../data/frag.glsl");
		baseShader.compile();


		GL.glEnable(GL.GL_DEPTH_TEST);

		var vaos = [0];

		GL.glGenVertexArrays(1, vaos);
		GL.glBindVertexArray(vaos[0]);

		levelData.makeGl();

		var camera = new Mat4();

		var lastFrameTime = GLFW.getTime();

		window.setInputMode(Window.CURSOR_MODE, Window.CURSOR_DISABLED);
		resetMouse();

		var scale_unit = new Vec3(1, 1, 1);

		while (!window.shouldClose()) {
			GLFW.pollEvents();

			var frameTime = GLFW.getTime();
			var delta = frameTime - lastFrameTime;
			lastFrameTime = frameTime;

			//... logic goes here

			updateCamera(delta);

			var fbsize = window.getFramebufferSize();
			GL.glViewport(0, 0, fbsize[0], fbsize[1]);

			glm.GLM.perspective(80.0 / 180.0 * Math.PI, fbsize[0] / fbsize[1], 0.1, 1000.0, camera);

			GL.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);

			GL.glUseProgram(baseShader.program);
			baseShader.setProjection(camera, player.camView);

			levelData.bind();

			GL.glDrawElementsOffset(GL.GL_TRIANGLES, 61485, GL.GL_UNSIGNED_INT, 0);

			GL.glFinish();

			window.swapBuffers();
		}

		window.destroy();
		GLFW.terminate();
	}
}