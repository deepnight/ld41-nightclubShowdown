package en;

import mt.MLib;

class Cover extends Entity {
	public static var ALL : Array<Cover> = [];

	public var left : Area;
	public var right : Area;

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

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function update() {
		super.update();
	}
}

