import mt.heaps.slib.*;
import mt.deepnight.Sfx;

class Assets {
	//public static var SBANK = Sfx.importDirectory("sfx");
	public static var tiles : h2d.Tile;
	public static var font : h2d.Font;
	public static var music : Sfx;

	public static function init() {
		Sfx.setGroupVolume(0, 1);
		Sfx.setGroupVolume(1, 0.25);
		#if debug
		Sfx.toggleMuteGroup(1);
		#end

		font = hxd.Res.minecraftiaOutline.toFont();
		//tiles = mt.heaps.slib.assets.Atlas.load("tiles.atlas");
	}
}