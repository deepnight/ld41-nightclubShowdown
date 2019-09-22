class Area {
	public static var ALL : Array<Area> = [];

	public var radius : Float;
	public var owner : Entity;
	var getX : Void->Float;
	var getY : Void->Float;

	public var centerX(get,never) : Float; inline function get_centerX() return getX();
	public var centerY(get,never) : Float; inline function get_centerY() return getY();
	public var color : UInt = 0xFFFFFF;

	public function new(e:Entity, r:Float, getX:Void->Float, getY:Void->Float) {
		ALL.push(this);
		owner = e;
		radius = r;
		this.getX = getX;
		this.getY = getY;
	}

	public function dispose() {
		ALL.remove(this);
		owner = null;
	}

	public function contains(x,y) {
		return M.dist(centerX, centerY, x, y)<=radius;
	}
}