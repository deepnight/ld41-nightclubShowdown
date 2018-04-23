import mt.MLib;
import mt.heaps.slib.*;

class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;

	public var debug : h2d.Graphics;

	var collMap : haxe.ds.Vector<Bool>;

	var crowd : h2d.Sprite;
	var people : Array<HSprite>;

	public function new() {
		super(Game.ME);

		wid = 30;
		hei = 7;

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		//var bg = new h2d.Graphics(root);
		//bg.beginFill(0x31415B,1);
		//bg.drawRect(0,0,wid*Const.GRID,hei*Const.GRID);
		var bg = Assets.gameElements.h_get("bg",root);
		var bg = Assets.gameElements.h_get("bg",root);
		bg.x = Const.GRID*20;

		debug = new h2d.Graphics(root);
		debug.beginFill(0xFFFF00,1);

		collMap = new haxe.ds.Vector(wid*hei);
		for(x in 0...wid)
		for(y in hei-2...hei)
			setColl(x,y,true);

		crowd = new h2d.Sprite(root);
		people = [];
		var x = 10;
		while( x<wid*Const.GRID ) {
			var e = Assets.gameElements.h_get("dancingA",crowd);
			e.anim.playAndLoop(Std.random(2)==0?"dancingA":"dancingB");
			e.setPos(x, hei*Const.GRID-15-rnd(25,30));
			e.setCenterRatio(0.5,1);
			e.setScale(rnd(0.6,0.7));
			e.colorize(0x370064);
			e.alpha = 0.5;
			people.push(e);
			x+=irnd(6,15);
		}
		var x = 0;
		while( x<wid*Const.GRID ) {
			var e = Assets.gameElements.h_get("dancingA",crowd);
			e.anim.playAndLoop(Std.random(2)==0?"dancingA":"dancingB");
			e.setPos(x, hei*Const.GRID-5-rnd(25,30));
			e.setCenterRatio(0.5,1);
			e.colorize(0x260046);
			people.push(e);
			x+=irnd(6,15);
		}
		var x = 6;
		while( x<wid*Const.GRID ) {
			var e = Assets.gameElements.h_get("dancingA",crowd);
			e.anim.playAndLoop(Std.random(2)==0?"dancingA":"dancingB");
			e.setPos(x, hei*Const.GRID-rnd(25,30));
			e.setCenterRatio(0.5,1);
			e.colorize(0x0e0019);
			people.push(e);
			x+=irnd(6,15);
		}

		for(cx in 0...wid) {
			var e = Assets.gameElements.h_getRandom("ground",root);
			e.x = cx*Const.GRID;
			e.y = (hei-2)*Const.GRID;
		}


		for(cx in 0...wid)
		for(cy in 0...hei) {
			var x = cx*Const.GRID;
			var y = cy*Const.GRID;
			if( hasColl(cx,cy) ) {
				//bg.beginFill(0x644F40,1);
				//bg.drawRect(x,y,Const.GRID,Const.GRID);
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

	override public function update() {
		var game = Game.ME;
		speedMod = game.getSlowMoFactor();
		super.update();
		for(e in people)
			e.anim.setSpeed(game.getSlowMoFactor());

		if( !cd.hasSetS("flash",0.5) )
			Game.ME.fx.flashBangS(0x7B64DB,0.04,1);

		if( !cd.hasSetS("spot",0.06) )
			for(i in 0...5)
				Game.ME.fx.spotLight(wid*Const.GRID*rnd(0,1), rnd(20,30));
	}
}