class Skill {
	public var id : String;
	var owner : Null<Entity>;

	public var chargeS : Float;
	public var cooldownS : Float;
	public var lockAfterS : Float;
	var curCdS : Float;
	var curChargeS : Float;
	public var target(default,null) : Null<Entity>;

	public var onExecute : Null<Entity>->Void;
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

		onExecute = function(e:Entity) {}
		onStart = function() {}
		onProgress = function(r) {}
		onInterrupt = function() {}
	}

	public function isReady() {
		return !isCharging() && !isUnderCd();
	}

	public function isUnderCd() return curCdS>0;


	public function prepare(?cdMul=1.0) {
		if( !isReady() )
			return false;

		curChargeS = (1-cdMul)*chargeS;
		onStart();
		return true;
	}

	public function prepareOn(e:Entity, ?cdMul=1.0) {
		if( !isReady() )
			return false;

		target = e;
		return prepare(cdMul);
	}

	public function setTimers(charge:Float, cd:Float, lock:Float) {
		chargeS = charge;
		cooldownS = cd;
		lockAfterS = lock;
	}

	public function isCharging() {
		return curChargeS>=0;
	}

	public function interrupt(startCd:Bool) {
		if( isCharging() ) {
			curChargeS = -1;
			curCdS = -1;
			target = null;
			if( startCd )
				curCdS = cooldownS;
			onInterrupt();
		}
	}

	public function update(dt:Float) {
		if( isUnderCd() )
			curCdS-=dt*1/Const.FPS;

		if( isCharging() ) {
			curChargeS+=dt*1/Const.FPS;
			onProgress( M.fclamp(curChargeS/chargeS, 0, 1) );
			if( curChargeS>=chargeS ) {
				curChargeS = -1;
				curCdS = cooldownS;
				var t = target;
				target = null;
				if( lockAfterS>0 )
					owner.lockControlsS(lockAfterS);
				onExecute(t);
			}
		}
	}
}