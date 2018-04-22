import mt.MLib;

class Skill {
	public var id : String;
	var owner : Null<Entity>;

	public var chargeS : Float;
	public var cooldownS : Float;
	var curCdS : Float;
	var curChargeS : Float;

	public var onExecute : Void->Void;
	public var onStart : Void->Void;
	public var onProgress : Float->Void;
	public var onInterrupt: Void->Void;

	public function new(id, ?e:Entity) {
		this.id = id;
		owner = e;
		chargeS = 1;
		cooldownS = 1;
		curChargeS = -1;
		curCdS = -1;

		onExecute = function() {}
		onStart = function() {}
		onProgress = function(r) {}
		onInterrupt = function() {}
	}

	public function isReady() {
		return curChargeS<0 && curCdS<=0;
	}

	public function prepare() {
		if( curCdS>0 )
			return false;

		curChargeS = 0;
		onStart();
		return true;
	}

	public function setTimers(charge:Float, cd:Float) {
		chargeS = charge;
		cooldownS = cd;
	}

	public function interrupt(startCd:Bool) {
		if( curChargeS>=0 ) {
			onInterrupt();
			curChargeS = -1;
			if( startCd )
				curCdS = cooldownS;
		}
	}

	public function update(dt:Float) {
		if( curCdS>0 ) {
			curCdS-=dt*1/Const.FPS;
		}

		if( curChargeS>=0 ) {
			curChargeS+=dt*1/Const.FPS;
			onProgress( MLib.fclamp(curChargeS/chargeS, 0, 1) );
			if( curChargeS>=chargeS ) {
				curChargeS = -1;
				curCdS = cooldownS;
				onExecute();
			}
		}
	}
}