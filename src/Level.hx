class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;

	public var debug : h2d.Graphics;

	var collMap : haxe.ds.Vector<Bool>;

	public function new() {
		super(Game.ME);

		wid = 30;
		hei = 8;

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		var bg = new h2d.Graphics(root);
		bg.beginFill(0x31415B,1);
		bg.drawRect(0,0,wid*Const.GRID,hei*Const.GRID);

		debug = new h2d.Graphics(root);
		debug.beginFill(0xFFFF00,1);

		collMap = new haxe.ds.Vector(wid*hei);
		for(x in 0...wid)
		for(y in hei-3...hei)
			setColl(x,y,true);

		for(cx in 0...wid)
		for(cy in 0...hei) {
			var x = cx*Const.GRID;
			var y = cy*Const.GRID;
			if( hasColl(cx,cy) ) {
				bg.beginFill(0x644F40,1);
				bg.drawRect(x,y,Const.GRID,Const.GRID);
			}
		}
	}

	public function isValid(cx:Float,cy:Float) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}

	public function coordId(x,y) return x+y*wid;

	public function hasColl(x:Int, y:Int) {
		return !isValid(x,y) ? true : collMap.get(coordId(x,y));
	}

	public function setColl(x,y,v:Bool) {
		collMap.set(coordId(x,y), v);
	}
}