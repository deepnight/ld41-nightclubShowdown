import mt.MLib;

class Console extends h2d.Console {
	public static var ME : Console;

	var flags : Map<String,Bool>;

	public function new() {
		super(Assets.font);
		h2d.Console.HIDE_LOG_TIMEOUT = 30;
		ME = this;
		Main.ME.root.add(this, Const.DP_UI);
		#if !flash
		mt.deepnight.Lib.redirectTracesToH2dConsole(this);
		#end

		flags = new Map();

		this.addCommand("fps", [], function(v:Int) set("fps",!has("fps")) );
		#if debug
		this.addCommand("set", [{ name:"k", t:AString }], function(k:String) {
			set(k,true);
			log("+ "+k, 0x80FF00);
		});
		this.addCommand("unset", [{ name:"k", t:AString, opt:true } ], function(?k:String) {
			if( k==null ) {
				log("Reset all.",0xFF0000);
				flags = new Map();
			}
			else {
				log("- "+k,0xFF8000);
				set(k,false);
			}
		});
		this.addAlias("+","set");
		this.addAlias("-","unset");

		this.addCommand("grid", [], function() {
			var level = Game.ME.level;
			var g = level.debug;
			g.endFill();
			g.lineStyle(1,0xFFFF00,0.4);
			for(cx in 0...level.wid) {
				g.moveTo(cx*Const.GRID,0);
				g.lineTo(cx*Const.GRID,level.hei*Const.GRID);
			}
			for(cy in 0...level.hei) {
				g.moveTo(0, cy*Const.GRID);
				g.lineTo(level.wid*Const.GRID, cy*Const.GRID);
			}
		});
		#end
	}

	public function set(k:String,v) return flags.set(k,v);
	public function has(k:String) return flags.get(k)==true;
}