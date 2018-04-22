package en;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	public function new(x,y) {
		super(x,y);

		ALL.push(this);

		game.scroller.add(spr, Const.DP_MOBS);

		//var g = new h2d.Graphics(spr);
		//g.beginFill(0xFF0000,1);
		//g.drawCircle(0,-radius,radius);

		initLife(4);
	}

	override public function isBlockingHeroMoves() return true;

	override function onDie() {
		super.onDie();
		new en.DeadBody(this);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function update() {
		super.update();

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
