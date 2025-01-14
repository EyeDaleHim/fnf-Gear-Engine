package assets.formats;

import assets.formats.GameplayRatingFormat;

typedef SongFormat = {
    // names
    var ?name:String; // name of the song, for files, if blank, it just refers to the parent folder's name instead
    var ?display:String; // song to be displayed in story and freeplay, uses name if invalid

    // freeplay
    var ?freeplayDisplay:String; // the icon to be used
    var ?background:String; // if provided, will override its week parent's background color

    // gameplay format, likely to be overwritten by the chart itself if exists
    var ?characters:Array<String>; // characters to load, order is dependent on the stage
    var ?bpm:Float;
    var ?stage:String;

    var ?ratingFormat:GameplayRatingFormat;

    // additional properties
    var ?difficulties:Array<String>; // difficulties to load, uses ["easy", "normal", "hard"] as default, game checks "chart/DIFF.json"
    var ?tracks:Array<String>; // fallback tracks to load if the chart doesn't have one, also the songs to play on freeplay
};