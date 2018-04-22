class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;

	public var debug : h2d.Graphics;

	public function new() {
		super(Game.ME);

		wid = 20;
		hei = 8;

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		var bg = new h2d.Graphics(root);
		bg.beginFill(0x0,1);
		bg.drawRect(0,0,wid*Const.GRID,hei*Const.GRID);

		debug = new h2d.Graphics(root);
		debug.beginFill(0xFFFF00,1);
	}

	public function isValid(cx:Float,cy:Float) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}

	public function hasColl(x:Int, y:Int) {
		return !isValid(x,y) ? true : false;
	}
}