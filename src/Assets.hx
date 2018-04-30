import mt.heaps.slib.*;
import mt.deepnight.Sfx;

class Assets {
	public static var SBANK = Sfx.importDirectory("sfx");
	public static var gameElements : SpriteLib;
	public static var font : h2d.Font;
	public static var musicIn : Sfx;
	public static var musicOut : Sfx;

	public static function init() {
		Sfx.setGroupVolume(0, 1);
		Sfx.setGroupVolume(1, 0.7);
		#if debug
		Sfx.toggleMuteGroup(1);
		#end

		musicIn = new mt.deepnight.Sfx( hxd.Res.music.musicIn );
		musicOut = new mt.deepnight.Sfx( hxd.Res.music.musicOut );

		gameElements = mt.heaps.slib.assets.Atlas.load("gameElements.atlas");
		gameElements.defineAnim("heroAimShoot","0(10), 1(10)");
		gameElements.defineAnim("heroGrabBlindShoot","0(4), 1(10)");
		gameElements.defineAnim("heroBlindShoot","0(4), 1(10)");
		gameElements.defineAnim("heroHit","0(8)");
		gameElements.defineAnim("heroKick","0(20), 1(5)");
		gameElements.defineAnim("heroDeathFly","0(30), 1(9999)");
		gameElements.defineAnim("heroRun","0(6),1(4), 2(4), 3(6), 4(4), 5(4)");
		gameElements.defineAnim("heroReload","0(15),1(15), 2(8), 3(6), 4(4), 5(6)");

		gameElements.defineAnim("aAimShoot","0(10), 1(10)");
		gameElements.defineAnim("aBlindShoot","0(4), 1(10)");
		gameElements.defineAnim("aHit","0(8)");
		gameElements.defineAnim("aDeathFly","0(30), 1(9999)");
		gameElements.defineAnim("aGrab","0(15), 1(10)");
		gameElements.defineAnim("aRun","0(6),1(4), 2(4), 3(6), 4(4), 5(4)");

		gameElements.defineAnim("bAimShoot","0(10), 1(10)");
		gameElements.defineAnim("bBlindShoot","0(4), 1(10)");
		gameElements.defineAnim("bHit","0(8)");
		gameElements.defineAnim("bDeathFly","0(30), 1(9999)");
		gameElements.defineAnim("bRun","0(6),1(4), 2(4), 3(6), 4(4), 5(4)");

		gameElements.defineAnim("cAimShoot","0(10), 1(10)");
		gameElements.defineAnim("cBlindShoot","0(4), 1(10)");
		gameElements.defineAnim("cHit","0(8)");
		gameElements.defineAnim("cDeathFly","0(30), 1(9999)");
		gameElements.defineAnim("cRun","0(6),1(4), 2(4), 3(6), 4(4), 5(4)");

		gameElements.defineAnim("dancingA","0-1(10)");
		gameElements.defineAnim("dancingB","0-1(10)");
		gameElements.defineAnim("dancingC","0-1(10)");

		font = hxd.Res.minecraftiaOutline.toFont();
		//tiles = mt.heaps.slib.assets.Atlas.load("tiles.atlas");
	}

	public static function playMusic(isIn:Bool) {
		musicIn.stop();
		musicOut.stop();
		if( isIn )
			musicIn.playOnGroup(1,true);
		else
			musicOut.playOnGroup(1,true);
	}
}