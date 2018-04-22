package en;

class Hero extends Entity {

	public function new(x,y) {
		super(x,y);

		var g = new h2d.Graphics(spr);
		g.beginFill(0x00FF00,1);
		g.drawCircle(0,0,10);
	}
}