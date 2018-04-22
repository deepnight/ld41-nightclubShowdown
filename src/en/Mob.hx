package en;

class Mob extends Entity {

	public function new(x,y) {
		super(x,y);

		var g = new h2d.Graphics(spr);
		g.beginFill(0xFF0000,1);
		g.drawCircle(0,-radius,radius);

		initLife(4);

		var s = createSkill("test");
		s.setTimers(1,2);
		s.onStart = function() setLabel("preparing...");
		s.onInterrupt = function() setLabel("CANCEL!");
		s.onExecute = function() {
			dy = -0.9;
			setLabel("EXEC");
		}

	}

	override public function update() {
		super.update();

		if( getSkill("test").isReady() )
			getSkill("test").prepare();

		if( Main.ME.keyPressed(hxd.Key.SPACE) )
			getSkill("test").interrupt(true);
	}
}
