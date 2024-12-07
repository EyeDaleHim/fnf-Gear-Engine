package assets;

#if sys
typedef Assets = assets.platform.SystemAssets;
#elseif html5
typedef Assets = assets.platform.HTML5Assets;
#end