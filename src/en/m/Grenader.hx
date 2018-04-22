package en.m;

class Grenader extends en.Mob {

	public function new(x,y) {
		super(x,y);

		initLife(5);

		spr.anim.registerStateAnim("dummyPush",2, function() return !onGround && cd.has("bodyHit"));
		spr.anim.registerStateAnim("dummyStun",1, function() return isStunned());
		spr.anim.registerStateAnim("dummyIdle",0);
		spr.colorize(0x911A0D);


		var s = createSkill("shoot");
		s.setTimers(0.6, 0, 3);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("dummyHit");
		}
		s.onProgress = function(t) lookAt(s.target);
		s.onInterrupt = function() spr.anim.stopWithStateAnims();
		s.onExecute = function(e) {
			dy = -0.1;
			var g = new en.Grenade(this);
			g.dx = dirTo(e)*0.2 * mt.MLib.fabs(e.cx-cx)/7; // 0.2 for 7 cells
			g.dy = -0.15;
			//if( e.hit(1,this) ) {
				//e.dx*=0.3;
				//e.dx+=dirTo(e)*rnd(0.03,0.06);
				//e.lockMovementsS(0.3);
				//e.lockControlsS(0.3);
				//fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
			//}
			//fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFF0000);
			spr.anim.play("dummyAimShoot").chainFor("dummyHit",Const.FPS*0.2);
		}
	}

	override function get_headY():Float {
		if( spr!=null && !spr.destroyed )
			return super.get_headY() + switch( spr.groupName ) {
				case "dummyStun" : 5;
				default : 0;
			}
		return super.get_headY();
	}

	override function onDamage(v:Int) {
		super.onDamage(v);

		spr.anim.playOverlap("dummyHit");

		if( getDiminishingReturnFactor("hitInterrupt", 3,3)>0 )
			interruptSkills(true);
	}

	override public function update() {
		super.update();

		if( !controlsLocked() && onGround && getSkill("shoot").isReady() && game.hero.isAlive() )
			getSkill("shoot").prepareOn(game.hero);
	}
}

