extends Node

const UPSCALE_BY			: int = 48
const STARTING_SEPARATION	: float = 0.1

var palette : AsepritePalette

var all_layers	: Array[AsepriteLayer] = []
var all_tags	: Array[AsepriteTag] = []
var all_frames	: Array[AsepriteFrame] = []
var view_frame	: int = 0

var image_size	: Vector2i = Vector2i(0,0)

var seperation_distance : float = 20
var layer_separation	: float = STARTING_SEPARATION
var spreadout			: bool = false
var truespreadout		: bool = false

func import(fname: String) -> Vector2i:
	all_layers.clear()
	all_tags.clear()
	all_frames.clear()

	palette = AsepritePalette.new()

	view_frame = 0

	var raw = FileAccess.open(fname, FileAccess.READ)
	raw.big_endian = false
	var pixel_size = 4

	# Header
	var _header_fsize = raw.get_32()

	var header_magic = raw.get_16()
	if header_magic != 0xA5E0:
		push_error("wrong header magic number (byte pos: %s)" % raw.get_position())

	var _header_frames = raw.get_16()
	var header_width = raw.get_16()
	var header_height = raw.get_16()
	var header_colour_depth = raw.get_16()
	var _header_flags = raw.get_32()
	var _header_speed = raw.get_16()
	var _header_zero = raw.get_32() + raw.get_32()
	var _header_palette_entry = raw.get_8()
	var _header_ignore = raw.get_buffer(3)
	var _header_colour_count = raw.get_16()
	var _header_pixel_width = raw.get_8()
	var _header_pixel_height = raw.get_8()
	var _header_grid_xpos = raw.get_16()
	var _header_grid_ypos = raw.get_16()
	var _header_grid_width = raw.get_16()
	var _header_grid_height = raw.get_16()

	if header_colour_depth==16: # grayscale
		pixel_size = 2
	elif header_colour_depth==8: # indexed
		pixel_size = 1

		push_error("unsupported rn nocap")

	_header_ignore = raw.get_buffer(84)

	var current_frame = 0

	while !raw.eof_reached():
		all_frames.append(AsepriteFrame.new())#[current_frame] = []

		# Frames
		var _frames_length = raw.get_32()
		var frames_magic = raw.get_16()
		if frames_magic != 0xF1FA:
			push_error("wrong frames magic number (byte pos: %s)" % raw.get_position())

		var frames_chunk_count = raw.get_16()
		all_frames[len(all_frames)-1].DurationMS = raw.get_16()
		raw.get_buffer(2)
		var frames_new_chunk_count = raw.get_32()

		var usable_count = frames_chunk_count if frames_new_chunk_count == 0 else frames_new_chunk_count
		if frames_chunk_count == 0xFFFF:
			usable_count = frames_new_chunk_count

		for chunk in usable_count:
			var chunk_start = raw.get_position()

			var chunk_size = raw.get_32()
			var chunk_type = raw.get_16()
			match chunk_type:
				0x2004:
					var item : AsepriteLayer = AsepriteLayer.new()
					item.Flags = raw.get_16()
					item.Type = raw.get_16() as AsepriteLayer.LayerType
					item.ChildLevel = raw.get_16()
					item.DefaultWidth = raw.get_16()
					item.DefaultHeight = raw.get_16()
					item.Blending = raw.get_16() as AsepriteLayer.BlendMode
					item.Opacity = raw.get_8()
					raw.get_buffer(3)
					var str_len = raw.get_16()
					item.Name = raw.get_buffer(str_len).get_string_from_utf8()
					if item.Type == 2:
						item.TilesetIndex = raw.get_32()
					all_layers.append(item)

				0x2005:
					var item = AsepriteCell.new()
					item.LayerIndex = raw.get_16()
					item.Position.x = raw.get_16()
					item.Position.x *= -1 if item.Position.x & 0x8000 > 0 else 1
					item.Position.y = raw.get_16()
					item.Position.y *= -1 if item.Position.y & 0x8000 > 0 else 1
					item.Opacity = raw.get_8()
					var cell_type = raw.get_16()
					item.ZIndex = raw.get_16()
					item.ZIndex *= -1 if item.ZIndex & 0x8000 > 0 else 1
					raw.get_buffer(5)

					match cell_type:
						0: # uncompressed
							item.Width = raw.get_16()
							item.Height = raw.get_16()
							item.UncompressedData = raw.get_buffer(chunk_size-(raw.get_position()-chunk_start))
						1: # linked!
							item.IsLinked = true
							item.LinkedTo = raw.get_16()
						2: # compressed
							item.Width = raw.get_16()
							item.Height = raw.get_16()
							var raw_buff = raw.get_buffer(chunk_size-(raw.get_position()-chunk_start))
							item.UncompressedData = raw_buff.decompress(item.Width*item.Height*pixel_size,FileAccess.COMPRESSION_DEFLATE)
						_:
							# skip this shit
							raw.get_buffer(chunk_size-(raw.get_position()-chunk_start))
							continue

					if !item.IsLinked:
						var fmt = Image.FORMAT_RGBA8 if pixel_size == 4 else Image.FORMAT_LA8

						var working_img = Image.create(header_width, header_height, false, fmt)
						working_img.blit_rect( \
							Image.create_from_data(item.Width, item.Height,false,fmt,item.UncompressedData), \
							Rect2i(0,0,item.Width,item.Height), \
							Vector2i(item.Position) \
						)

						item.CellImage = working_img
					all_frames[current_frame].Cells[item.LayerIndex] = item

				0x2018:
					var tag_count = raw.get_16()
					raw.get_buffer(8)
					for i in tag_count:
						var item = AsepriteTag.new()
						item.From = raw.get_16()
						item.To = raw.get_16()
						item.LoopDirection = raw.get_8()
						item.RepeatCount = raw.get_16()

						raw.get_buffer(6)
						raw.get_buffer(3)
						raw.get_8()
						var str_len = raw.get_16()
						item.Name = raw.get_buffer(str_len).get_string_from_utf8()
						all_tags.append(item)

				0x2019:
					palette.PaletteSize = raw.get_32()
					palette.FirstChngIndex = raw.get_32()
					palette.LastChngIndex = raw.get_32()

					raw.get_buffer(8)

					for i in range(palette.FirstChngIndex, palette.LastChngIndex+1):
						var subitem = AsepritePaletteEntry.new()
						subitem.Flags = raw.get_16()
						subitem.Colour = Color(Color.BLACK, 1.0)
						subitem.Colour.r8 = raw.get_8()
						subitem.Colour.g8 = raw.get_8()
						subitem.Colour.b8 = raw.get_8()
						subitem.Colour.a8 = raw.get_8()
						if subitem.Flags & 1:
							var str_len = raw.get_16()
							subitem.Name = raw.get_buffer(str_len).get_string_from_utf8()
						palette.Entries[i] = subitem

				_:
					raw.get_buffer(chunk_size-(raw.get_position()-chunk_start))

		current_frame += 1

	raw.close()

	image_size = Vector2i(header_width, header_height)
	return image_size
