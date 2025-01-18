package objects;

import assets.formats.StageFormat;

class Stage extends FlxGroup
{
    public static final fallbackStage:StageFormat = {
        objects: [
            {name: 'stagebg', graphic: 'stage/'}
        ]
    };

    public function new(?format:StageFormat)
    {
        super();

        format ??= fallbackStage;


    }
}