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
import glfw.Window;

typedef Key = glfw.GLFW.Key;

class Input
{
	inline static var wkey = 87;
	inline static var akey = 65;
	inline static var skey = 83;
	inline static var dkey = 68;

	static var prevMouseX = 0.0;
	static var prevMouseY = 0.0;

	public static var mouseDeltaX = 0.0;
	public static var mouseDeltaY = 0.0;

	public static function resetMouse()
	{
		var move = Main.mainWindow.win.getCursorPos();
		prevMouseX = move[0];
		prevMouseY = move[1];
	}

	public static function updateMouse()
	{
		var move = Main.mainWindow.win.getCursorPos();
		mouseDeltaX = move[0] - prevMouseX;
		mouseDeltaY = move[1] - prevMouseY;
		prevMouseX = move[0];
		prevMouseY = move[1];
	}

	public static function captureMouse(m : Bool)
	{
		Main.mainWindow.win.setInputMode(Window.CURSOR_MODE, if (m) Window.CURSOR_DISABLED else Window.CURSOR_NORMAL);
	}

	public static function getKey(k : Key) : Single {
		return if (Main.mainWindow.win.getKey(k) > 0) 1.0 else 0.0;
	}
}