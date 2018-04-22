import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;

class Entity {
	public static var ALL : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	//public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var destroyed(default,null) = false;
	public var cd : mt.Cooldown;
	public var dt : Float;

	public var spr : HSprite;
	public var label : Null<h2d.Text>;
	var cAdd : h3d.Vector;

	public var uid : Int;
	public var cx = 0;
	public var cy = 0;
	public var xr = 0.;
	public var yr = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var frict = 0.9;
	public var gravity = 0.04;
	public var weight = 1.;
	public var radius : Float;
	public var dir(default,set) = 1;
	public var hasColl = true;
	public var isAffectBySlowMo = true;

	public var life : Int;
	public var maxLife : Int;
	var skills : Array<Skill>;

	public var footX(get,never) : Float; inline function get_footX() return (cx+xr)*Const.GRID;
	public var footY(get,never) : Float; inline function get_footY() return (cy+yr)*Const.GRID;
	public var centerX(get,never) : Float; inline function get_centerX() return footX;
	public var centerY(get,never) : Float; inline function get_centerY() return footY-radius;
	public var headX(get,never) : Float; inline function get_headX() return footX;
	public var headY(get,never) : Float; inline function get_headY() return footY-radius*2;
	public var onGround(get,never) : Bool; inline function get_onGround() return level.hasColl(cx,cy+1) && yr>=1 && dy==0;

	private function new(x,y) {
		uid = Const.UNIQ++;
		ALL.push(this);

		cd = new mt.Cooldown(Const.FPS);
		radius = Const.GRID*0.6;
		setPosCase(x,y);
		initLife(3);
		skills = [];

		spr = new mt.heaps.slib.HSprite();
		//spr = new mt.heaps.slib.HSprite(Assets.gameElements);
		game.scroller.add(spr, Const.DP_HERO);
		spr.setCenterRatio(0.5,1);
		spr.colorAdd = cAdd = new h3d.Vector();
	}

	public function initLife(v) {
		life = maxLife = v;
	}

	public function hit(dmg:Int) {
		if( life>0 && dmg>0 ) {
			dmg = MLib.min(life,dmg);
			life-=dmg;
			onDamage(dmg);
			blink();
			if( life<=0 )
				onDie();
		}
	}

	function onDamage(v:Int) {
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
		return cd.has("moveLock");
	}
	public function lockMovementsS(t:Float) {
		cd.setS("moveLock",t);
	}

	public function controlsLocked() {
		return cd.has("ctrlLock");
	}
	public function lockControlsS(t:Float) {
		cd.setS("ctrlLock",t);
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
		yr = 0.5;
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
		cd.destroy();
		spr.remove();
		skills = null;
		if( label!=null )
			label.remove();
		//if( debug!=null )
			//debug.remove();
	}

	public function preUpdate() {
		cd.update(dt);
	}

	public function postUpdate() {
		spr.x = (cx+xr)*Const.GRID;
		spr.y = (cy+yr)*Const.GRID;
		spr.scaleX = dir;

		if( label!=null ) {
			label.setPos( Std.int(footX-label.textWidth*0.5), Std.int(footY+2));
		}

		//if( Console.ME.has("bounds") ) {
			//if( debug==null ) {
				//debug = new h2d.Graphics();
				//game.scroller.add(debug, Const.DP_UI);
			//}
			//if( !cd.hasSetS("debugRedraw",1) ) {
				//debug.beginFill(0xFFFF00,0.3);
				//debug.lineStyle(1,0xFFFF00,0.7);
				//debug.drawCircle(0,0,radius);
			//}
			//debug.setPos(footX, footY);
		//}
		//if( !Console.ME.has("bounds") && debug!=null ) {
			//debug.remove();
			//debug = null;
		//}

		cAdd.r*=0.9;
		cAdd.g*=0.75;
		cAdd.b*=0.75;
	}

	//function hasCircColl() {
		//return !destroyed && weight>=0 && !cd.has("rolling") && altitude<=5;
	//}
//
	//function hasCircCollWith(e:Entity) {
		//return true;
	//}

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

	public function update() {
		for( s in skills )
			s.update(dt);

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