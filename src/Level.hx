class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;

	public function new() {
		super(Game.ME);
		wid = 20;
		hei = 8;
	}

	public function isValid(cx:Float,cy:Float) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}

	public function hasColl(x:Int, y:Int) {
		return !isValid(x,y) ? true : false;
	}
}