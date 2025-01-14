package assets.formats;

typedef ChartFormat = {
    var ?characters:Array<String>; // characters to load, order is dependent on the stage

    var ?bpm:Float;
    var ?speed:Float;

    var ?stage:String;

    var ?strums:Array<StrumFormat>;
    var ?playables:Array<Bool>; // if each strum should be played, easily overridable mid-game

    // [0] = strum time
    // [1] = strum index, defined by `strums`
    // [2] = lane of the note, will wrap around if exceeds limits
    // [3] = sustain length
    // [4] = character to play animation from, defined by `characters`
    // [5] = note type, defined by `noteTypes`
    // [6] = animation to play
    var ?notes:Array<Dynamic>;
    var ?noteTypes:Array<String>;

    var ?tracks:Array<String>;

    var ?ratingFormat:GameplayRatingFormat;

    var ?version:String; // version used to identify gear engine charts
};

typedef StrumFormat = {
    var ?character:String;
    var ?attachedTrack:String;
    var ?lanes:Int; // no effect yet, will remain as four lanes
};