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

package reclaim.console;

import reclaim.graphics.Shader;
import opengl.GL;
import haxe.Constraints;
import sys.io.File;

using StringTools;

typedef CmdArg = {
	var start : Int;
	var length : Int;
}

@:publicFields
class ConsoleParser
{
	static function exec(scope : ConsoleScope, commandline : String, args : Array< CmdArg >)
	{
		var cmd = commandline.substr(args[0].start, args[0].length);
		var fn = scope.lookup(cmd);
		if (fn == null)
			throw 'Command $cmd is not found';

		// make args array
		var va = [for (i in 1 ... args.length) commandline.substr(args[i].start, args[i].length)];
		
		return Reflect.callMethod(null, fn, [va]);
	}

	static function parse(scope : ConsoleScope, commandline : String, offset : Int, end : Int)
	{
		var i = offset;
		var args : Array< CmdArg > = [];

		var lastRes : Dynamic = null;
		
		while (true)
		{
			// delimiter of arguments
			if (i >= end || commandline.charAt(i) == ";") {
				//### exeute command
				if (args.length > 0)
					lastRes = exec(scope, commandline, args);

				if (i >= end)
					break;
				
				// reset arguments
				args.resize(0);
				++i;
				continue;
			}

			// skip any space chars
			if (commandline.isSpace(i)) {
				++i;
				continue;
			}

			if (commandline.charAt(i) == "\"") {
				var close = commandline.indexOf("\"", i + 1);
				if (close < 0) {
					// allow parens to be non-closed
					close = end;
				}

				// save the arg
				args.push({ start : i + 1, length: close - i - 1 });
				i = close + 1;
			} else {
				var start = i;
				// searh for next whitespace or ;
				while (i < end) {
					if (commandline.charAt(i) == ";" || commandline.isSpace(i))
						break;
					++i;
				}
				
				// save the arg
				var  l = i - start;
				if (l > 0)
					args.push({ start : start, length: l });
			}
		}

		return lastRes;
	}
}

@:publicFields
class ConsoleScope
{
	var commands : Map< String, Function > = [];

	public function lookup(cmd : String) {
		return commands[cmd];
	}

	public function complete(prefix : String) {
		var res = [];
		for (k => v in commands) {
			if (k.startsWith(prefix)) {
				res.push(k);
			}
		}
		return res;
	}

	function new() {}
}

class Console
{
	public function new() {}
	
	var global : ConsoleScope = new ConsoleScope();

	public function init()
	{
		initConsole();

		addCommand("echo", (args : Array< String >) -> log(args.join(" ")));
		addCommand("help", (args : Array< String >) -> {
			var prefix = switch (args.shift()) { case null: ""; case var s: s; };
			for (k => v in global.commands) {
				if (k.startsWith(prefix))
					trace('  $k');
			}
		});
 	}

	function exec(scope : ConsoleScope, command : String)
	{
		try {
			var result = ConsoleParser.parse(scope, command, 0, command.length);
			if (result != null) {
				trace(result);
			}
		} catch (ex : Any) {
			trace('!: ${Std.string(ex)}');
		}
	}

	public function addCommand(name : String, fn : Function)
	{
		global.commands[name] = fn;
	}

	//-----------------
	// Log

	var logLines = new Ring<String>(512);
	public function log(str: String)
	{
		logLines.push(str);
	}

	//------------------
	// Input

	var active = false;

	var history = new Ring<String>(8);

	var commandLine : String = "";
	var clScroll : Int = 0;
	var clCursor : Int = 0;

	var historyPtr = 0;

	public function completion(command:String) {
		var res = global.complete(command);

		res.sort((a, b) -> if (a == b) 0 else if (a > b) 1 else -1);

		if (res.length > 1) {
			if (command.length > 0) 
				trace('== $command');
			else
				trace('== All commands');
			
			for (s in res) {
				trace('  $s');
			}

			var com = 0;
			var s0 = res[0];
			var s1 = res[res.length - 1];
			while (com < s0.length) {
				if (s0.charAt(com) != s1.charAt(com))
					break;
				++com;
			}
		
			commandLine = s0.substr(0, com);
			clCursor = commandLine.length;
		} else if (res.length == 1) {
			commandLine = res[0] + " ";
			clCursor = commandLine.length;
		}
	}

	public function onkey(key : glfw.GLFW.Key)
	{
		if (key == KEY_F1) {
			active = !active;
			return true;
		}
		if (!active)
			return false;

		switch (key) {
			case KEY_LEFT:
				clCursor--;
				if (clCursor < 0) clCursor = 0;
			case KEY_RIGHT:
				clCursor++;
				if (clCursor > commandLine.length) clCursor = commandLine.length;
			case KEY_BACKSPACE:
				if (clCursor > 0) {
					commandLine = commandLine.substr(0, clCursor - 1) + commandLine.substr(clCursor);
					clCursor--;
				}
			case KEY_DELETE:
				if (commandLine.length > clCursor) {
					commandLine = commandLine.substr(0, clCursor) + commandLine.substr(clCursor + 1);
				}
			case KEY_HOME:
				clCursor = 0;
			case KEY_END:
				clCursor = commandLine.length;
			case KEY_ENTER | KEY_KP_ENTER:
				var cl = commandLine;
				trace('>$cl');
				history.push(cl); // push instruction into the history
				historyPtr = -1; // put pointer right after the last entry
				commandLine = "";
				clCursor = 0;
				exec(global, cl);
				clCursor = 0;
			case KEY_TAB:
				completion(commandLine);
			case KEY_UP:
				// go deeper into the history
				if (history.count() > 0) {
					historyPtr++;
					if (historyPtr >= history.count())
						historyPtr = history.count() - 1;
					commandLine = history.get(historyPtr);
					clCursor = commandLine.length;
				}
			case KEY_DOWN:
				// pull more recent commands
				historyPtr--;
				if (historyPtr < 0) {
					historyPtr = -1;
					commandLine = "";
				} else {
					commandLine = history.get(historyPtr);
				}
				clCursor = commandLine.length;
			default:
		}
		return true;
	}

	public function onchar(char : Int)
	{
		if (!active)
			return false;

		// ignore weird chars, which we can't print
		if (char < 32 || char > 127)
			return true;

		if (clCursor < 0) 
			clCursor = 0;
		if (clCursor > commandLine.length)
			clCursor = commandLine.length;
		
		//### remove this, when we have scroll working
		if (commandLine.length > 250)
			return true;
		
		var rem = String.fromCharCode(char) + commandLine.substr(clCursor);
		commandLine = if (clCursor > 0) commandLine.substr(0, clCursor) + rem else rem;
		clCursor++;
		return true;
	}

	//------------------
	// Rendering

	final symbolWidth = 10.0;

	var fontData : haxe.io.Bytes;
	var fontTexture : Int;

	var mesh = new DebugMesh();
	var shader : Shader;

	var debugLines : Array< String > = [];

	var oldTrace : (v:Dynamic, ?infos:haxe.PosInfos) -> Void;

	function initConsole()
	{
		oldTrace = haxe.Log.trace;
		haxe.Log.trace = function(v, ?infos) {
			log(Std.string(v));
			oldTrace(v, infos);
		};

		var font = File.read("../data/ReclaimFont.tga", true);

		font.seek(18, SeekBegin);
		fontData = font.read(256 * 128);

		var textures = [0];
		GL.glGenTextures(1, textures);
		fontTexture = textures[0];
		GL.glBindTexture(GL.GL_TEXTURE_2D, textures[0]);
		GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST);
		GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST);
		//GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP);
		//GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP);
		//GL.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_R, GL.GL_CLAMP);
		GL.glTexImage2D(GL.GL_TEXTURE_2D, 0, GL.GL_R8, 256, 128, 0, GL.GL_RED, GL.GL_UNSIGNED_BYTE, fontData.getData());
		GL.glBindTexture(GL.GL_TEXTURE_2D, 0);

		shader = new Shader();
		shader.loadShaders("../data/con_vert.glsl", "../data/con_frag.glsl");
		shader.compile();
	}

	public function setLine(i : Int, str : String)
	{
		//### check length
		debugLines[i] = str;
	}

	function drawString(str : String, offx : Single, offy : Single, color : Int)
	{
		if (str == null || str.length == 0)
			return;
		
		final dtx = 5.0 / 128.0;
		final dty = 5.0 / 32.0;

		var i = 0;
		var len = str.length;

		while (i < len) {
			var ch = str.charCodeAt(i++);

			if (ch <= 32 || ch > 0x7f) {
				offx += symbolWidth;
				continue;
			}

			// compute coords for character
			var tx = ch - 0x20;
			var ty = Std.int(tx / 24);
			tx -= ty * 24;

			// ty * 5 / 32
			var ftx = tx * dtx;
			var fty = ty * dty;

			var v : Array< Single > = [
				offx, offy + 20.0, ftx, fty + dty,
				offx, offy, ftx, fty,
				offx + symbolWidth, offy + 20.0, ftx + dtx, fty + dty,
				offx + symbolWidth, offy, ftx + dtx, fty
			];

			offx += symbolWidth;

			mesh.quad(v, color);
		}
	}

	public function render(fbWidth : Float, fbHeight : Float)
	{
		mesh.clear();

		if (!active) {
			// draw debug lines and bail out
			//### make this configurable
			var y = 30.0;
			for (i in 0 ... debugLines.length) {
				drawString(debugLines[i], 10.0, y, 0xFFFFFFFF);
				y += 20.0;
			}
		} else {
			var hh = Math.ffloor(fbHeight * 0.5);

			// draw background
			var bg : Array< Single > = [
				0.0, hh, 1.0/256.0, 127.0/128.0,
				0.0, 0.0, 1.0/256.0, 125.0/128.0,
				fbWidth, hh, 3.0/256.0, 127.0/128.0,
				fbWidth, 0.0, 3.0/256.0, 125.0/128.0
			];
			var line : Array< Single > = [
				0.0, hh+2.0, 1.0/256.0, 127.0/128.0,
				0.0, hh-2.0, 1.0/256.0, 125.0/128.0,
				fbWidth, hh+2.0, 3.0/256.0, 127.0/128.0,
				fbWidth, hh-2.0, 3.0/256.0, 125.0/128.0
			];

			mesh.quad(bg, 0x80000000);
			mesh.quad(line, 0xFFEE6688);

			drawString("Reclaim Console v0.1", fbWidth - 220.0, hh - 20.0, 0xCCEE6688);

			// draw log lines
			var y = hh - 70.0;
			var i = 0;
			while (i < logLines.count())
			{
				drawString(logLines.get(i), 10.0, y, 0xFFFFFFFF);
				y -= 20.0;
				++i;

				if (y < 0) break;
			}

			// draw input line
			var cly = hh - 45.0;
			drawString(">", 10.0, cly, 0xCCFFEEEE);
			drawString(commandLine, 22.0, cly, 0xFFFFFFFF);
			drawString("\x7f", 22.0 + symbolWidth * clCursor, cly, 0xC080FF80);
		}

		if (mesh.empty())
			return;
		
		//### I should move this somewhere
		GL.glDisable(GL.GL_DEPTH_TEST);
		GL.glEnable(GL.GL_BLEND);
		GL.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE_MINUS_SRC_ALPHA);

		GL.glUseProgram(shader.program);
		GL.glUniform4f(shader.projUni, 2.0 / fbWidth, -2.0 / fbHeight, -1.0, 1.0);
		GL.glUniform1i(shader.mainTexUni, 0);

		GL.glActiveTexture(GL.GL_TEXTURE0);
		GL.glBindTexture(GL.GL_TEXTURE_2D, fontTexture);

		mesh.draw();
	}
}



