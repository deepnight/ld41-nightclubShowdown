package en;

import hxd.Key;
import mt.MLib;
import mt.deepnight.*;
import mt.heaps.slib.*;

enum Action {
	None;
	BlindShot(e:en.Mob);
	HeadShot(e:en.Mob);
	Move(x:Float, y:Float);
	TurnBack;
	TakeCover(e:Cover, side:Int);
	Wait(sec:Float);
	GrabMob(e:en.Mob, side:Int);
	KickGrab;
	Reload;
}

class Hero extends Entity {
	public var moveTarget : FPoint;
	public var afterMoveAction : Action;
	var icon : HSprite;

	public var ammo : Int;
	public var maxAmmo : Int;
	public var grabbedMob : Null<en.Mob>;

	public function new(x,y) {
		super(x,y);

		afterMoveAction = None;

		game.scroller.add(spr, Const.DP_HERO);
		spr.anim.registerStateAnim("heroPush",21, function() return !onGround && isStunned());
		spr.anim.registerStateAnim("heroStun",20, function() return cd.has("reloading"));
		spr.anim.registerStateAnim("heroCover",10, function() return cover!=null);
		spr.anim.registerStateAnim("heroRoll",9, function() return onGround && moveTarget!=null && !movementLocked() && cd.has("rolling") );
		spr.anim.registerStateAnim("heroBrake",6, function() return onGround && moveTarget!=null && !movementLocked() && cd.has("rollBraking") );
		spr.anim.registerStateAnim("heroRun",5, function() return onGround && moveTarget!=null && !movementLocked() );
		spr.anim.registerStateAnim("heroBrake",2, function() return cd.has("braking") && grabbedMob==null );
		spr.anim.registerStateAnim("heroIdleGrab",1, function() return grabbedMob!=null );
		spr.anim.registerStateAnim("heroIdle",0);

		icon = Assets.gameElements.h_get("iconMove");
		game.scroller.add(icon, Const.DP_UI);
		icon.setCenterRatio(0.5,0.5);
		icon.blendMode = Add;

		isAffectBySlowMo = false;
		setAmmo(6);
		initLife(3);
		//initLife(Const.INFINITE);



		// Blind shot
		var s = createSkill("blindShot");
		s.setTimers(0.1,0,0.22);
		s.onStart = function() {
			lookAt(s.target);
			if( grabbedMob==null )
				spr.anim.playAndLoop("heroBlind");
			else
				spr.anim.playAndLoop("heroGrabBlind");
		}
		s.onExecute = function(e) {
			if( !useAmmo() ) {
				Assets.SBANK.empty(1);
				if( grabbedMob==null )
					spr.anim.play("heroBlindShoot");
				else
					spr.anim.play("heroGrabBlindShoot");
				return;
			}

			if( e.hit(1,this) ) {
				var r = e.getDiminishingReturnFactor("blindShot",1,1);
				e.dx*=0.3;
				e.dx+=dirTo(e)*rnd(0.03,0.05)*r;
				e.stunS(1.1*r);
				fx.bloodHit(shootX, shootY, e.centerX, e.centerY);
			}
			fx.shoot(shootX, shootY, e.centerX, e.centerY, 0x2780D8);
			Assets.SBANK.pew2(0.5);
			//Assets.SBANK.gun1(1);
			Assets.SBANK.blaster1(1);
			fx.bullet(shootX-dir*5,shootY,-dir);
			fx.flashBangS(0x477ADA,0.1,0.1);

			if( cover==null && grabbedMob==null )
				dx += 0.03*-dir;

			if( grabbedMob==null )
				spr.anim.play("heroBlindShoot");
			else
				spr.anim.play("heroGrabBlindShoot");
		}

		// Head shot
		var s = createSkill("headShot");
		s.setTimers(0.85,0,0.1);
		s.onStart = function() {
			lookAt(s.target);
			spr.anim.playAndLoop("heroAim");
		}
		s.onExecute = function(e) {
			if( !useAmmo() ) {
				Assets.SBANK.empty(1);
				spr.anim.play("heroAimShoot");
				return;
			}

			fx.flashBangS(0x477ADA,0.1,0.1);

			if( e.hit(2,this,true) )
				fx.headShot(shootX, shootY, e.headX, e.headY, dirTo(e));
			fx.shoot(shootX, shootY, e.headX, e.headY, 0x2780D8);
			fx.bullet(shootX-dir*5,shootY,dir);
			//Assets.SBANK.gun0(1);
			Assets.SBANK.heavy(1);
			Assets.SBANK.pew0(0.5);

			if( cover==null )
				if( grabbedMob==null )
					dx += 0.03*-dir;
				else
					dx += 0.01*-dir;
			spr.anim.play("heroAimShoot");
		}
	}

	override public function isCoveredFrom(source:Entity) {
		return super.isCoveredFrom(source) || grabbedMob!=null && dirTo(grabbedMob)==dirTo(source);
	}

	override public function hitCover(dmg:Int, source:Entity) {
		if( grabbedMob!=null )
			grabbedMob.hit(dmg, source);
		else
			super.hitCover(dmg, source);
	}

	public function setAmmo(v) {
		ammo = maxAmmo = v;
		game.updateHud();
	}

	function useAmmo() {
		if( ammo<=0 ) {
			say("I need to reload!", 0xFF0000);
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
		stopGrab();
		new en.DeadBody(this,"hero");
		game.announce("ESCAPE to restart",0xFF0000,true);
	}

	override public function dispose() {
		super.dispose();
		icon.remove();
	}

	override function get_shootY():Float {
		return switch( curAnimId ) {
			case "heroGrabBlind" : footY - 16;
			case "heroBlind" : footY - 16;
			case "heroAim" : footY - 21;
			default : super.get_shootY();
		}
	}

	//override function onTouchWall(wallDir:Int) {
		//dx = -wallDir*MLib.fabs(dx);
	//}

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
		if( MLib.fabs(y-footY)<=1.5*Const.GRID && grabbedMob==null ) {
			var ok = true;
			for(e in Entity.ALL)
				if( e.isBlockingHeroMoves() && MLib.fabs(x-e.centerX)<=Const.GRID*0.8 ) {
					ok = false;
					break;
				}

			if( ok ) {
				x = MLib.fclamp(x, 5, level.wid*Const.GRID-5);
				if( game.waveId<=1 && level.waveMobCount>0 && x>=(level.wid-3)*Const.GRID )
					x = (game.level.wid-3)*Const.GRID;
				a = Move(x,footY);
			}
		}

		// Throw grabbed mob
		if( grabbedMob!=null && MLib.fabs(centerX-dir*10-x)<=9 && MLib.fabs(centerY-y)<=20 )
			a = KickGrab;

		// Turn back
		if( a==null && grabbedMob!=null && MLib.fabs(x-centerX)>=Const.GRID && ( x>centerX && dir==-1 || x<centerX && dir==1 ) )
			a = TurnBack;

		// Wait
		if( grabbedMob==null && game.isSlowMo() && ammo>=maxAmmo && MLib.fabs(centerX-x)<=Const.GRID*0.3 && MLib.fabs(centerY-y)<=Const.GRID*0.7 )
			a = Wait(0.6);

		// Take cover
		for(e in en.Cover.ALL) {
			if( e.left.contains(x,y) && e.canHostSomeone(-1) )
				a = TakeCover(e, -1);

			if( e.right.contains(x,y) && e.canHostSomeone(1) )
				a = TakeCover(e, 1);
		}

		// Grab mob
		if( grabbedMob==null ) {
			var best : en.Mob = null;
			for(e in en.Mob.ALL)
				if( e.canBeShot() && e.canBeGrabbed() && grabbedMob!=e && MLib.fabs(x-e.centerX)<=Const.GRID && MLib.fabs(y-e.centerY)<=Const.GRID && ( best==null || e.distPxFree(x,y)<=best.distPxFree(x,y) ) )
					best = e;
			if( best!=null )
				a = GrabMob(best, x<best.centerX ? -1 : 1);
		}

		// Shoot mob
		if( a!=KickGrab ) {
			var best : en.Mob = null;
			for(e in en.Mob.ALL) {
				if( e.canBeShot() && ( e.head.contains(x,y) || e.torso.contains(x,y) || e.legs.contains(x,y) ) && ( best==null || e.distPxFree(x,y)<=best.distPxFree(x,y) ) )
					best = e;
			}
			if( best!=null ) {
				if( best.head.contains(x,y) )
					a = HeadShot(best);
				else
					a = BlindShot(best);
			}
		}

		// Relaod
		if( grabbedMob==null && ammo<maxAmmo && MLib.fabs(centerX-x)<=Const.GRID*0.3 && MLib.fabs(centerY-y)<=Const.GRID*0.7 )
			a = Reload;

		return a;
	}

	public function executeAction(a:Action) {
		if( !game.isReplay )
			game.heroHistory.push( { t:game.itime, a:a } );
		switch( a ) {
			case None :

			case KickGrab :
				if( grabbedMob!=null ) {
					Assets.SBANK.hit1(1);
					grabbedMob.hit(1, this, true);
					grabbedMob.xr+=0.5*dirTo(grabbedMob);
					grabbedMob.violentBump(dir*0.5, -0.1, 1.5);
					stopGrab();
					spr.anim.play("heroKick");
				}

			case TurnBack :
				dir*=-1;

			case Wait(t) :
				spr.anim.stopWithStateAnims();
				lockControlsS(t);

			case Reload :
				spr.anim.stopWithStateAnims();
				spr.anim.play("heroReload");
				Assets.SBANK.reload0(1);
				game.delayer.addS( Assets.SBANK.reload1.bind(1), 0.25 );
				game.delayer.addS( Assets.SBANK.reload1.bind(1), 0.7 );
				fx.charger(hero.centerX-dir*6, hero.centerY-4, -dir);
				cd.setS("reloading",0.8);
				lockControlsS(0.8);
				setAmmo(maxAmmo);

			case Move(x,y) :
				spr.anim.stopWithStateAnims();
				moveTarget = new FPoint(x,y);
				//cd.setS("rolling",0.5);
				cd.setS("rollBraking",cd.getS("rolling")+0.1);
				afterMoveAction = None;
				leaveCover();
				stopGrab();

			case GrabMob(e,side) :
				if( distPxFree(e.footX+side*10, e.footY) >=20 ) {
					stopGrab();
					leaveCover();
					moveTarget = new FPoint(e.footX+side*10,e.footY);
					afterMoveAction = GrabMob(e,side);
				}
				else {
					Assets.SBANK.hit0(1);
					dir = -side;
					cx = e.cx;
					xr = e.xr+side*0.9;
					startGrab(e);
				}

			case TakeCover(c,side) :
				spr.anim.stopWithStateAnims();
				if( c.canHostSomeone(side) ) {
					stopGrab();
					if( distPxFree(c.centerX+side*10,c.centerY)>=20 ) {
						moveTarget = new FPoint(c.centerX+side*10, footY);
						afterMoveAction = a;
						leaveCover();
					}
					else {
						startCover(c,side);
					}
				}

			case BlindShot(e) :
				getSkill("blindShot").prepareOn(e, e.isGrabbed()?0.5:1);

			case HeadShot(e) :
				getSkill("headShot").prepareOn(e, e.isGrabbed()?0.5:1);
		}
	}

	override public function postUpdate() {
		super.postUpdate();
		if( spr.groupName=="heroRoll" ) {
			spr.setCenterRatio(0.5,0.5);
			spr.rotation+=0.6*dt*dir;
			spr.y -= 7;
		}
		else {
			spr.rotation = 0;
			spr.setCenterRatio(0.5,1);
		}
		//ammoBar.x = headX-2;
		//ammoBar.y = headY-4;
	}

	public function startGrab(e:en.Mob) {
		if( !e.isAlive() )
			return;
		grabbedMob = e;
		grabbedMob.hasGravity = false;
		grabbedMob.interruptSkills(false);
		game.scroller.add(grabbedMob.spr, Const.DP_HERO);
	}

	public function stopGrab() {
		if( grabbedMob==null )
			return;
		grabbedMob.hasGravity = true;
		if( grabbedMob.isAlive() )
			game.scroller.add(grabbedMob.spr, Const.DP_MOBS);
		grabbedMob = null;
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
			case TurnBack : icon.visible = false;

			case Wait(_) :
				icon.setPos(centerX, footY);
				icon.set("iconWait");

			case KickGrab :
				icon.setPos(centerX-dir*8, centerY);
				icon.colorize(0xFF9300);
				icon.set("iconKickGrab");

			case Reload :
				icon.setPos(centerX, footY);
				icon.set("iconReload");

			case BlindShot(e) :
				icon.setPos(e.torso.centerX, e.torso.centerY+3);
				icon.set(e.isCoveredFrom(this) ? "iconShootCover" : "iconShoot");
				icon.colorize(e.isCoveredFrom(this) ? 0xFF0000 : 0xFFFF00);

			case HeadShot(e) :
				icon.setPos(e.head.centerX, e.head.centerY);
				icon.set("iconShoot");
				icon.colorize(0xFF9300);

			case TakeCover(e,side) :
				icon.setPos(e.footX+side*14, e.footY-6);
				icon.set("iconCover"+(side==-1?"Left":"Right"));
				icon.colorize(0xA6EE11);

			case GrabMob(e,side) :
				icon.setPos(e.footX+side*14, e.footY-6);
				icon.colorize(0xA6EE11);
				icon.set("iconCover"+(side==-1?"Left":"Right"));
		}


		if( !controlsLocked() && Main.ME.keyPressed(hxd.Key.R) && ammo<maxAmmo )
			executeAction(Reload);

		// Move
		if( moveTarget!=null && !movementLocked() )
			if( MLib.fabs(centerX-moveTarget.x)<=5 ) {
				// Arrived
				game.cm.signal("move");
				executeAction( afterMoveAction );
				moveTarget = null;
				afterMoveAction = None;
				dx*=0.3;
				if( MLib.fabs(dx)>=0.04 )
					cd.setS("braking",0.2);
			}
			else {
				var s = 0.011;
				if( moveTarget.x>centerX ) {
					dir = 1;
					dx+=s*dt;
				}
				if( moveTarget.x<centerX ) {
					dir = -1;
					dx-=s*dt;
				}
			}


		if( grabbedMob!=null ) {
			if( !grabbedMob.isAlive() ) {
				stopGrab();
			}
			else {
				grabbedMob.setPosPixel(footX+dir*6,footY-1);
				grabbedMob.dir = dir;
			}
		}
	}
}