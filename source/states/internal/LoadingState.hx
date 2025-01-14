package states.internal;

class LoadingState extends MainState
{
    private var _task:()->Void;

    public function new(task:()->Void)
    {
        _task = task;

        super();
    }
}