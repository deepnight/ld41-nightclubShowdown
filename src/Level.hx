import mt.MLib;
import mt.deepnight.Color;
import mt.heaps.slib.*;

class Level extends mt.Process {
	var curWaveId : Int;

	public var wid : Int;
	public var hei : Int;

	public var debug : h2d.Graphics;

	var collMap : haxe.ds.Vector<Bool>;

	var crowd : h2d.Sprite;
	var bg : HSprite;
	var front : HSprite;
	var circle : HSprite;
	var people : Array<HSprite>;
	var pixels : Map<UInt, Array<CPoint>>;

	public function new() {
		super(Game.ME);

		wid = 20;
		hei = 7;
		collMap = new haxe.ds.Vector(wid*hei);

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		var mask = new h2d.Graphics(root);
		mask.beginFill(0x0,1);
		mask.drawRect(0,0,wid*Const.GRID,hei*Const.GRID);

	}

	public function startWave(waveId:Int) {
		curWaveId = waveId;
		render();
	}

	function render() {
		if( bg!=null ) {
			bg.remove();
			debug.remove();
			front.remove();
			circle.remove();
			for(e in people)
				e.remove();
			root.removeChildren();
		}
		people = [];
		collMap = new haxe.ds.Vector(wid*hei);
		var game = Game.ME;

		if( curWaveId==2 )
			Assets.playMusic(true);

		switch( curWaveId ) {

			case 0,1 :
				bg = Assets.gameElements.h_get("bgOut",root);

				front = Assets.gameElements.h_get("bgOver");
				Game.ME.scroller.add(front, Const.DP_TOP);
				front.x = -32;

				circle = Assets.gameElements.h_get("redCircle",0, 0.5,0.5);
				Game.ME.scroller.add(circle, Const.DP_BG);
				circle.x = wid-36;
				circle.y = 34;
				circle.blendMode = Add;


			default :
				for(x in 0...wid)
				for(y in hei-2...hei)
					setColl(x,y,true);

				bg = Assets.gameElements.h_get("bg",root);

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
					e.setPos(x, hei*Const.GRID-14-rnd(25,30));
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
					e.setPos(x, hei*Const.GRID-3-rnd(25,30));
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

				front = Assets.gameElements.h_get("bgOver");
				Game.ME.scroller.add(front, Const.DP_TOP);
				front.x = -32;

				var bottomLight = Assets.gameElements.h_get("bottomLight",0, 0,1, root);
				//Game.ME.scroller.add(bottomLight, Const.DP_BG);
				bottomLight.y = 5*Const.GRID;
				bottomLight.blendMode = Add;
				bottomLight.colorize(0xAF40BF);
				bottomLight.alpha = 0.6;
				bottomLight.scaleY = 0.5;

				circle = Assets.gameElements.h_get("redCircle",0, 0.5,0.5);
				Game.ME.scroller.add(circle, Const.DP_BG);
				circle.x = wid*0.5*Const.GRID-5;
				circle.y = 2*Const.GRID;
				circle.blendMode = Add;
		}

		debug = new h2d.Graphics(root);
	}

	override function onDispose() {
		super.onDispose();
		front.remove();
	}

	var curHue = 0.;
	public function hue(ang:Float, sec:Float) {
		tw.createS(curHue, ang, sec).onUpdate = function() {
			bg.colorMatrix = new h3d.Matrix();
			bg.colorMatrix.identity();
			bg.colorMatrix.colorHue(curHue);
			for(e in people) {
				e.colorMatrix = new h3d.Matrix();
				e.colorMatrix.identity();
				e.colorMatrix.colorHue(curHue);
			}
		}
	}

	public var waveMobCount : Int;
	public function attacheWaveEntities() {
		if( curWaveId>=2 )
			Game.ME.fx.allSpots(25, wid*Const.GRID);

		var bd = hxd.Res.levels.toBitmap();
		pixels = new Map();
		for(cy in 0...hei)
		for(cx in 0...wid) {
			var c = mt.deepnight.Color.removeAlpha( bd.getPixel(cx,cy+curWaveId*6) );
			if( !pixels.exists(c) )
				pixels.set(c, []);
			pixels.get(c).push( new CPoint(cx,cy) );
		}

		var c = mt.deepnight.Color.removeAlpha( bd.getPixel(0,curWaveId*6) );
		hue(mt.deepnight.Color.intToHsl(c).h*6.28, 2.5);

		waveMobCount = getPixels(0xff6600).length + getPixels(0x20d5fc).length + getPixels(0x00ff00).length;

		for(pt in getPixels(0x704621))
			new en.Cover(pt.cx,0);

		function initMob(cx:Int, cy:Int, cb:Void->en.Mob) {
			delayer.addS(function() {
				var e = cb();
				e.enterArena(rnd(0.5,1));
				if( hasPixel(0x363c60,cx-1,cy) )
					e.dir = -1;
				else if( hasPixel(0x363c60,cx-1,cy) )
					e.dir = 1;
			}, hasPixel(0x363c60,cx,cy-2) ? 7 : hasPixel(0x363c60,cx,cy-1) ? 3.5 : 0);
		}

		for(pt in getPixels(0x00ff00))
			initMob(pt.cx, pt.cy, function() return new en.m.MachineGun(pt.cx, curWaveId<=1?6:4));

		for(pt in getPixels(0xff6600))
			initMob(pt.cx, pt.cy, function() return new en.m.BasicGun(pt.cx, curWaveId<=1?6:4));

		for(pt in getPixels(0x20d5fc))
			initMob(pt.cx, pt.cy, function() return new en.m.Grenader(pt.cx, curWaveId<=1?6:4));

		//// Grenader
		//for(pt in getPixels(0x20d5fc)) {
			//delayer.addS(function() {
				//var e = new en.m.Grenader(pt.cx,4);
				//e.enterArena(1.5);
				//if( hasPixel(0x363c60,pt.cx-1,pt.cy) )
					//e.dir = -1;
				//else if( hasPixel(0x363c60,pt.cx-1,pt.cy) )
					//e.dir = 1;
			//}, hasPixel(0x363c60,pt.cx,pt.cy-2) ? 6 : hasPixel(0x363c60,pt.cx,pt.cy-1) ? 3 : 0);
		//}
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


		switch( curWaveId ) {
			case 0,1 :
				if( !cd.hasSetS("smoke",0.06) )
					game.fx.envSmoke();

				if( !cd.hasSetS("envInit",Const.INFINITE) )
					for(i in 0...30 )
						game.fx.envRain();

				if( !cd.hasSetS("env",0.06) )
					game.fx.envRain();


			default :
				if( !cd.hasSetS("envInit",Const.INFINITE) )
					for(i in 0...30 )
						game.fx.envDust();

				if( !cd.hasSetS("env",0.06) )
					game.fx.envDust();

				if( !cd.hasSetS("flash",0.5) )
					Game.ME.fx.flashBangS(0x7B64DB,0.07,0.5);

				if( !cd.hasSetS("spot",0.06) )
					for(i in 0...5)
						Game.ME.fx.spotLight(wid*Const.GRID*rnd(0,1), rnd(20,30));

				if( !cd.hasSetS("lazer",0.06) )
					for(i in 0...5)
						Game.ME.fx.lazer(wid*Const.GRID*rnd(0,1));
		}
	}
}