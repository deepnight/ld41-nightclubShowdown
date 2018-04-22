package en;

import mt.MLib;

class DeadBody extends Entity {
	public function new(e:Entity) {
		super(e.cx,e.cy);
		xr = e.xr;
		yr = e.yr;

		dx = e.lastHitDir * rnd(0.2,0.2);
		dir = -e.lastHitDir;
		gravity*=0.25;
		frict = 0.97;
		dy = -0.1;
		spr.anim.registerStateAnim("dummyDeathBounce",2, function() return !onGround && cd.has("hitGround"));
		spr.anim.registerStateAnim("dummyDeathFly",1, function() return !onGround);
		spr.anim.registerStateAnim("dummyDeathGround",0);
		spr.colorize(e.spr.color.toColor());
		cd.setS("bleeding",2);
	}

	override public function dispose() {
		super.dispose();
	}

	override function onLand() {
		if( MLib.fabs(dy)<=0.1 )
			dy = 0;
		else
			dy = -dy*0.7;
		frict = 0.8;
		cd.setS("hitGround",Const.INFINITE);
	}

	override public function update() {
		super.update();
		if( cd.has("bleeding") && !cd.hasSetS("bleedFx",0.03) )
			fx.woundBleed(centerX,centerY);

		if( !onGround ) {
			for(e in en.Cover.ALL)
				if( distPx(e)<=radius+e.radius && !e.cd.hasSetS("bodyHit",0.1) )
					e.hit(3,this,true);

			for(e in en.Mob.ALL)
				if( e.isAlive() && distPx(e)<=radius+e.radius && !e.cd.hasSetS("bodyHit",0.4) ) {
					violentBump(dirTo(e)*0.4, -0.2, 0.5);
				}
		}
	}
}
