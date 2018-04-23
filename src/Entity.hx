import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;

class Entity {
	public static var ALL : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var hero(get,never) : en.Hero; inline function get_hero() return Game.ME.hero;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var destroyed(default,null) = false;
	public var cd : mt.Cooldown;
	public var dt : Float;

	public var spr : HSprite;
	public var debug : Null<h2d.Graphics>;
	public var label : Null<h2d.Text>;
	var cAdd : h3d.Vector;
	var lifeBar : h2d.Flow;

	public var uid : Int;
	public var cx = 0;
	public var cy = 0;
	public var xr = 0.;
	public var yr = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var frict = 0.9;
	public var gravity = 0.02;
	public var weight = 1.;
	public var radius : Float;
	public var dir(default,set) = 1;
	public var hasColl = true;
	public var isAffectBySlowMo = true;
	public var lastHitDir = 0;

	public var life : Int;
	public var maxLife : Int;
	var skills : Array<Skill>;
	var diminishingUses : Map<String,Int> = new Map();
	var head : Area;
	var torso : Area;
	var legs : Area;
	public var cover : Null<en.Cover>;

	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;
	public var centerX(get,never) : Float; inline function get_centerX() return footX;
	public var centerY(get,never) : Float; inline function get_centerY() return footY-radius;
	public var headX(get,never) : Float; function get_headX() return footX;
	public var headY(get,never) : Float; function get_headY() return footY-22;
	public var shootX(get,never) : Float; function get_shootX() return footX+dir*11;
	public var shootY(get,never) : Float; function get_shootY() return footY-radius*0.8;

	public var onGround(get,never) : Bool; inline function get_onGround() return level.hasColl(cx,cy+1) && yr>=1 && dy==0;
	public var curAnimId(get,never) : String; inline function get_curAnimId() return !isAlive() || spr==null || spr.destroyed ? "" : spr.groupName;

	private function new(x,y) {
		uid = Const.UNIQ++;
		ALL.push(this);

		lifeBar = new h2d.Flow();
		game.scroller.add(lifeBar, Const.DP_UI);
		lifeBar.horizontalSpacing = 1;
		lifeBar.visible = false;

		cd = new mt.Cooldown(Const.FPS);
		radius = Const.GRID*0.6;
		setPosCase(x,y);
		initLife(3);
		skills = [];

		spr = new mt.heaps.slib.HSprite(Assets.gameElements);
		//spr = new mt.heaps.slib.HSprite(Assets.gameElements);
		game.scroller.add(spr, Const.DP_PROPS);
		spr.setCenterRatio(0.5,1);
		spr.colorAdd = cAdd = new h3d.Vector();

		head = new Area(this, 6, function() return headX, function() return headY);
		head.color = 0xFF0000;

		torso = new Area(this, 8, function() return (headX+footX)*0.5, function() return (headY+footY-4)*0.5);
		torso.color = 0x0080FF;

		legs = new Area(this, 5, function() return footX, function() return footY-4);
		legs.color = 0x9D55DF;
	}

	public function isBlockingHeroMoves() return false;

	public function initLife(v) {
		life = maxLife = v;
		updateLifeBar();
	}

	function updateLifeBar() {
		lifeBar.removeChildren();
		for( i in 0...maxLife ) {
			var e = Assets.gameElements.h_get("dot",lifeBar);
			e.scaleY = 2;
			e.colorize(i+1<=life ? 0xFFFFFF : 0xCC0000);
		}
	}

	public function isCoveredFrom(source:Entity) {
		return source==null ? false : cover!=null && cover.isAlive() && dirTo(source)==dirTo(cover);
	}

	public function hit(dmg:Int, source:Entity, ?ignoreCover=false) : Bool {
		if( source!=null )
			lastHitDir = source.dirTo(this);

		if( dmg<=0 || !isAlive() )
			return false;

		if( !ignoreCover && isCoveredFrom(source) ) {
			cover.hit(dmg, source);
			return false;
		}

		dmg = MLib.min(life,dmg);
		life-=dmg;
		updateLifeBar();
		onDamage(dmg);
		blink();
		if( life<=0 ) {
			interruptSkills(false);
			onDie();
		}
		return true;
	}


	public function violentBump(bdx:Float, bdy:Float, sec:Float) {
		if( !isAlive() )
			return;

		this.dx = bdx;
		this.dy = bdy;
		dir = bdx>0 ? -1 : 1;
		stunS(sec);
		interruptSkills(false);
	}

	function onDamage(v:Int) {
		//leaveCover();
	}

	function onDie() {
		destroy();
	}

	public inline function isAlive() {
		return life>0 && !destroyed;
	}

	public function toString() {
		return Type.getClassName(Type.getClass(this))+"#"+uid;
	}

	public function createSkill(id:String) : Skill {
		var s = new Skill(id, this);
		skills.push(s);
		return s;
	}

	public function interruptSkills(startCd:Bool) {
		for(s in skills)
			s.interrupt(startCd);
	}

	public function getSkill(id:String) : Null<Skill> {
		for(s in skills)
			if( s.id==id )
				return s;
		return null;
	}

	public function movementLocked() {
		return cd.has("moveLock") || isStunned();
	}
	public function lockMovementsS(t:Float) {
		if( isAlive() )
			cd.setS("moveLock",t,false);
	}

	public function controlsLocked() {
		return cd.has("ctrlLock") || isStunned();
	}
	public function lockControlsS(t:Float) {
		if( isAlive() )
			cd.setS("ctrlLock",t,false);
	}

	public function stunS(t:Float) {
		if( isAlive() )
			cd.setS("stun",t,false);
	}
	public function isStunned() {
		return cd.has("stun");
	}
	//public function pop(str:String, ?c=0x30D9E7) {
		//var tf = new h2d.Text(Assets.font);
		//game.scroller.add(tf, Const.DP_UI);
		//tf.text = str;
		//tf.textColor = c;
//
		//tf.x = Std.int(footX-tf.textWidth*0.5);
		//tf.y = Std.int( footY-5 );
		//game.tw.createS(tf.y, tf.y-20, 0.15);
		//game.tw.createS(tf.scaleY, 0>1, 0.15);
		//game.delayer.addS( function() {
			//game.tw.createS(tf.y, tf.y-15,1);
		//}, 0.15);
		//game.delayer.addS( function() {
			//game.tw.createS(tf.alpha, 1>0, 0.4).end(function() {
				//tf.remove();
			//});
		//}, 2);
	//}

	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
	}

	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
	}

	public function setLabel(?str:String, ?c=0xFFFFFF) {
		if( str==null && label!=null ) {
			label.remove();
			label = null;
		}
		if( str!=null ) {
			if( label==null ) {
				label = new h2d.Text(Assets.font);
				game.scroller.add(label, Const.DP_UI);
			}
			label.text = str;
			label.textColor = c;
		}
	}

	public function startCover(c:en.Cover, side:Int) {
		if( !c.canHostSomeone(side) )
			return false;

		dx = dy = 0;
		cover = c;
		setPosCase(c.cx+side, c.cy);
		xr = 0.5-side*0.25;
		yr = 1;
		lookAt(c);
		return true;
	}

	public function leaveCover() {
		cover = null;
	}


	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p=1) return Lib.prettyFloat(v,p);

	public inline function distCase(e:Entity) {
		return Lib.distance(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	}

	public inline function distPx(e:Entity) {
		return Lib.distance(footX, footY, e.footX, e.footY);
	}

	public inline function distPxFree(x:Float, y:Float) {
		return Lib.distance(footX, footY, x, y);
	}

	//function canSeeThrough(x,y) return !level.hasColl(x,y);
//
	//public inline function sightCheck(e:Entity) {
		//if( level.hasColl(cx,cy) || level.hasColl(e.cx,e.cy) )
			//return true;
		//return mt.deepnight.Bresenham.checkThinLine(cx, cy, e.cx, e.cy, canSeeThrough);
	//}
//
	//public inline function sightCheckCase(x,y) {
		//return mt.deepnight.Bresenham.checkThinLine(cx, cy, x, y, canSeeThrough);
	//}

	public inline function getMoveAng() {
		return Math.atan2(dy,dx);
	}

	public inline function angTo(e:Entity) return Math.atan2(e.footY-footY, e.footX-footX);
	public inline function dirTo(e:Entity) return e.footX<=footX ? -1 : 1;
	public inline function lookAt(e:Entity) dir = dirTo(e);
	public inline function isLookingAt(e:Entity) return dirTo(e)==dir;

	public inline function destroy() {
		destroyed = true;
	}

	public function is<T:Entity>(c:Class<T>) return Std.is(this, c);
	public function as<T:Entity>(c:Class<T>) : T return Std.instance(this, c);

	public function dispose() {
		ALL.remove(this);
		lifeBar.remove();
		cd.destroy();
		spr.remove();
		skills = null;
		if( label!=null )
			label.remove();
		if( debug!=null )
			debug.remove();
	}

	public function preUpdate() {
		cd.update(dt);
	}

	public function postUpdate() {
		spr.x = (cx+xr)*Const.GRID;
		spr.y = (cy+yr)*Const.GRID;
		spr.scaleX = dir;
		spr.anim.setGlobalSpeed( isAffectBySlowMo ? game.getSlowMoFactor() : 1 );

		if( label!=null ) {
			label.setPos( Std.int(footX-label.textWidth*0.5), Std.int(footY+2));
		}

		lifeBar.setPos( Std.int(footX-lifeBar.outerWidth*0.5), Std.int(footY+2));

		if( Console.ME.has("bounds") ) {
			if( debug==null ) {
				debug = new h2d.Graphics();
				game.scroller.add(debug, Const.DP_UI);
			}
			debug.setPos(footX, footY);
			debug.clear();
			debug.beginFill(0xFFFFFF,0.9);
			debug.drawRect(shootX-footX, shootY-footY, 2,2);

			debug.beginFill(0xE8DDB3,0.1);
			debug.lineStyle(1,0xE8DDB3,0.2);
			debug.drawCircle(0,-radius,radius);

			for(a in Area.ALL)
				if( a.owner==this ) {
					debug.beginFill(a.color,0.2); debug.lineStyle(1,a.color,0.4);
					debug.drawCircle(a.centerX-footX, a.centerY-footY, a.radius);
				}

			//var c = 0xFF0000; debug.beginFill(c,0.2); debug.lineStyle(1,c,0.7);
			//debug.drawCircle(head.centerX-footX, head.centerY-footY, head.radius);
//
			//var c = 0x0080FF; debug.beginFill(c,0.2); debug.lineStyle(1,c,0.7);
			//debug.drawCircle(torso.centerX-footX, torso.centerY-footY, torso.radius);
//
			//var c = 0x6D5BA4; debug.beginFill(c,0.2); debug.lineStyle(1,c,0.7);
			//debug.drawCircle(legs.centerX-footX, legs.centerY-footY, legs.radius);
		}
		if( !Console.ME.has("bounds") && debug!=null ) {
			debug.remove();
			debug = null;
		}

		cAdd.r*=Math.pow(0.93,dt);
		cAdd.g*=Math.pow(0.8,dt);
		cAdd.b*=Math.pow(0.8,dt);
	}

	//function hasCircColl() {
		//return !destroyed && weight>=0 && !cd.has("rolling") && altitude<=5;
	//}
//
	//function hasCircCollWith(e:Entity) {
		//return true;
	//}

	public function getDiminishingReturnFactor(id:String, fullUses:Int, maxUses:Int) : Float {
		if( !diminishingUses.exists(id) )
			diminishingUses.set(id,1);
		else
			diminishingUses.set(id, diminishingUses.get(id)+1);

		var n = diminishingUses.get(id);
		if( n<=fullUses )
			return 1;
		else if( n>maxUses )
			return 0;
		else
			return 1 - ( n-fullUses ) / ( maxUses-fullUses+1 );
	}

	public function onClick(x:Float, y:Float, bt:Int) {
	}

	function onTouch(e:Entity) { }
	function onBounce(pow:Float) {}
	function onTouchWall(wallDir:Int) {
		dx*=0.5;
	}
	function onTouchCeiling() {
		dy = 0;
	}
	function onLand() {
		dy = 0;
	}

	public function blink() {
		cAdd.r = 1;
		cAdd.g = 1;
		cAdd.b = 1;
	}

	public function setDt(v:Float) {
		dt = v * ( isAffectBySlowMo && game.isSlowMo() ? Const.PAUSE_SLOWMO : 1 );
	}

	public function hasSkillCharging() {
		for(s in skills)
			if( s.isCharging() )
				return true;
		return false;
	}

	public function canInterruptSkill() {
		return true;
	}

	public function update() {
		for( s in skills )
			s.update(dt);

		if( cover!=null && !cover.isAlive() )
			leaveCover();

		//// Circular collisions
		//if( hasCircColl() )
			//for(e in ALL)
				//if( e!=this && e.hasCircColl() && hasCircCollWith(e) && e.hasCircCollWith(this) ) {
					//var d = distPx(e);
					//if( d<=radius+e.radius ) {
						//var repel = 0.05;
						//var a = Math.atan2(e.footY-footY, e.footX-footX);
//
						//var r = e.weight==weight ? 0.5 : e.weight / (weight+e.weight);
						//if( r<=0.1 ) r = 0;
						//dx-=Math.cos(a)*repel * r;
						//dy-=Math.sin(a)*repel * r;
//
						//var r = e.weight==weight ? 0.5 : weight / (weight+e.weight);
						//if( r<=0.1 ) r = 0;
						//e.dx+=Math.cos(a)*repel * r;
						//e.dy+=Math.sin(a)*repel * r;
//
						//onTouch(e);
						//e.onTouch(this);
					//}
				//}

		if( cover!=null ) {
			dx = dy = 0;
		}

		// X
		var steps = MLib.ceil( MLib.fabs(dx*dt) );
		var step = dx*dt / steps;
		while( steps>0 ) {
			xr+=step;
			if( hasColl ) {
				if( xr>0.7 && level.hasColl(cx+1,cy) ) {
					xr = 0.7;
					onTouchWall(1);
					steps = 0;
				}
				if( xr<0.3 && level.hasColl(cx-1,cy) ) {
					xr = 0.3;
					onTouchWall(-1);
					steps = 0;
				}
			}
			while( xr>1 ) { xr--; cx++; }
			while( xr<0 ) { xr++; cx--; }
			steps--;
		}
		dx*=Math.pow(frict,dt);

		// Gravity
		if( !onGround )
			dy += gravity*dt;

		// Y
		var steps = MLib.ceil( MLib.fabs(dy*dt) );
		var step = dy*dt / steps;
		while( steps>0 ) {
			yr+=step;
			if( hasColl ) {
				if( yr>1 && level.hasColl(cx,cy+1) ) {
					yr = 1;
					onLand();
					//steps = 0;
				}
				if( yr<0.3 && level.hasColl(cx,cy-1) ) {
					yr = 0.3;
					onTouchCeiling();
					steps = 0;
				}
			}
			while( yr>1 ) { yr--; cy++; }
			while( yr<0 ) { yr++; cy--; }
			steps--;
		}
		dy*=Math.pow(frict,dt);
	}
}