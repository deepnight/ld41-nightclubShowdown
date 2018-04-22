package en.m;

class GunGuy extends en.Mob {

	public function new(x,y) {
		super(x,y);

		initLife(4);

		spr.anim.registerStateAnim("dummyStun",1, function() return isStunned());
		spr.anim.registerStateAnim("dummyIdle",0);


		var s = createSkill("shoot");
		s.setTimers(1, 0, 0.5);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("dummyAim");
		}
		s.onProgress = function(t) lookAt(s.target);
		s.onInterrupt = function() spr.anim.stopWithStateAnims();
		s.onExecute = function(e) {
			dy = -0.1;
			if( e.hit(1,this) ) {
				e.dx*=0.3;
				e.dx+=dirTo(e)*rnd(0.03,0.06);
				e.lockMovementsS(0.3);
				e.lockControlsS(0.3);
				fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
			}
			fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFF0000);
			spr.anim.play("dummyAimShoot").chainFor("dummyBlind",Const.FPS*0.2);
		}
	}

	override function get_shootY():Float {
		return switch( curAnimId ) {
			case "dummyBlind" : footY - 13;
			case "dummyAim" : footY - 18;
			default : super.get_shootY();
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
