package en.m;

class BasicGun extends en.Mob {

	public function new(x,y) {
		super(x,y);

		initLife(4);

		spr.anim.registerStateAnim("aRun",3, function() return cd.has("entering"));
		spr.anim.registerStateAnim("aPush",2, function() return !onGround && isStunned());
		spr.anim.registerStateAnim("aStun",1, function() return isStunned());
		spr.anim.registerStateAnim("aIdle",0);
		//spr.colorize(0x911A0D);


		var s = createSkill("shoot");
		s.setTimers(1, 0.7, 0.3);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("aAim");
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
			fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFF0000);
			spr.anim.play("aAimShoot").chainFor("aBlind",Const.FPS*0.2);
		}

		lockControlsS(rnd(0.3,1.6));
	}

	override function onDie() {
		super.onDie();
		new en.DeadBody(this,"a");
	}

	override function get_shootY():Float {
		return switch( curAnimId ) {
			case "aBlind" : footY - 13;
			case "aAim" : footY - 18;
			default : super.get_shootY();
		}
	}
	override function get_headY():Float {
		if( spr!=null && !spr.destroyed )
			return super.get_headY() + switch( spr.groupName ) {
				case "aStun" : 11;
				default : 0;
			}
		return super.get_headY();
	}

	override function onDamage(v:Int) {
		super.onDamage(v);

		spr.anim.playOverlap("aHit");

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

