import mt.Process;
import mt.MLib;

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

	public var ammoBar : h2d.Flow;

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

		ammoBar = new h2d.Flow();
		root.add(ammoBar, Const.DP_UI);
		ammoBar.horizontalSpacing = 1;

		hero = new en.Hero(8,0);
		new en.Cover(6,3);

		new en.m.GunGuy(10,4);
		new en.m.GunGuy(4,4);
		var m = new en.m.GunGuy(13,4);
		var c = new en.Cover(12,4);
		m.startCover(c,1);

		vp.track(level.wid*0.33*Const.GRID, level.hei*0.5*Const.GRID);
		//vp.track(hero);
		vp.repos();

		onResize();
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
		ammoBar.x = w()*0.5/Const.SCALE - ammoBar.outerWidth*0.5;
		ammoBar.y = 8;
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
