@tool
extends EditorPlugin

const AppLovinMAXEditorPluginNameIcon = "AppLovinMAXEditorPlugin"
const AppLovinMAXEditorIcon = preload("res://addons/applovin_max/Example/Textures/applovin_max_logo.png")

func _enter_tree():
	pass
	
	
func _exit_tree():
	pass
	
	
func _has_main_screen():
	return false
	
	
func _get_plugin_name():
	return AppLovinMAXEditorPluginNameIcon
	
	
func _get_plugin_icon():
	return AppLovinMAXEditorIcon
