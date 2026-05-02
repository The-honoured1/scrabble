extends Node
class_name AppThemeSingleton

var BG_DARK := Color("#1A1A18")
var BG_SURFACE := Color("#242420")
var BG_CARD := Color("#2C2C28")
var BORDER := Color("#3A3A36")
var TEXT_PRIMARY := Color("#F5F4EF")
var TEXT_MUTED := Color("#7A7A74")
var ACCENT_GREEN := Color("#52B788")
var ACCENT_PURPLE := Color("#9D8FD4")
var ACCENT_YELLOW := Color("#F0C940")
var ACCENT_NAVY := Color("#4A7FBF")
var ACCENT_RED := Color("#E05C3A")
var ACCENT_AMBER := Color("#E9A84C")
var TILE_CORRECT := Color("#52B788")
var TILE_PRESENT := Color("#E9A84C")
var TILE_ABSENT := Color("#4A4A46")
var TILE_EMPTY := Color("#2C2C28")

var FONT_DISPLAY := 42
var FONT_TITLE := 28
var FONT_HEADING := 20
var FONT_BODY := 15
var FONT_LABEL := 12
var FONT_MINI := 10

var display_font: FontFile
var sans_regular: FontFile
var sans_medium: FontFile

func _ready() -> void:
	display_font = load("res://assets/fonts/PlayfairDisplay-Bold.ttf") if ResourceLoader.exists("res://assets/fonts/PlayfairDisplay-Bold.ttf") else null
	sans_regular = load("res://assets/fonts/DMSans-Regular.ttf") if ResourceLoader.exists("res://assets/fonts/DMSans-Regular.ttf") else null
	sans_medium = load("res://assets/fonts/DMSans-Medium.ttf") if ResourceLoader.exists("res://assets/fonts/DMSans-Medium.ttf") else null

func style_card(accent: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = accent
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = BORDER
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	return sb
