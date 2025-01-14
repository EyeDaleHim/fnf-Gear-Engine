package assets.formats;

// order matters!
typedef GameplayRatingFormat = {
    var list:Array<Rating>;
    var maxTiming:Float;
}

typedef Rating = {
    // timings, if they're not used, could be identified as a miss because it can't be achieved by hitting
    var ?earlyTiming:Float;
    var ?lateTiming:Float;

    var ?timing:Float; // if none of the above are not filled in, this is used instead

    var ?score:Int;
    
    var name:String;
    var accuracyFactor:Float;

    var showRating:Bool;
    var showCombo:Bool;
};