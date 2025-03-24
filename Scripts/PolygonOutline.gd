@tool
class_name PolygonOutline
extends Polygon2D

@export var outline_color:Color = Color(0.204,0.078,0.102,0.5):
	set(c):
		outline_color = c
@export var outline_width:float = 6.0:
	set(w):
		outline_width = w
@export var outline_material:Material = load("res://Resources/Shaders/SM_LineWobble.tres")
@export var fill_texture:Texture2D
@export var clipChildren:bool = true

func _ready() -> void:
	var outline = Line2D.new()
	add_child(outline)
	outline.name = "Outline of " + str(name)
	outline.points = polygon
	outline.default_color = outline_color
	outline.closed = true
	outline.width = outline_width
	if outline_material:
		outline.material = outline_material
	if fill_texture:
		outline.texture = fill_texture
		outline.texture_mode = Line2D.LINE_TEXTURE_TILE
	
	if clipChildren:
		clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	else:
		clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
