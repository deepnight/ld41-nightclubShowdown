package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	public function new(x,y) {
		super(x,y);

		ALL.push(this);

		//var g = new h2d.Graphics(spr);
		//g.beginFill(0xFF0000,1);
		//g.drawCircle(0,-radius,radius);

		initLife(4);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function update() {
		super.update();
	}
}
