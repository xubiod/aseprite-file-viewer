class_name AsepriteTag extends RefCounted

enum LoopDir {
	FORWARD,
	REVERSE,
	PINGPONG,
	PINGPONGREVERSE,
}

var From			: int
var To				: int
var LoopDirection	: LoopDir
var RepeatCount		: int

var Name : String
