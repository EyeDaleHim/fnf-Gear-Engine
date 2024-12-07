package assets.formats;

typedef WeekFormat = {
    var name:String;

    var ?display:String;
    var ?order:Array<String>; // order of songs, if a song isn't in SongList, it won't be added
    
    var ?background:String;
};