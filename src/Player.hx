

import glm.Vec3;
import glm.GLM;
import glm.Vec4;
import glm.Quat;
import glm.Mat4;

class Player
{
	public var position : glm.Vec3 = new Vec3();

	public var camYaw : Float;
	public var camPitch : Float;

	static var speed = 2;
	static var sensitivity = 0.2;

	public var camView = new Mat4();

	public function updateInputs(dt : Float, fmove : Float, smove : Float, lookX : Float, lookY : Float)
	{
		camYaw += lookX * sensitivity;
		camPitch += lookY * sensitivity;

		if (camPitch > 89.0) camPitch = 89.0;
		if (camPitch < -89.0) camPitch = -89.0;

		var m0 = new Mat4();
		var m1 = new Mat4();
		var mt = new Mat4();
		var m1i = new Mat4();
		var r1 = new Quat();
		var r2 = new Quat();
		Quat.fromEuler(0, camYaw / 180.0 * Math.PI, 0, r1);
		Quat.fromEuler(camPitch / 180.0 * Math.PI, 0, 0, r2);

		glm.GLM.rotate(r1, m1);
		glm.GLM.rotate(r2, m0);

		Mat4.multMat(m0, m1, m1);

		Mat4.invert(m1, m1i);

		smove *= speed;
		fmove *= speed;

		var movevec = new Vec4(smove, 0, fmove, 1);
		var fwd = new Vec4(0,0,1,1);
		var side = new Vec4(1,0,0,1);

		Mat4.multVec(m1i, movevec, movevec);
		Mat4.multVec(m1i, fwd, fwd);
		Mat4.multVec(m1i, side, side);

		var lensq = movevec.x * movevec.x + movevec.y * movevec.y + movevec.z * movevec.z;
		if (lensq > speed * speed) {
			var sc = speed / Math.sqrt(lensq);
			movevec.x *= sc;
			movevec.y *= sc;
			movevec.z *= sc;
		}

		position.x = position.x + movevec.x * dt;
		position.y = position.y + movevec.y * dt;
		position.z = position.z + movevec.z * dt;  // P' = P + V * t

		GLM.translate(position, mt);
		Mat4.multMat(m1, mt, camView);
	}

	public function new() {}
}