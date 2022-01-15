tool
extends HBoxContainer

# Node references
onready var scene_list : OptionButton = $SceneList
onready var close_button : Button = $CloseButton
onready var play_button : Button = $PlayButton
onready var toggle_button : Button = $ToggleButton

# Public properties
var plugin_instance : EditorPlugin

# Private properties
var _default_color : Color = Color.white
var _hover_color : Color = Color.white
var _pressed_color : Color = Color.white
var _disabled_color : Color = Color.gray

func _ready() -> void:
	_update_theme()
	
	if (plugin_instance):
		plugin_instance.connect("resource_saved", self, "_on_resource_saved")
		plugin_instance.connect("scene_changed", self, "_on_scene_changed")
		plugin_instance.connect("scene_closed", self, "_on_scene_closed")
	
	scene_list.connect("pressed", self, "_on_scene_list_opens")
	scene_list.connect("item_selected", self, "_on_scene_list_selected")
	close_button.connect("pressed", self, "_on_close_button_pressed")
	play_button.connect("pressed", self, "_on_play_button_pressed")
	toggle_button.connect("pressed", self, "_on_toggle_button_pressed")

func _update_theme() -> void:
	if (!Engine.editor_hint || !is_inside_tree()):
		return
	
	close_button.icon = get_icon("close", "Tabs")
	play_button.icon = get_icon("Play", "EditorIcons")
	
	_default_color = get_color("font_color", "OptionButton")
	_hover_color = get_color("font_color_hover", "OptionButton")
	_pressed_color = get_color("font_color_pressed", "OptionButton")
	_disabled_color = get_color("font_color_disabled", "OptionButton")

func update_scene_list() -> void:
	scene_list.clear()
	close_button.disabled = true
	if (!plugin_instance):
		return
	var editor_interface = plugin_instance.get_editor_interface()
	
	var selected_scene_path = ""
	var selected_scene = editor_interface.get_edited_scene_root()
	if (selected_scene):
		selected_scene_path = selected_scene.filename
	
	var scenes = editor_interface.get_open_scenes()
	if (scenes.size() > 0):
		var item_index = 0
		for scene_filepath in scenes:
			var scene_name = scene_filepath.get_file().get_basename()
			scene_list.add_item(scene_name)
			scene_list.set_item_metadata(item_index, scene_filepath)
			
			if (scene_filepath == selected_scene_path):
				scene_list.select(item_index)
			
			item_index += 1
		
		scene_list.add_color_override("font_color", _default_color)
		scene_list.add_color_override("font_color_hover", _hover_color)
		scene_list.add_color_override("font_color_pressed", _pressed_color)
		close_button.disabled = false
	else:
		scene_list.add_item("No open scenes")
		scene_list.set_item_disabled(0, true)
		scene_list.add_color_override("font_color", _disabled_color)
		scene_list.add_color_override("font_color_hover", _disabled_color)
		scene_list.add_color_override("font_color_pressed", _disabled_color)

### Event handlers
func _on_scene_list_opens() -> void:
	update_scene_list()

func _on_scene_changed(root_node : Node) -> void:
	update_scene_list()

func _on_resource_saved(resource : Resource) -> void:
	update_scene_list()

func _on_scene_closed(filepath : String) -> void:
	update_scene_list()

func _on_scene_list_selected(item_index : int) -> void:
	if (!plugin_instance):
		return
	
	var selected_path = scene_list.get_item_metadata(item_index)
	plugin_instance.get_editor_interface().open_scene_from_path(selected_path)

func _on_close_button_pressed() -> void:
	if (!plugin_instance):
		return
	
	var editor_node = plugin_instance.get_editor_interface().get_parent()
	if (!editor_node):
		return
	
	# This is a very unstable solution, but at least it's universal...
	# MenuOptions::FILE_CLOSE = 21
	editor_node._menu_option(21)

func _on_play_button_pressed() -> void:
	if (!plugin_instance):
		return
	
	var item_index = scene_list.selected
	var selected_path = scene_list.get_item_metadata(item_index)
	plugin_instance.get_editor_interface().play_custom_scene(selected_path)

func _on_toggle_button_pressed() -> void:
	if (!plugin_instance):
		return
	
	var scene_tabs_panel = plugin_instance.get_scene_tabs_panel()
	if (scene_tabs_panel.visible):
		scene_tabs_panel.hide()
	else:
		scene_tabs_panel.show()
