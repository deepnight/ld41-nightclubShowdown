package en;

import mt.MLib;
import mt.deepnight.*;
import mt.heaps.slib.*;

enum Action {
	None;
	BlindShot(e:Entity);
	HeadShot(e:Entity);
	Move(x:Float, y:Float);
	TakeCover(e:Cover, side:Int);
	Wait(sec:Float);
	Reload(sec:Float);
}

class Hero extends Entity {
	public var moveTarget : FPoint;
	public var afterMoveAction : Action;
	var icon : HSprite;

	public var ammo : Int;
	public var maxAmmo : Int;

	public function new(x,y) {
		super(x,y);

		afterMoveAction = None;

		game.scroller.add(spr, Const.DP_HERO);
		spr.anim.registerStateAnim("heroPush",11, function() return !onGround && isStunned());
		spr.anim.registerStateAnim("heroStun",10, function() return cd.has("reloading"));
		spr.anim.registerStateAnim("heroCover",5, function() return cover!=null);
		spr.anim.registerStateAnim("heroRun",1, function() return onGround && MLib.fabs(dx)>=0.1);
		spr.anim.registerStateAnim("heroIdle",0);

		icon = Assets.gameElements.h_get("iconMove");
		game.scroller.add(icon, Const.DP_UI);
		icon.setCenterRatio(0.5,0.5);
		icon.blendMode = Add;

		isAffectBySlowMo = false;
		setAmmo(4);
		initLife(2);
		//initLife(Const.INFINITE);



		// Blind shot
		var s = createSkill("blindShot");
		s.setTimers(0.25,0,0.1);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("heroBlind");
		}
		s.onExecute = function(e) {
			if( !useAmmo() ) {
				spr.anim.play("heroBlindShoot");
				return;
			}

			if( e.hit(1,this) ) {
				var r = e.getDiminishingReturnFactor("blindShot",1,3);
				e.dx*=0.3;
				e.dx+=dirTo(e)*rnd(0.03,0.05)*r;
				e.stunS(0.7*r);
				fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
			}
			fx.shoot(shootX, shootY, e.centerX, e.centerY, 0x2780D8);
			fx.flashBangS(0x477ADA,0.1,0.1);

			if( cover==null )
				dx += 0.03*-dir;
			spr.anim.play("heroBlindShoot");
		}

		// Head shot
		var s = createSkill("headShot");
		s.setTimers(0.8,0,0.1);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("heroAim");
		}
		s.onExecute = function(e) {
			if( !useAmmo() ) {
				spr.anim.play("heroAimShoot");
				return;
			}

			fx.flashBangS(0x477ADA,0.1,0.1);

			if( e.hit(999,this,true) )
				fx.headShot(shootX, shootY, e.headX, e.headY, dirTo(e));
			fx.shoot(shootX, shootY, e.headX, e.headY, 0x2780D8);

			if( cover==null )
				dx += 0.03*-dir;
			spr.anim.play("heroAimShoot");
		}
	}

	public function setAmmo(v) {
		ammo = maxAmmo = v;
		game.updateHud();
	}

	function useAmmo() {
		if( ammo<=0 ) {
			fx.noAmmo(shootX, shootY, dir);
			lockControlsS(0.2);
			return false;
		}
		else {
			ammo--;
			game.updateHud();
			return true;
		}
	}

	override function onDamage(v:Int) {
		super.onDamage(v);
		game.updateHud();
		fx.flashBangS(0xFF0000,0.2,0.2);
		spr.anim.playOverlap("heroHit");
	}

	override function onDie() {
		super.onDie();
		new en.DeadBody(this,"hero");
	}

	override public function dispose() {
		super.dispose();
		icon.remove();
	}

	override function get_shootY():Float {
		return switch( curAnimId ) {
			case "heroBlind" : footY - 16;
			case "heroAim" : footY - 21;
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

		return super.controlsLocked() || moveTarget!=null || !onGround;
	}

	override public function onClick(x:Float, y:Float, bt) {
		super.onClick(x, y, bt);

		if( controlsLocked() )
			return;

		executeAction( getActionAt(x,y) );

		//switch(bt) {
			//case 0 :
				//target = new FPoint(x,footY);
				//leaveCover();
//
			//case 1 :
				//var dh = new DecisionHelper(en.Mob.ALL);
				//dh.remove( function(e) return e.distPxFree(x,y)>=30 );
				//dh.score( function(e) return -e.distPxFree(x,y) );
				//var e = dh.getBest();
				//if( e!=null ) {
					//if( e.head.contains(x,y) && getSkill("headShot").isReady() )
						//getSkill("headShot").prepareOn(e);
					//else if( getSkill("blindShot").isReady() )
						//getSkill("blindShot").prepareOn(e);
				//}
		//}
	}

	function getActionAt(x:Float, y:Float) : Action {
		var a = None;

		// Movement
		if( MLib.fabs(y-footY)<=1.5*Const.GRID ) {
			var ok = true;
			for(e in Entity.ALL)
				if( e.isBlockingHeroMoves() && MLib.fabs(x-e.centerX)<=Const.GRID ) {
					ok = false;
					break;
				}
			if( ok )
				a = Move(x,footY);
		}

		// Wait
		if( ammo>=maxAmmo && MLib.fabs(centerX-x)<=Const.GRID*0.3 && MLib.fabs(centerY-y)<=Const.GRID*0.7 )
			a = Wait(0.3);

		// Take cover
		for(e in en.Cover.ALL) {
			if( e.left.contains(x,y) && e.canHostSomeone(-1) )
				a = TakeCover(e, -1);

			if( e.right.contains(x,y) && e.canHostSomeone(1) )
				a = TakeCover(e, 1);
		}

		// Shoot mob
		var best : en.Mob = null;
		for(e in en.Mob.ALL) {
			if( ( e.head.contains(x,y) || e.torso.contains(x,y) || e.legs.contains(x,y) ) && ( best==null || e.distPxFree(x,y)<=best.distPxFree(x,y) ) )
			//if( e.distPxFree(x,y)<=30 && ( best==null || e.distPxFree(x,y)<=best.distPxFree(x,y) ) )
				best = e;
		}
		if( best!=null )
			if( best.head.contains(x,y) )
				a = HeadShot(best);
			else
				a = BlindShot(best);

		// Relaod
		if( ammo<maxAmmo && MLib.fabs(centerX-x)<=Const.GRID*0.3 && MLib.fabs(centerY-y)<=Const.GRID*0.7 )
			a = Reload(0.8);

		return a;
	}

	public function executeAction(a:Action) {
		if( !game.isReplay )
			game.heroHistory.push( { t:game.itime, a:a } );
		switch( a ) {
			case None :

			case Wait(t) :
				spr.anim.stopWithStateAnims();
				lockControlsS(t);

			case Reload(t) :
				spr.anim.stopWithStateAnims();
				spr.anim.play("heroReload");
				fx.charger(hero.centerX-dir*6, hero.centerY-4, -dir);
				cd.setS("reloading",t);
				lockControlsS(t);
				setAmmo(maxAmmo);

			case Move(x,y) :
				spr.anim.stopWithStateAnims();
				moveTarget = new FPoint(x,y);
				afterMoveAction = None;
				leaveCover();

			case TakeCover(c,side) :
				spr.anim.stopWithStateAnims();
				if( c.canHostSomeone(side) )
					if( distPxFree(c.centerX+side*10,c.centerY)>=20 ) {
						moveTarget = new FPoint(c.centerX+side*10, footY);
						afterMoveAction = a;
						leaveCover();
					}
					else {
						startCover(c,side);
					}

			case BlindShot(e) :
				//if( cover!=null && dirTo(cover)!=dirTo(e) ) {
					//leaveCover();
					//dx = -0.05;
				//}
				getSkill("blindShot").prepareOn(e);

			case HeadShot(e) :
				//if( cover!=null && dirTo(cover)!=dirTo(e) ) {
					//leaveCover();
					//dx = -0.05;
				//}
				getSkill("headShot").prepareOn(e);
		}
	}

	override public function postUpdate() {
		super.postUpdate();
		//ammoBar.x = headX-2;
		//ammoBar.y = headY-4;
	}

	override public function update() {
		super.update();

		if( cover!=null && !hasSkillCharging() && !controlsLocked() )
			lookAt(cover);

		// HUD icon
		var m = game.getMouse();
		var a = getActionAt(m.x,m.y);
		icon.alpha = 0.7;
		icon.visible = true;
		icon.colorize(0xffffff);
		switch( a ) {
			case None : icon.visible = false;
			case Move(_) : icon.visible = false;
			case Wait(_) :
				icon.setPos(centerX, footY);
				icon.set("iconWait");
			case Reload(_) :
				icon.setPos(centerX, footY);
				icon.set("iconReload");
			//case Move(x,y) : icon.setPos(x,y); icon.set("iconMove"); icon.alpha = 0.3;
			case BlindShot(e) :
				icon.setPos(e.torso.centerX, e.torso.centerY+3);
				icon.set(e.isCoveredFrom(this) ? "iconShootCover" : "iconShoot");
				icon.colorize(e.isCoveredFrom(this) ? 0xFF0000 : 0xFFFFFF);
			case HeadShot(e) :
				icon.setPos(e.head.centerX, e.head.centerY);
				icon.set("iconShoot");
				icon.colorize(0xFFA600);
			case TakeCover(e,side) :
				icon.setPos(e.footX+side*14, e.footY-2);
				icon.set("iconCover"+(side==-1?"Left":"Right"));
		}

		if( moveTarget!=null && !movementLocked() )
			if( MLib.fabs(centerX-moveTarget.x)<=5 ) {
				// Arrived
				executeAction( afterMoveAction );
				moveTarget = null;
				afterMoveAction = None;
				dx*=0.5;
			}
			else {
				var s = 0.015;
				if( moveTarget.x>centerX ) {
					dir = 1;
					dx+=s;
				}
				if( moveTarget.x<centerX ) {
					dir = -1;
					dx-=s;
				}
			}
	}
}