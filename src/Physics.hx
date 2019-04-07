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

package ;

import math.Vec3;

typedef BBox = {
	var min : Vec3;
	var max : Vec3;
};

typedef TraceResult = {
	var startsolid : Bool;
	@:optional var planeNormal : Vec3;
	@:optional var planePoint : Vec3;
};

class Physics
{
	static var groundNormal = new Vec3(0, 1, 0);
	static var groundPoint = new Vec3();

	public static function traceBox(box : BBox, start : Vec3, end : Vec3, tr : TraceResult) : Float
	{
		var sy = start.y + box.min.y;
		var ey = end.y + box.min.y;

		var d = ey - sy;
		//### this is probably unnecessary
		if (Math.abs(d) < 1e-7) {
			return if (ey <= 0) 0.0 else 1.0;
		}

		if (sy <= 0) {
			if (tr != null)
				tr.startsolid = true;
			return 0;
		} else {
			if (tr != null)
				tr.startsolid = false;

			if (d > 0)
				return 1.0;
			
			var t = (0 - sy) / d;
			if (t > 1.0)
				return 1.0;

			if (tr != null) {
				tr.planeNormal = groundNormal;
				tr.planePoint = groundPoint;
			}

			if (t < 0) t = 0;
			return t;
		}
	}

	static final groundProbe = new Vec3(0, -1, 0);

	public static function checkGround(box : BBox, pos : Vec3) : Bool
	{
		var end = pos.clone();
		end.add(groundProbe);
		var res = traceBox(box, pos, end, null);
		return !(res >= 1.0);
	}
}