import mt.Process;
import mt.deepnight.Tweenie;
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
	var mask : h2d.Graphics;

	public var waveId : Int;
	public var isReplay : Bool;
	public var heroHistory : Array<HistoryEntry>;

	public var hud : h2d.Flow;

	public var cm : mt.deepnight.Cinematic;


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

		cm = new mt.deepnight.Cinematic(Const.FPS);
		//Console.ME.runCommand("+ bounds");

		scroller = new h2d.Layers(root);
		vp = new Viewport();
		fx = new Fx();

		clickTrap = new h2d.Interactive(1,1,Main.ME.root);
		//clickTrap.backgroundColor = 0x4400FF00;
		clickTrap.onPush = onMouseDown;
		//clickTrap.enableRightButton = true;

		mask = new h2d.Graphics(Main.ME.root);
		mask.visible = false;

		hud = new h2d.Flow();
		root.add(hud, Const.DP_UI);
		hud.horizontalSpacing = 1;

		level = new Level();
		hero = new en.Hero(2,6);

		#if debug
		hero.setPosCase(8,6);
		startWave(0);
		#else
		logo();
		if( !Main.ME.cd.hasSetS("intro",Const.INFINITE) ) {
			startWave(0);
			delayer.addS( function() {
				announce("A fast turned-based action game",0x706ACC);
			}, 1);
			cm.create( {
				hud.visible = false;
				hero.moveTarget = new FPoint(8*Const.GRID, hero.footY);
				end("move");
				500;
				hero.executeAction(Reload);
				1500;
				hero.say("Let's finish this.",0xFBAD9F);
				end;
				hud.visible = true;
				1000;
			});
		}
		else {
			hero.setPosCase(8,6);
			startWave(0);
		}
		#end

		// Testing
		#if debug
		{
			//new en.Cover(5,4);
			//new en.Cover(10,4);
			//new en.m.Grenader(16,4);
			//new en.m.Heavy(12,4);
			//level.waveMobCount = en.Mob.ALL.length;
		}
		#end

		vp.repos();

		onResize();
	}

	//function updateWave() {
		//var n = 0;
		//for(e in en.Cover.ALL)
			//if( e.isAlive() )
				//n++;
		//for(i in n...2) {
			//var e = new en.Cover(10,0);
		//}
	//}

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

		hud.x = Std.int( w()*0.5/Const.SCALE - hud.outerWidth*0.5 );
		hud.y = Std.int( level.hei*Const.GRID + 6 );

		mask.clear();
		mask.beginFill(0x0,1);
		mask.drawRect(0,0, w(), h());
	}

	override public function onDispose() {
		super.onDispose();

		mask.remove();
		clickTrap.remove();
		cm.destroy();

		for(e in Entity.ALL)
			e.destroy();
		gc();

		if( ME==this )
			ME = null;
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

	public function logo() {
		var e = Assets.gameElements.h_get("logo",root);
		e.y = 30;
		e.colorize(0x3D65C2);
		e.blendMode = Add;
		tw.createMs(e.x, 500|-e.tile.width>12, 250).onEnd = function() {
			var d = 5000;
			tw.createMs(e.alpha, d|0, 1500).onEnd = e.remove;
		}

	}

	public function announce(txt:String, ?c=0xFFFFFF, ?permanent=false) {
		var tf = new h2d.Text(Assets.font,root);
		tf.text = txt;
		tf.textColor = c;
		tf.y = Std.int( 58 - tf.textHeight );
		tw.createMs(tf.x, 500|-tf.textWidth>12, 200).onEnd = function() {
			if( !permanent ) {
				var d = 1000+txt.length*75;
				tw.createMs(tf.alpha, d|0, 1500).onEnd = tf.remove;
			}
		}
	}

	var lastNotif : Null<h2d.Text>;
	public function notify(txt:String, ?c=0xFFFFFF) {
		if( lastNotif!=null )
			lastNotif.remove();

		var tf = new h2d.Text(Assets.font,root);
		lastNotif = tf;
		tf.text = txt;
		tf.textColor = c;
		tf.y = Std.int( 100 - tf.textHeight );
		tw.createMs(tf.x, -tf.textWidth>12, 200).onEnd = function() {
			var d = 650+txt.length*75;
			tw.createMs(tf.alpha, d|0, 1500).onEnd = function() {
				tf.remove();
				if( lastNotif==tf )
					lastNotif = null;
			}
		}
	}

	public function hasCinematic() {
		return !cm.isEmpty();
	}

	public function startWave(id:Int) {
		waveId = id;

		for(e in en.Mob.ALL)
			e.destroy();

		level.startWave(waveId);

		if( waveId==2 ) {
			fx.clear();
			fx.allSpots(25, level.wid*Const.GRID);
			fx.flashBangS(0xFFCC00,0.5,0.5);
			for(e in en.DeadBody.ALL)
				e.destroy();

			for(e in en.Cover.ALL)
				e.destroy();
		}

		level.waveMobCount = 1;
		if( waveId>7 )
			announce("Thank you for playing ^_^\nA 20h game by Sebastien Benard\ndeepnight.net",true);
		else {
			if( waveId<=0 )
				level.attacheWaveEntities();
			else {
				announce("Wave "+waveId+"...", 0xFFD11C);
				delayer.addS(function() {
					announce("          Fight!", 0xEF4810);
				}, 0.5);
				delayer.addS(function() {
					level.attacheWaveEntities();
					cd.unset("lockNext");
				}, waveId==0 ? 1 : 1);
			}
		}
	}

	function exitLevel() {
		cd.setS("lockNext",Const.INFINITE);
		switch( waveId ) {
			case 1 :
				cm.create( {
					mask.visible = true;
					tw.createS(mask.alpha, 0>1, 0.6);
					600;
					hero.setPosCase(0, level.hei-3);
					startWave(waveId+1);
					tw.createS(mask.alpha, 0, 0.3);
					mask.visible = false;
					hero.moveTarget = new FPoint(hero.centerX+30, hero.footY);
					end("move");
				});

			default :
				startWave(waveId+1);
		}
	}

	public function isSlowMo() {
		#if debug
		if( Key.isDown(Key.SHIFT) )
			return false;
		#end
		if( isReplay || !hero.isAlive() || hero.controlsLocked() )
			return false;

		for(e in en.Mob.ALL)
			if( e.isAlive() && e.canBeShot() )
				return true;

		return false;
	}

	public function getSlowMoDt() {
		return isSlowMo() ? dt*Const.PAUSE_SLOWMO : dt;
	}

	public function getSlowMoFactor() {
		return isSlowMo() ? Const.PAUSE_SLOWMO : 1;
	}

	function canStartNextWave() {
		if( level.waveMobCount>0 )
			return false;

		if( cd.has("lockNext") || hasCinematic() )
			return false;

		return switch( waveId ) {
			case 0 : level.waveMobCount<=0;
			case 1 : hero.cx>=level.wid-2;

			default : level.waveMobCount<=0;
		}
	}

	override public function update() {
		cm.update(dt);

		super.update();

		// Updates
		for(e in Entity.ALL) {
			e.setDt(dt);
			if( !e.destroyed ) e.preUpdate();
			if( !e.destroyed ) e.update();
			if( !e.destroyed ) e.postUpdate();
		}
		gc();

		if( canStartNextWave() )
			exitLevel();

		if( Main.ME.keyPressed(hxd.Key.ESCAPE) ) {
			if( Key.isDown(Key.SHIFT) ) {
				Main.ME.cd.unset("intro");
				Assets.musicIn.stop();
				Assets.musicOut.stop();
				Main.ME.restartGame();
			}
			else
				Main.ME.restartGame();
		}

		#if debug
		if( Main.ME.keyPressed(Key.N) )
			startWave(waveId+1);
		if( Main.ME.keyPressed(Key.K) )
			for(e in en.Mob.ALL)
				if( e.isAlive() )
					e.hit(99, hero, true);
		#end

		if( Main.ME.keyPressed(hxd.Key.S) ) {
			notify("Sounds: "+(mt.deepnight.Sfx.isMuted(0) ? "ON" : "off"));
			mt.deepnight.Sfx.toggleMuteGroup(0);
			Assets.SBANK.grunt0().playOnGroup(0);
		}

		if( Main.ME.keyPressed(hxd.Key.M) ) {
			notify("Music: "+(mt.deepnight.Sfx.isMuted(1) ? "ON" : "off"));
			mt.deepnight.Sfx.toggleMuteGroup(1);
		}

		if( isReplay && heroHistory.length>0 && itime>=heroHistory[0].t )
			hero.executeAction(heroHistory.shift().a);
	}
}
