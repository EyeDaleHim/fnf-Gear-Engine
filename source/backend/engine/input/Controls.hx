package backend.engine.input;

class Controls 
{
    public static function initialize():Void
    {
        
    }

    public static function resetCallbacks():Void
    {
        for (control in Control.list)
        {
            control.callbacks.removeAll();
        }
    }
}