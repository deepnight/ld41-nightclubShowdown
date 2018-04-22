package en;

import mt.MLib;

class Cover extends Entity {
	public static var ALL : Array<Cover> = [];

	public var left : Area;
	public var right : Area;

	public var broken : Bool;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);

		spr.set("crate");
		initLife(3);

		var r = 11;
		left = new Area(this, r, function() return centerX-r, function() return centerY);
		left.color = 0x009500;
		right = new Area(this, r, function() return centerX+r, function() return centerY);
		right.color = 0x17FF17;
	}


	override function onDie() {
		spr.set("crateBroken");
	}

	override public function isBlockingHeroMoves() return isAlive();

	public function canHostSomeone(side:Int) {
		if( !isAlive() )
			return false;

		for(e in Entity.ALL)
			if( e.cover==this && dirTo(e)==side )
				return false;
		return true;
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function update() {
		super.update();
	}
}

