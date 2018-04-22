package en;

import mt.MLib;
import mt.deepnight.*;
import mt.heaps.slib.*;

class Hero extends Entity {

	public function new(x,y) {
		super(x,y);

		var g = new h2d.Graphics(spr);
		g.beginFill(0x00FF00,1);
		g.drawCircle(0,-radius,radius);

		//initLife(3);
		initLife(Const.INFINITE);
	}

	override function onLand() {
		dy *= -0.8;
	}

	override function onTouchWall(wallDir:Int) {
		dx = -wallDir*MLib.fabs(dx);
	}

	override public function update() {
		super.update();
		//setLabel(""+dy);
		var m = game.getMouse();
		setLabel(m.cx+","+m.cy);
	}
}