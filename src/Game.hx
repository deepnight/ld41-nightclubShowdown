import mt.Process;
import mt.MLib;
import hxd.Key;

typedef HistoryEntry = { t:Int, a:en.Hero.Action } ;

class Game extends mt.Process {
	public static var ME : Game;
	public var scroller : h2d.Layers;
	public var vp : Viewport;
	public var fx : Fx;
	public var level : Level;
	public var hero : en.Hero;
	var clickTrap : h2d.Interactive;

	public var isReplay : Bool;
	public var heroHistory : Array<HistoryEntry>;

	public var hud : h2d.Flow;

	public function new(ctx:h2d.Sprite, replayHistory:Array<HistoryEntry>) {
		super(Main.ME);

		ME = this;
		createRoot(ctx);

		if( replayHistory!=null ) {
			isReplay = true;
			heroHistory = replayHistory.copy();
		}
		else {
			heroHistory = [];
			isReplay = false;
		}

		trace("new game, replay="+isReplay);
		//Console.ME.runCommand("+ bounds");

		scroller = new h2d.Layers(root);
		vp = new Viewport();
		fx = new Fx();

		clickTrap = new h2d.Interactive(1,1,Main.ME.root);
		//clickTrap.backgroundColor = 0x4400FF00;
		clickTrap.onPush = onMouseDown;
		//clickTrap.enableRightButton = true;

		level = new Level();

		hud = new h2d.Flow();
		root.add(hud, Const.DP_UI);
		hud.horizontalSpacing = 1;

		hero = new en.Hero(5,0);
		new en.Cover(4,3);

		new en.m.Grenader(10,4);
		new en.m.Grenader(16,4);
		//new en.m.BasicGun(2,4);
		//var m = new en.m.BasicGun(13,4);
		//var c = new en.Cover(12,4);
		//m.startCover(c,1);

		vp.repos();

		onResize();
	}

	public function updateHud() cd.setS("invalidateHud",Const.INFINITE);
	function _updateHud() {
		if( !cd.has("invalidateHud") )
			return;

		hud.removeChildren();
		cd.unset("invalidateHud");


		for( i in 0...MLib.min(hero.maxLife,6) ) {
			var e = Assets.gameElements.h_get("iconHeart", hud);
			e.colorize(i+1<=hero.life ? 0xFFFFFF : 0xFF0000);
			e.alpha = i+1<=hero.life ? 1 : 0.8;
			e.blendMode = Add;
		}

		hud.addSpacing(4);

		for( i in 0...hero.maxAmmo ) {
			var e = Assets.gameElements.h_get("iconBullet", hud);
			e.colorize(i+1<=hero.ammo ? 0xFFFFFF : 0xFF0000);
			e.alpha = i+1<=hero.ammo ? 1 : 0.8;
			e.blendMode = Add;
		}

	}

	function onMouseDown(ev:hxd.Event) {
		var m = getMouse();
		for(e in Entity.ALL)
			e.onClick(m.x, m.y, ev.button);
	}

	override public function onResize() {
		super.onResize();
		clickTrap.width = w();
		clickTrap.height = h();
		hud.x = w()*0.5/Const.SCALE - hud.outerWidth*0.5;
		hud.y = 8;
	}

	override public function onDispose() {
		super.onDispose();
		trace("game killed");
		if( ME==this )
			ME = null;
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	function gc() {
		var i = 0;
		while( i<Entity.ALL.length )
			if( Entity.ALL[i].destroyed )
				Entity.ALL[i].dispose();
			else
				i++;
	}

	override function postUpdate() {
		super.postUpdate();
		_updateHud();
	}

	public function getMouse() {
		var gx = hxd.Stage.getInstance().mouseX;
		var gy = hxd.Stage.getInstance().mouseY;
		var x = Std.int( gx/Const.SCALE-scroller.x );
		var y = Std.int( gy/Const.SCALE-scroller.y );
		return {
			x : x,
			y : y,
			cx : Std.int(x/Const.GRID),
			cy : Std.int(y/Const.GRID),
		}
	}

	public function isSlowMo() {
		#if debug
		if( Key.isDown(Key.SHIFT) )
			return false;
		#end
		return !isReplay && hero.isAlive() && !hero.controlsLocked() && en.Mob.ALL.length>0;
	}

	public function getSlowMoDt() {
		return isSlowMo() ? dt*Const.PAUSE_SLOWMO : dt;
	}

	public function getSlowMoFactor() {
		return isSlowMo() ? Const.PAUSE_SLOWMO : 1;
	}

	override public function update() {
		super.update();

		// Updates
		for(e in Entity.ALL) {
			e.setDt(dt);
			if( !e.destroyed ) e.preUpdate();
			if( !e.destroyed ) e.update();
			if( !e.destroyed ) e.postUpdate();
		}
		gc();

		if( Main.ME.keyPressed(hxd.Key.R) )
			Main.ME.restartGame();
			//Main.ME.restartGame( hxd.Key.isDown(hxd.Key.CTRL) ? heroHistory : null );

		if( isReplay && heroHistory.length>0 && itime>=heroHistory[0].t )
			hero.executeAction(heroHistory.shift().a);
	}
}
