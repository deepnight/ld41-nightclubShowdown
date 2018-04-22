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
		if( !movementLocked() && !controlsLocked() && !hasSkillCharging() && onGround && distCase(hero)<=2.5 && hero.moveTarget==null && !cd.hasSetS("dodgeHero",0.3) ) {
			dx = -dirTo(hero)*0.1;
			dy = -0.15;
		}
	}
}
