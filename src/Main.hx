import mt.Process;
import mt.MLib;

class Main extends mt.Process {
	public static var BG = 0x0;
	public static var ME : Main;
	public var console : Console;
	public var cached : h2d.CachedBitmap;
	var black : h2d.Bitmap;

	var screening : mt.heaps.slib.HSpriteBatch;

	public function new() {
		super();

		ME = this;

		createRoot(Boot.ME.s2d);

		cached = new h2d.CachedBitmap(root, 1,1);

		//#if( debug && hl )
		//hxd.Res.initLocal();
		//hxd.res.Resource.LIVE_UPDATE = true;
		//#else
		hxd.Res.initEmbed();
		//#end

		Assets.init();
		hxd.Timer.wantedFPS = Const.FPS;
		console = new Console();

		screening = new mt.heaps.slib.HSpriteBatch(Assets.gameElements.tile, cached);
		screening.alpha = 0.04;
		screening.visible = false;

		black = new h2d.Bitmap(h2d.Tile.fromColor(BG,1,1), root);
		black.visible = false;

		restartGame();

		onResize();
	}

	public function isTransitioning() return cd.has("transition");

	var presses : Map<Int,Bool>;
	public function keyPressed(k:Int) {
		if( console.isActive() || isTransitioning() )
			return false;

		if( presses==null )
			presses = new Map();

		if( presses.exists(k) )
			return false;

		presses.set(k, true);
		return hxd.Key.isDown(k);
	}

	public function setBlack(on:Bool, ?cb:Void->Void) {
		if( on ) {
			black.visible = true;
			tw.createS(black.alpha, 0>1, 0.6).onEnd = function() {
				if( cb!=null )
					cb();
			}
		}
		else {
			tw.createS(black.alpha, 0, 0.3).onEnd = function() {
				black.visible = false;
				if( cb!=null )
					cb();
			}
		}
	}

	override public function onResize() {
		super.onResize();
		Const.SCALE = MLib.floor( w() / (20*Const.GRID) );
		cached.scaleX = cached.scaleY = Const.SCALE;

		cached.width = MLib.ceil(Boot.ME.s2d.width/cached.scaleX);
		cached.height = MLib.ceil(Boot.ME.s2d.height/cached.scaleY);
		black.scaleX = Boot.ME.s2d.width;
		black.scaleY = Boot.ME.s2d.height;

		screening.clear();
		var t = Assets.gameElements.getTile("screening");
		for(y in 0...mt.MLib.ceil(cached.height/t.height))
		for(x in 0...mt.MLib.ceil(cached.width/t.width)) {
			var be = Assets.gameElements.hbe_get(screening, "screening");
			be.x = x*t.width;
			be.y = y*t.height;
		}
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	var full = false;
	public function toggleFullscreen() {
		#if hl
		var s = hxd.Stage.getInstance();
		full = !full;
		s.setFullScreen(full);
		#end
	}

	public function restartGame(?hist:Array<Game.HistoryEntry>) {
		if( Game.ME!=null ) {
			cd.setS("transition",Const.INFINITE);
			setBlack(true, function() {
				Game.ME.destroy();
				delayer.addS(function() {
					cd.unset("transition");
					new Game( new h2d.Sprite(cached), hist );
					tw.createS(Game.ME.root.alpha, 0>1, 0.4);
					setBlack(false);
					cached.addChild(screening);
				},0.5);
			});
		}
		else {
			var g = new Game( new h2d.Sprite(cached), hist );
			tw.createS(Game.ME.root.alpha, 0>1, 0.4);
			setBlack(false);
			cached.addChild(screening);
		}

	}

	override function postUpdate() {
		super.postUpdate();

		root.over(black);

		for(k in presses.keys())
			if( !hxd.Key.isDown(k) )
				presses.remove(k);
	}


	override function update() {
		super.update();

		if( keyPressed(hxd.Key.M) )
			mt.deepnight.Sfx.toggleMuteGroup(1);
	}
}
