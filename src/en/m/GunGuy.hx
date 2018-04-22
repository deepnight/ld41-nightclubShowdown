package en.m;

class GunGuy extends en.Mob {

	public function new(x,y) {
		super(x,y);

		initLife(4);

		var s = createSkill("shoot");
		s.setTimers(1, 0, 0.5);
		s.onStart = function() setLabel("preparing...");
		s.onProgress = function(t) setLabel("preparing "+Std.int(t*100)+"%");
		s.onInterrupt = function() setLabel("CANCEL!");
		s.onExecute = function(e) {
			dy = -0.1;
			e.hit(1);
			e.dx*=0.3;
			e.dx+=dirTo(e)*rnd(0.06,0.10);
			e.lockMovementsS(0.3);
			e.lockControlsS(0.3);
			setLabel("bang!");
		}
	}

	override function onDamage(v:Int) {
		super.onDamage(v);
		interruptSkills(true);
	}

	override public function update() {
		super.update();

		if( !controlsLocked() && onGround && getSkill("shoot").isReady() )
			getSkill("shoot").prepareOn(game.hero);
	}
}
