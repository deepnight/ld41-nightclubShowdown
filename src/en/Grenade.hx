package en;

import mt.MLib;

class Grenade extends Entity {
	var range : Float;

	public function new(e:Entity) {
		super(e.cx,e.cy);
		xr = e.xr;
		yr = e.yr;

		dir = e.dir;
		gravity*=0.25;
		frict = 0.98;
		cd.setS("timer",1.25);
		radius = 5;
		range = Const.GRID*2;

		spr.set("grenade");
		spr.setCenterRatio(0.5,0.5);
	}

	override public function dispose() {
		super.dispose();
	}

	override function onLand() {
		frict = 0.93;
		dy = -dy*0.8;
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.y-=3;
		spr.rotation+=dx*2;
	}

	override public function update() {
		super.update();

		if( cd.getS("timer")<=0.5 && !cd.hasSetS("warn",0.1) )
			fx.warnZone(centerX, centerY, range);

		if( !cd.has("timer") ) {
			fx.grenade(centerX,centerY,range);
			if( distPx(game.hero)<=range ) {
				game.hero.violentBump(dirTo(game.hero)*0.28, -0.2, 0.5);
				game.hero.hit(2, this, true);
			}

			for(e in en.Cover.ALL)
				if( distPx(e)<=range )
					e.hit(999, this, true);

			destroy();
		}
	}
}
