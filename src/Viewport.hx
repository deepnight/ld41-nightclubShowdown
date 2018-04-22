import mt.deepnight.Lib;
import mt.MLib;

class Viewport extends mt.Process {
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;
	var targetEnt : Null<Entity>;
	var targetPt : Null<{ x:Float, y:Float }>;

	public var x = 0.;
	public var y = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var wid(get,never) : Int;
	public var hei(get,never) : Int;
	public var screenWid(get,never) : Int;
	public var screenHei(get,never) : Int;

	public function new() {
		super(Game.ME);
	}

	inline function get_screenWid() return Boot.ME.s2d.width;
	inline function get_screenHei() return Boot.ME.s2d.height;

	inline function get_wid() {
		return MLib.ceil( Boot.ME.s2d.width / Const.SCALE );
	}

	inline function get_hei() {
		return MLib.ceil( Boot.ME.s2d.height / Const.SCALE );
	}

	public function track(?e:Entity, ?x:Float, ?y:Float) {
		targetEnt = null;
		targetPt = null;
		if( e!=null )
			targetEnt = e;
		else
			targetPt = { x:x, y:y }
	}

	public function repos() {
		if( targetEnt!=null ) {
			x = targetEnt.footX;
			y = targetEnt.footY;
		}
	}

	override public function update() {
		super.update();

		if( targetEnt!=null ) {
			var a = Math.atan2(targetEnt.footY-y, targetEnt.footX-x);
			var d = mt.deepnight.Lib.distance(x, y, targetEnt.footX, targetEnt.footY);
			if( d>=10 ) {
				var s = 0.5 * MLib.fclamp(d/100,0,1);
				dx+=Math.cos(a)*s;
				dy+=Math.sin(a)*s;
			}
		}
		else if( targetPt!=null ) {
			var a = Math.atan2(targetPt.y-y, targetPt.x-x);
			var d = mt.deepnight.Lib.distance(x, y, targetPt.x, targetPt.y);
			if( d>=10 ) {
				var s = 2 * MLib.fclamp(d/100,0,1);
				dx+=Math.cos(a)*s;
				dy+=Math.sin(a)*s;
			}
		}

		x+=dx;
		y+=dy;
		dx*=0.8;
		dy*=0.8;
		x = MLib.fclamp(x,-screenWid,0);
		var prioCenter = 0.3;
		if( Console.ME.has("screen") ) {
			game.scroller.x = -level.wid*0.5*Const.GRID + wid*0.5;
			game.scroller.y = -level.hei*0.5*Const.GRID + hei*0.5;
		}
		else {
			game.scroller.x = Std.int( -(x+prioCenter*level.wid*0.5*Const.GRID)/(1+prioCenter) + wid*0.5 );
			game.scroller.y = Std.int( -(y+prioCenter*level.hei*0.5*Const.GRID)/(1+prioCenter) + hei*0.5 );
		}
	}
}