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

class Ring<T> {
	
	var head: Int;
	var tail: Int;
	var cap: Int;
	var a: haxe.ds.Vector<T>;

	public function new(len) {
		cap = len - 1; // only "len-1" available spaces
		a = new haxe.ds.Vector<T>(len);
		reset();
	}

	public function reset() {
		head = 0;
		tail = 0;
	}

	public function push(v: T) {
		if (space() == 0) tail = (tail + 1) & cap;
		head = (head + 1) & cap;
		a[head] = v;
	}

	public function get(i : Int) {
		return a[(head - i) & cap];
	}

	public function toString() {
		return '[head: $head, tail: $tail, capacity: $cap]';
	}

	public inline function count() return (head - tail) & cap;

	public inline function space() return (tail - head - 1) & cap;
}