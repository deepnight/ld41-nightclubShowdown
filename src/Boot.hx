import hxd.Key;

/**
    The main application singleton class.
**/
class Boot extends hxd.App {
    public static var ME: Boot;

    public var speed = 1.;

    static function main() {
        new Boot();
    }

    /**
        Called when the engine is ready.
    **/
    override function init() {
        ME = this;

        // Set alpha channel to 0xFF and color to BG
        engine.backgroundColor = 0xFF << 24 | Main.BG;

        onResize();

        #if hl // Probably supposed to make graphics smoother
        @:privateAccess hxd.Window.getInstance().window.vsync = true;
        #end

        new Main();
    }

    override function onResize() {
        super.onResize();
        dn.Process.resizeAll();
    }

    override function update(deltaTime: Float) {
        super.update(deltaTime);
        var tmod = hxd.Timer.tmod;

        #if debug
        if (!Console.ME.isActive()) {
            if (Key.isPressed(Key.NUMPAD_SUB))
                speed = speed == 1 ? 0.35 : speed == 0.35 ? 0.1 : 1;

            if (Key.isPressed(Key.P))
                speed = speed == 0 ? 1 : 0;

            if (Key.isDown(Key.NUMPAD_ADD))
                speed = 3;
            else if (speed > 1)
                speed = 1;
        }
        #end

        if (speed > 0)
            dn.Process.updateAll(tmod * speed);
    }
}
