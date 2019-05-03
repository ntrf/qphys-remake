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

	static function traceBoxBrush(brushId : Int, last : Single, box : BBox, start : Vec3, end : Vec3, tr : TraceResult) : Float
	{
		var map = Main.baseMap;

		var brush = map.getBrush(brushId);

		var pi = brush[0];
		var pn = brush[1];

		var startsolid = true;
		var endsolid = true;

		var enter = -1.0;
		var exit = 1.0;

		var enterplane = null;

		for (i in 0 ... pn) {
			var plane = map.getPlane(pi + i);

			var lim = plane.w + 
				(plane.x > 0 ? box.max.x : box.min.x) * plane.x + 
				(plane.z > 0 ? box.max.y : box.min.y) * plane.z +
				(-plane.y > 0 ? box.max.z : box.min.z) * -plane.y;

			var spos = start.x * plane.x + start.y * plane.z + start.z * -plane.y;
			var epos = end.x * plane.x + end.y * plane.z + end.z * -plane.y;
			
			spos -= lim;
			epos -= lim;

			if (spos > 0) {
				startsolid = false;
			}
			if (epos > 0) {
				endsolid = false;
			}

			// check if both points are in front of the brush
			if (spos > 0 && epos > 0) {
				return 1.0;
			}

			// skip planes, that won't generate intersection points
			if (spos <= 0 && epos <= 0) {
				continue;
			}

			var d = spos - epos;

			// check if there is a no movement on the axis
//			if (Math.abs(d) > 1e-7) {
//				continue;
//			}

			// compute enter and exit coordinates
			var t = spos / d;
			if (d > 0) {
				if (t > enter) {
					enter = t;
					enterplane = plane;
				}
			} else {
				if (t < exit)
					exit = t;
			}
		}

		// check if we're stuck
		if (startsolid) {
			if (tr != null)
				tr.startsolid = true;
			return 0.0;
		}

		// we pass by the object
		if (enter > exit)
			return 1.0;
		
		// did we hit a wall closer, than before
		if (tr != null && enter > -1 && enter < last) {
			if (enterplane != null) {
				tr.planeNormal = new Vec3(enterplane.x, enterplane.z, -enterplane.y);
			}
		}

		if (enter < 0) {
			enter = 0;
		}

		return enter;
	}

	public static function traceBox(box : BBox, start : Vec3, end : Vec3, tr : TraceResult) : Float
	{
#if 0
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
#else
		var last : Single = 1.0;

		if (tr != null) {
			tr.planeNormal = null;
			tr.planePoint = null;
			tr.startsolid = false;
		}
		
		var num = Main.baseMap.numBrushes;

		for (i in 0 ... num) {
			var res = traceBoxBrush(i, last, box, start, end, tr);
			if (last > res)
				last = res;
		}

		return last;
#end
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