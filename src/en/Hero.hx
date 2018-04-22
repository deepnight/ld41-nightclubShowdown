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
		frict = 1;
		dx = 0.2;

		var g = new h2d.Graphics(game.scroller);
		g.lineStyle(1,0xFFFF00,1);
		g.moveTo(0,0);
		g.lineTo(600,0);
		g.y = 100;

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
	}
}