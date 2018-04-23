package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	var tx = -1;
	var onArrive : Null<Void->Void>;

	public function new(x,y) {
		super(x,y);

		ALL.push(this);

		game.scroller.add(spr, Const.DP_MOBS);

		//var g = new h2d.Graphics(spr);
		//g.beginFill(0xFF0000,1);
		//g.drawCircle(0,-radius,radius);

		initLife(4);
	}

	public function enterArena(t) {
		spr.alpha = 0;
		cd.setS("entering",0.5);
		cd.onComplete("entering", function() {
			lookAt(hero);
		});
		lockControlsS(t+cd.getS("entering"));
	}

	override function onDie() {
		super.onDie();
		level.waveMobCount--;
	}

	public function canBeShot() return !cd.has("entering");

	override public function isBlockingHeroMoves() return true;

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function postUpdate() {
		super.postUpdate();
		if( cd.has("entering") )
			spr.alpha = 1-cd.getRatio("entering");
	}

	function goto(x:Int, ?onDone:Void->Void) {
		tx = x;
		onArrive = onDone;
	}

	override public function update() {
		super.update();

		if( tx!=-1 && !cd.has("entering") && !movementLocked() && !controlsLocked() && !hasSkillCharging() ) {
			if( cover!=null )
				leaveCover();

			var s = 0.015;
			if( tx>cx ) {
				dir = 1;
				dx+=s*dt;
			}
			if( tx<cx ) {
				dir = -1;
				dx-=s*dt;
			}

			if( tx==cx ) {
				tx = -1;
				if( onArrive!=null ) {
					var cb = onArrive;
					onArrive = null;
					cb();
				}
			}
		}

		if( cd.has("entering") )
			dx = dir*0.05;

		// Find cover
		if( cover==null && tx==-1 && !controlsLocked() && !hasSkillCharging() )
			for(e in en.Cover.ALL)
				if( distCase(e)<=3 && e.canHostSomeone(-dirTo(hero)) && !e.coversAnyone() ) {
					//fx.markerEntity(e, true);
					goto(e.cx-dirTo(hero), function() {
						startCover(e,-dirTo(hero));
						trace("startCover");
					});
				}

		// Dodge hero
		if( onGround && !movementLocked() && !controlsLocked() && ( !hasSkillCharging() || canInterruptSkill() ) && distCase(hero)<=1.75 && hero.moveTarget==null && !cd.has("dodgeHero") ) {
			if( cover==null || dirTo(cover)!=dirTo(hero) ) {
				leaveCover();
				for(s in skills)
					s.interrupt(false);
				dx = -dirTo(hero)*0.12;
				dy = -0.15;
				cd.setS("dodgeHero",0.6);
			}
		}
	}
}
