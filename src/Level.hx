import mt.MLib;
import mt.heaps.slib.*;

class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;

	public var debug : h2d.Graphics;

	var collMap : haxe.ds.Vector<Bool>;

	var crowd : h2d.Sprite;
	var people : Array<HSprite>;
	var pixels : Map<UInt, Array<CPoint>>;

	public function new() {
		super(Game.ME);


		wid = 20;
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

		function getDancer() return switch(Std.random(3)) {
			case 0 : "dancingA";
			case 1 : "dancingB";
			case 2 : "dancingC";
			default : "dancingA";
		}
		var x = 10;
		while( x<wid*Const.GRID ) {
			var e = Assets.gameElements.h_get("dancingA",crowd);
			e.anim.playAndLoop(getDancer()).setSpeed(rnd(0.8,1));
			e.setPos(x, hei*Const.GRID-17-rnd(25,30));
			e.setCenterRatio(0.5,1);
			e.setScale(rnd(0.6,0.7));
			e.colorize(0x830E4F);
			//e.alpha = 0.4;
			people.push(e);
			x+=irnd(6,15);
		}
		var x = 0;
		while( x<wid*Const.GRID ) {
			var e = Assets.gameElements.h_get("dancingA",crowd);
			e.anim.playAndLoop(getDancer()).setSpeed( rnd(0.85,1.1) );
			e.setPos(x, hei*Const.GRID-5-rnd(25,30));
			e.setCenterRatio(0.5,1);
			e.colorize(0x680261);
			people.push(e);
			x+=irnd(6,15);
		}
		var x = 6;
		while( x<wid*Const.GRID ) {
			var e = Assets.gameElements.h_get("dancingA",crowd);
			e.anim.playAndLoop(getDancer()).setSpeed( rnd(0.85,1.1) );
			e.setPos(x, hei*Const.GRID-rnd(25,30));
			e.setCenterRatio(0.5,1);
			e.colorize(0x29004A);
			people.push(e);
			x+=irnd(6,15);
		}

		for(cx in 0...wid) {
			var e = Assets.gameElements.h_getRandom("ground",root);
			e.x = cx*Const.GRID;
			e.y = (hei-2)*Const.GRID;
		}


		//for(cx in 0...wid)
		//for(cy in 0...hei) {
			//var x = cx*Const.GRID;
			//var y = cy*Const.GRID;
			//if( hasColl(cx,cy) ) {
				////bg.beginFill(0x644F40,1);
				////bg.drawRect(x,y,Const.GRID,Const.GRID);
			//}
		//}
	}

	public var waveMobCount : Int;
	public function attacheWaveEntities(waveId:Int) {
		var bd = hxd.Res.levels.toBitmap();
		pixels = new Map();
		for(cy in 0...hei)
		for(cx in 0...wid) {
			var c = mt.deepnight.Color.removeAlpha( bd.getPixel(cx,cy+waveId*6) );
			if( !pixels.exists(c) )
				pixels.set(c, []);
			pixels.get(c).push( new CPoint(cx,cy) );
		}

		waveMobCount = getPixels(0xff6600).length + getPixels(0x20d5fc).length;

		for(pt in getPixels(0x704621))
			new en.Cover(pt.cx,0);

		for(pt in getPixels(0xff6600)) {
			delayer.addS(function() {
				var e = new en.m.BasicGun(pt.cx,pt.cy);
				e.dir = hasPixel(0x363c60,pt.cx-1,pt.cy) ? -1 : 1;
				e.enterArena(rnd(0.5,1));
			}, hasPixel(0x363c60,pt.cx,pt.cy-2) ? 6 : hasPixel(0x363c60,pt.cx,pt.cy-1) ? 3 : 0);
		}

		for(pt in getPixels(0x20d5fc)) {
			delayer.addS(function() {
				var e = new en.m.Grenader(pt.cx,pt.cy);
				e.dir = hasPixel(0x363c60,pt.cx-1,pt.cy) ? -1 : 1;
				e.enterArena(1.5);
			}, hasPixel(0x363c60,pt.cx,pt.cy-2) ? 6 : hasPixel(0x363c60,pt.cx,pt.cy-1) ? 3 : 0);
		}
	}

	public function iteratePixels(c:UInt, cb:Int->Int->Void) {
		if( !pixels.exists(c) )
			return;

		for(pt in pixels.get(c))
			cb(pt.cx, pt.cy);
	}

	public inline function getPixel(c:UInt) : Null<CPoint> {
		return pixels.exists(c) ? pixels.get(c)[0] : null;
	}

	public function getPixels(c:UInt) : Array<CPoint> {
		return pixels.exists(c) ? pixels.get(c) : [];
	}

	public function hasPixel(c:UInt, cx:Int, cy:Int) {
		for(pt in getPixels(c))
			if( pt.cx==cx && pt.cy==cy )
				return true;
		return false;
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
			e.anim.setGlobalSpeed( game.getSlowMoFactor() );

		if( !cd.hasSetS("flash",0.5) )
			Game.ME.fx.flashBangS(0x7B64DB,0.04,1);

		if( !cd.hasSetS("spot",0.06) )
			for(i in 0...5)
				Game.ME.fx.spotLight(wid*Const.GRID*rnd(0,1), rnd(20,30));
	}
}