class_name AsepriteCell extends RefCounted

var LayerIndex	: int
var Position	: Vector2i
var Opacity		: int
var ZIndex		: int

var Width	: int
var Height	: int

var UncompressedData : PackedByteArray

var IsLinked	: bool = false
var LinkedTo	: int

var CellImage	: Image
