package en.m;

class GunGuy extends en.Mob {

	public function new(x,y) {
		super(x,y);

		initLife(2);

		spr.anim.registerStateAnim("dummyStun",1, function() return isStunned());
		spr.anim.registerStateAnim("dummyIdle",0);


		var s = createSkill("shoot");
		s.setTimers(1, 0, 0.5);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("dummyAim");
		}
		//s.onProgress = function(t) setLabel("preparing "+Std.int(t*100)+"%");
		s.onInterrupt = function() spr.anim.stopWithStateAnims();
		s.onExecute = function(e) {
			dy = -0.1;
			e.hit(1,this);
			e.dx*=0.3;
			e.dx+=dirTo(e)*rnd(0.06,0.10);
			e.lockMovementsS(0.3);
			e.lockControlsS(0.3);
			fx.bloodHit(shootX, shootY, e.centerX, e.centerY, dirTo(e));
			spr.anim.play("dummyShoot");
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

		if( !controlsLocked() && onGround && getSkill("shoot").isReady() )
			getSkill("shoot").prepareOn(game.hero);
	}
}
