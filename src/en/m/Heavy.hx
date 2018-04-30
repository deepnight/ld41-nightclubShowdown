package en.m;

class Heavy extends en.Mob {

	public function new(x,y) {
		super(x,y);

		initLife(6);

		spr.anim.registerStateAnim("cRun",3, function() return cd.has("entering"));
		spr.anim.registerStateAnim("cPush",2, function() return !onGround && isStunned());
		spr.anim.registerStateAnim("cStun",1, function() return isStunned());
		spr.anim.registerStateAnim("cIdle",0);

		var s = createSkill("shoot");
		s.setTimers(1, 0.7, 0.3);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("cAim");
		}
		s.onProgress = function(t) lookAt(s.target);
		s.onInterrupt = function() spr.anim.stopWithStateAnims();
		s.onExecute = function(e) {
			lookAt(e);
			dy = -0.1;
			if( e.hit(1,this) ) {
				e.dx*=0.3;
				e.dx+=dirTo(e)*rnd(0.03,0.06);
				e.lockMovementsS(0.3);
				e.lockControlsS(0.3);
				fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
			}
			Assets.SBANK.pew2(1);
			fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFF0000);
			spr.anim.play("cAimShoot").chainFor("cBlind",Const.FPS*0.2);
		}

		lockControlsS(rnd(0.3,1.6));
	}

	override public function stunS(t:Float) {
	}

	override public function canBeGrabbed() {
		return false;
	}

	override function onDie() {
		super.onDie();
		new en.DeadBody(this,"c");
	}

	override function get_shootY():Float {
		return switch( curAnimId ) {
			case "cBlind" : footY - 13;
			case "cAim" : footY - 18;
			default : super.get_shootY();
		}
	}
	override function get_headY():Float {
		if( spr!=null && !spr.destroyed )
			return super.get_headY() + switch( spr.groupName ) {
				case "cStun" : 7;
				default : 0;
			}
		return super.get_headY();
	}

	override function onDamage(v:Int) {
		super.onDamage(v);

		spr.anim.playOverlap("cHit");
		playHitSound();

		if( getDiminishingReturnFactor("hitInterrupt", 3,3)>0 )
			interruptSkills(true);
	}

	override public function update() {
		super.update();

		if( !controlsLocked() && onGround && tx==-1 ) {
			if( getSkill("shoot").isReady() && game.hero.isAlive() )
				getSkill("shoot").prepareOn(game.hero);
		}
	}
}

