class FPoint {
	public var x = 0.;
	public var y = 0.;

	public var cx(get,never) : Int;
	public var cy(get,never) : Int;

	public function new(x,y) {
		set(x,y);
	}

	public function set(x,y) {
		this.x = x;
		this.y = y;
	}

	public function distEntCenter(e:Entity) {
		return M.dist(e.centerX,e.centerY,x,y);
	}
	public function distEntFoot(e:Entity) {
		return M.dist(e.footX,e.footY,x,y);
	}

	inline function get_cx() return Std.int(x/Const.GRID);
	inline function get_cy() return Std.int(y/Const.GRID);
}