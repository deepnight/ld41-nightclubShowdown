package en;

class Cover extends Entity {
	public static var ALL : Array<Cover> = [];

	public var left : Area;
	public var right : Area;
	var iconLeft : HSprite;
	var iconRight : HSprite;

	public function new(x,y) {
		super(x,y);
		ALL.push(this);

		spr.set("crate");
		initLife(3);

		var r = 11;
		left = new Area(this, r, function() return centerX-r, function() return centerY);
		left.color = 0x009500;
		right = new Area(this, r, function() return centerX+r, function() return centerY);
		right.color = 0x17FF17;

		game.scroller.add(iconLeft = Assets.gameElements.h_get("iconShield"), Const.DP_UI);
		iconLeft.setCenterRatio(0.5,1);
		iconLeft.blendMode = Add;
		iconLeft.colorize(0x14BBEB);

		game.scroller.add(iconRight = Assets.gameElements.h_get("iconShield"), Const.DP_UI);
		iconRight.setCenterRatio(0.5,1);
		iconRight.blendMode = Add;
		iconRight.colorize(0x14BBEB);
	}


	override function onDamage(v) {
		super.onDamage(v);
		Assets.SBANK.cover0(1);
	}


	override function onDie() {
		Assets.SBANK.explode2(1);
		spr.set("crateBroken");
		cd.setS("decay", 15);
		fx.woodCover(centerX,centerY,lastHitDir);
	}

	override public function isBlockingHeroMoves() return isAlive();

	public function canHostSomeone(side:Int) {
		if( !isAlive() || !onGround )
			return false;

		for(e in Entity.ALL)
			if( e.cover==this && dirTo(e)==side )
				return false;
		return true;
	}

	public function coversAnyone(?side=0) {
		for(e in Entity.ALL)
			if( e.cover==this && ( side==0 || dirTo(e)==side ) )
				return true;
		return false;
	}

	override function onLand() {
		super.onLand();
		for(e in ALL)
			if( e!=this && distCase(e)<=2 && e.isAlive() )
				e.hit(999,this,true);

		Assets.SBANK.land0(0.5);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		iconLeft.remove();
		iconRight.remove();
	}

	override public function postUpdate() {
		super.postUpdate();
		if( !isAlive() && cd.has("decay") )
			spr.scaleY = cd.getRatio("decay");

		iconLeft.setPos(centerX-6, footY);
		iconLeft.visible = coversAnyone(-1);

		iconRight.setPos(centerX+6, footY);
		iconRight.visible = coversAnyone(1);
	}

	override public function update() {
		super.update();

		if( !isAlive() && !cd.has("decay") )
			destroy();
	}
}

