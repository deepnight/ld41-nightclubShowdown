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
        this.engine.backgroundColor = 0xFF << 24 | Main.BG;

        this.onResize();

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

        // Multiplies this.speed to ensures game speed is consistent
        final tmod = hxd.Timer.tmod;

        #if debug
        if (!Console.ME.isActive()) {
            // (-) Toggle normal, slow, and very slow speeds
            if (Key.isPressed(Key.NUMPAD_SUB) || Key.isPressed(Key.QWERTY_MINUS))
                this.speed = if (this.speed == 1) 0.35 else if (this.speed == 0.35) 0.1 else 1;

            // (P) Toggle pause
            if (Key.isPressed(Key.P))
                this.speed = if (this.speed == 0) 1 else 0;

            // (+) Hold to fast forward
            if (Key.isDown(Key.NUMPAD_ADD) || Key.isDown(Key.QWERTY_EQUALS))
                this.speed = 3;
            else if (this.speed > 1)
                this.speed = 1;
        }
        #end

        if (this.speed > 0)
            dn.Process.updateAll(tmod * this.speed);
    }
}
