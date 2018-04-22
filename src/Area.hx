import mt.MLib;
import mt.deepnight.Lib;

class Area {
	public var radius : Float;
	var parent : Entity;
	var getX : Void->Float;
	var getY : Void->Float;

	public var centerX(get,never) : Float; inline function get_centerX() return getX();
	public var centerY(get,never) : Float; inline function get_centerY() return getY();

	public function new(e:Entity, r:Float, getX:Void->Float, getY:Void->Float) {
		parent = e;
		radius = r;
		this.getX = getX;
		this.getY = getY;
	}

	public function contains(x,y) {
		return Lib.distance(centerX, centerY, x, y)<=radius;
	}
}