##
##  AppLovinMAXDictionaryUtils.gd
##  AppLovin MAX Godot Plugin
##
##  Created by Christopher Cong on 09/14/23.
##  Copyright © 2023 AppLovin. All rights reserved.
##

class_name AppLovinMAXDictionaryUtils


static func get_dictionary(dictionary: Dictionary, key: String, defaultValue: Dictionary = {}) -> Dictionary:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null and value is Dictionary:
		return value as Dictionary

	return defaultValue


static func get_list(dictionary: Dictionary, key: String, defaultValue: Array = []) -> Array:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null and value is Array:
		return value as Array

	return defaultValue


static func get_string(dictionary: Dictionary, key: String, defaultValue: String = "") -> String:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null:
		return str(value)

	return defaultValue


static func get_bool(dictionary: Dictionary, key: String, defaultValue: bool = false) -> bool:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null:
		return value.to_bool()

	return defaultValue


static func get_int(dictionary: Dictionary, key: String, defaultValue: int = 0) -> int:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null:
		return int(value)

	return defaultValue


static func get_long(dictionary: Dictionary, key: String, defaultValue: int = 0) -> int:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null:
		return int(value)

	return defaultValue


static func get_float(dictionary: Dictionary, key: String, defaultValue: float = 0.0) -> float:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null:
		return float(value)

	return defaultValue


static func get_double(dictionary: Dictionary, key: String, defaultValue: float = 0.0) -> float:
	if dictionary == null || dictionary == {}:
		return defaultValue

	var value = dictionary.get(key)
	if value != null:
		return float(value)

	return defaultValue

