package en;

import mt.MLib;
import mt.deepnight.*;
import mt.heaps.slib.*;

class Hero extends Entity {
	public var target : FPoint;

	public function new(x,y) {
		super(x,y);

		game.scroller.add(spr, Const.DP_HERO);
		spr.anim.registerStateAnim("dummyCover",1, function() return cover!=null);
		spr.anim.registerStateAnim("dummyIdle",0);

		//initLife(3);
		isAffectBySlowMo = false;
		initLife(Const.INFINITE);
		target = new FPoint(footX, footY);


		// blindShot shot
		var s = createSkill("blindShot");
		s.setTimers(0.25,0,0.1);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("dummyBlind");
		}
		s.onExecute = function(e) {
			if( e.hit(1,this) ) {
				var r = e.getDiminishingReturnFactor("blindShot",1,3);
				e.dx*=0.3;
				e.dx+=dirTo(e)*rnd(0.03,0.05)*r;
				e.stunS(0.7*r);
				fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
			}
			fx.shoot(shootX, shootY, e.centerX, e.centerY, 0xFFFF00);

			dy = -0.1;
			spr.anim.play("dummyBlindShoot").chainFor("dummyBlind",Const.FPS*0.1);
		}

		// Head shot
		var s = createSkill("headShot");
		s.setTimers(0.8,0,0.1);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("dummyAim");
		}
		s.onExecute = function(e) {
			if( e.hit(999,this,true) )
				fx.headShot(shootX, shootY, e.headX, e.headY, dirTo(e));
			fx.shoot(shootX, shootY, e.headX, e.headY, 0xFFFF00);

			dy = -0.1;
			spr.anim.play("dummyAimShoot");
		}
	}

	override function get_shootY():Float {
		return switch( curAnimId ) {
			case "dummyBlind" : footY - 13;
			case "dummyAim" : footY - 18;
			default : super.get_shootY();
		}
	}

	override function onTouchWall(wallDir:Int) {
		dx = -wallDir*MLib.fabs(dx);
	}

	override public function controlsLocked() {
		for(s in skills)
			if( s.isCharging() )
				return true;

		return super.controlsLocked() || target!=null || !onGround;
	}

	override public function onClick(x:Float, y:Float, bt) {
		super.onClick(x, y, bt);

		if( controlsLocked() )
			return;

		switch(bt) {
			case 0 :
				target = new FPoint(x,footY);
				leaveCover();

			case 1 :
				var dh = new DecisionHelper(en.Mob.ALL);
				dh.remove( function(e) return e.distPxFree(x,y)>=30 );
				dh.score( function(e) return -e.distPxFree(x,y) );
				var e = dh.getBest();
				if( e!=null ) {
					if( e.head.contains(x,y) && getSkill("headShot").isReady() )
						getSkill("headShot").prepareOn(e);
					else if( getSkill("blindShot").isReady() )
						getSkill("blindShot").prepareOn(e);
				}
		}

	}

	override public function update() {
		super.update();

		if( target!=null && !movementLocked() )
			if( MLib.fabs(centerX-target.x)<=5 ) {
				// Arrived
				for(e in en.Cover.ALL)
					if( e.left.contains(centerX,centerY) )
						startCover(e, -1);
					else if( e.right.contains(centerX,centerY) )
						startCover(e, 1);
				target = null;
				dx*=0.5;
			}
			else {
				var s = 0.015;
				if( target.x>centerX ) {
					dir = 1;
					dx+=s;
				}
				if( target.x<centerX ) {
					dir = -1;
					dx-=s;
				}
			}
	}
}