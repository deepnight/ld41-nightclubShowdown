class Main extends dn.Process {
	public static var BG = 0x0;
	public static var ME : Main;
	public var console : Console;
	public var cached : h2d.Object;
	var black : h2d.Bitmap;


	public function new() {
		super();

		ME = this;
		presses = new Map();

		createRoot(Boot.ME.s2d);

		cached = new h2d.Object(root);
		cached.filter = new h2d.filter.ColorMatrix();

		//#if( debug && hl )
		//hxd.Res.initLocal();
		//hxd.res.Resource.LIVE_UPDATE = true;
		//#else
		hxd.Res.initEmbed();
		//#end

		hxd.snd.Manager.get(); // force sound init
		Assets.init();
		console = new Console();
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);
		hxd.Timer.wantedFPS = Const.FPS;
		#if !debug
		toggleFullscreen();
		#end


		black = new h2d.Bitmap(h2d.Tile.fromColor(BG,1,1), root);
		black.visible = false;

		delayer.addF(()->restartGame(), 1);

		onResize();
	}

	public function isTransitioning() return cd.has("transition");

	var presses : Map<Int,Bool>;
	public function keyPressed(k:Int) {
		if( console.isActive() || isTransitioning() )
			return false;

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

	var full = false;
	public function toggleFullscreen() {
		#if hl
		var s = hxd.Window.getInstance();
		full = !full;
		s.displayMode = Borderless;
		#end
	}

	override public function onResize() {
		super.onResize();
		Const.SCALE = M.floor( w() / (20*Const.GRID) );
		cached.scaleX = cached.scaleY = Const.SCALE;
		black.scaleX = Boot.ME.s2d.width;
		black.scaleY = Boot.ME.s2d.height;
	}

	override public function onDispose() {
		super.onDispose();
		if( ME==this )
			ME = null;
	}

	public function restartGame(?hist:Array<Game.HistoryEntry>) {
		if( Game.ME!=null ) {
			cd.setS("transition",Const.INFINITE);
			setBlack(true, function() {
				Game.ME.destroy();
				Assets.playMusic(false);

				delayer.addS(function() {
					cd.unset("transition");
					new Game( new h2d.Object(cached), hist );
					tw.createS(Game.ME.root.alpha, 0>1, 0.4);
					setBlack(false);
				},0.5);
			});
		}
		else {
			var g = new Game( new h2d.Object(cached), hist );
			tw.createS(Game.ME.root.alpha, 0>1, 0.4);
			setBlack(false);
			Assets.playMusic(false);
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
		Assets.gameElements.tmod = tmod*Boot.ME.speed;
	}
}
