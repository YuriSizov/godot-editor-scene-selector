tool
extends EditorPlugin

const NodeUtils := preload("./utils/NodeUtils.gd")

var plugin_name : String = "Editor Scene Selector"
var left_dock_container : Control

var scene_selector : HBoxContainer
var scene_list : OptionButton

func get_plugin_name() -> String:
	return plugin_name

func _enter_tree() -> void:
	var test_control = Control.new()
	test_control.name = "MyControl"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, test_control)
	left_dock_container = test_control.get_parent().get_parent()
	remove_control_from_docks(test_control)
	test_control.queue_free()

	var tab_control = get_dock_by_name("Scene")
	if (!tab_control):
		return

	scene_selector = preload("res://addons/editor-scene-selector/SceneSelectorBox.tscn").instance()
	scene_selector.plugin_instance = self

	var first_child = tab_control.get_child(0)
	tab_control.add_child_below_node(first_child, scene_selector)
	tab_control.move_child(first_child, 1)
	scene_selector.update_scene_list()

	var scene_tabs_panel = get_scene_tabs_panel()
	scene_tabs_panel.hide()

func _exit_tree() -> void:
	var parent_node = scene_selector.get_parent()
	parent_node.remove_child(scene_selector)
	scene_selector.queue_free()

### Helpers
func get_dock_by_name(tab_name : String) -> Control:
	var matched_tab = null

	var first_split = left_dock_container.get_parent()
	var left_ul_node = left_dock_container.get_child(0)
	matched_tab = NodeUtils.get_child_by_name(left_ul_node, tab_name)
	if (matched_tab):
		return matched_tab

	var left_bl_node = left_dock_container.get_child(1)
	matched_tab = NodeUtils.get_child_by_name(left_bl_node, tab_name)
	if (matched_tab):
		return matched_tab

	var second_split = first_split.get_child(1)
	var left_dock2_container = second_split.get_child(0)
	var left_ur_node = left_dock2_container.get_child(0)
	matched_tab = NodeUtils.get_child_by_name(left_ur_node, tab_name)
	if (matched_tab):
		return matched_tab

	var left_br_node = left_dock2_container.get_child(1)
	matched_tab = NodeUtils.get_child_by_name(left_br_node, tab_name)
	if (matched_tab):
		return matched_tab

	var third_split = second_split.get_child(1)
	var forth_split = third_split.get_child(1)
	var right_dock_container = forth_split.get_child(0)
	var right_ul_node = right_dock_container.get_child(0)
	matched_tab = NodeUtils.get_child_by_name(right_ul_node, tab_name)
	if (matched_tab):
		return matched_tab

	var right_bl_node = right_dock_container.get_child(1)
	matched_tab = NodeUtils.get_child_by_name(right_bl_node, tab_name)
	if (matched_tab):
		return matched_tab

	var right_dock2_container = forth_split.get_child(1)
	var right_ur_node = right_dock2_container.get_child(0)
	matched_tab = NodeUtils.get_child_by_name(right_ur_node, tab_name)
	if (matched_tab):
		return matched_tab

	var right_br_node = right_dock2_container.get_child(1)
	matched_tab = NodeUtils.get_child_by_name(right_br_node, tab_name)
	if (matched_tab):
		return matched_tab

	return null

func get_scene_tabs_panel() -> Control:
	var base_control = get_editor_interface().get_base_control()
	var indices := [ "VBoxContainer", 1, 1, 1, 0, 0, 0, 0, 0 ]

	var current_node = base_control
	var step = 1
	while (indices.size() > 0):
		#print(str(step) + ": " + current_node.name + " (" + current_node.get_class() + ")")

		var next_index = indices.pop_front()
		if (next_index is String):
			var current_children = current_node.get_children()
			var matched_child = null

			for child in current_children:
				if (child.get_class() == next_index || child.name == next_index):
					matched_child = child
					break

			if (matched_child == null):
				printerr("Premature stop at " + current_node.name + " (" + current_node.get_class() + "): No matching class or name")
				return null

			current_node = matched_child
		else:
			if (next_index < 0 || next_index >= current_node.get_child_count()):
				printerr("Premature stop at " + current_node.name + " (" + current_node.get_class() + "): Index out of bounds")
				return null

			current_node = current_node.get_child(next_index)

		step += 1

	#print("F: " + current_node.name + " (" + current_node.get_class() + ")")
	return current_node
