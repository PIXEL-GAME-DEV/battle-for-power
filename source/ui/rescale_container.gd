@tool
class_name RescaleContainer
extends Container
## Fixes ui scaling issues that affects certain control nodes.
##
## The issue affects the following control nodes.[br][br]
## - [SubViewportContainer] (resulting in a pixel density mismatch in most cases).[br][br]
## [b]NOTE:[/b] The control node(s) being rescaled must be a child of this node.


func _notification(what: int):
	match what:
		NOTIFICATION_ENTER_TREE:
			_connect()

		NOTIFICATION_EXIT_TREE:
			_disconnect()

		NOTIFICATION_PARENTED:
			_connect()

		NOTIFICATION_UNPARENTED:
			_disconnect()

		NOTIFICATION_SORT_CHILDREN:
			var oversampling := 1.0

			if is_inside_tree() and not Engine.is_editor_hint():
				oversampling = get_viewport().get_oversampling()

			for child in get_children():
				if child is Control:
					fit_child_in_rect(child, Rect2(Vector2.ZERO, size * oversampling))
					child.scale = Vector2.ONE / oversampling


func _connect():
	if is_inside_tree():
		get_viewport().size_changed.connect(queue_sort)
	queue_sort()


func _disconnect():
	get_viewport().size_changed.disconnect(queue_sort)
