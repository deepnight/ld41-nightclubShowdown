import mt.Process;
import mt.MLib;

class Game extends mt.Process {
	public static var ME : Game;
	public var scroller : h2d.Layers;
	public var vp : Viewport;
	public var fx : Fx;
	public var level : Level;
	public var hero : en.Hero;
	var clickTrap : h2d.Interactive;

	public function new(ctx:h2d.Sprite) {
		super(Main.ME);

		ME = this;
		createRoot(ctx);

		trace("new game");

		scroller = new h2d.Layers(root);
		vp = new Viewport();
		fx = new Fx();

		clickTrap = new h2d.Interactive(1,1,Main.ME.root);
		//clickTrap.backgroundColor = 0x4400FF00;
		clickTrap.onPush = onMouseDown;
		clickTrap.enableRightButton = true;

		level = new Level();

		hero = new en.Hero(8,0);
		new en.m.GunGuy(14,3);
		new en.m.GunGuy(18,2);
		new en.m.GunGuy(3,1);

		vp.track(level.wid*0.5*Const.GRID, level.hei*0.5*Const.GRID);

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
		return hero.isAlive() && !hero.controlsLocked() && en.Mob.ALL.length>0;
	}

	public function getSlowMoDt() {
		return isSlowMo() ? dt*Const.PAUSE_SLOWMO : dt;
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
	}
}
