package en;

class Mob extends Entity {

	public function new(x,y) {
		super(x,y);

		var g = new h2d.Graphics(spr);
		g.beginFill(0xFF0000,1);
		g.drawCircle(0,-radius,radius);
	}

	override public function update() {
		super.update();
	}
}