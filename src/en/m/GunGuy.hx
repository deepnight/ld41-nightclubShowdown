package en.m;

class GunGuy extends en.Mob {

	public function new(x,y) {
		super(x,y);

		initLife(4);

		var s = createSkill("shoot");
		s.setTimers(1,2);
		s.onStart = function() setLabel("preparing...");
		s.onProgress = function(t) setLabel("preparing "+Std.int(t*100)+"%");
		s.onInterrupt = function() setLabel("CANCEL!");
		s.onExecute = function() {
			var e = game.hero;
			dy = -0.1;
			e.hit(1);
			e.dx+=dirTo(e)*rnd(0.06,0.10);
			setLabel("bang!");
		}
	}


	override public function update() {
		super.update();

		if( getSkill("shoot").isReady() )
			getSkill("shoot").prepare();
	}
}
