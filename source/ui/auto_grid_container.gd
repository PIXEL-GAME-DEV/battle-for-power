@tool
extends GridContainer
## Sets GridContainer.columns before sorting children
## so that each child is approximately square in shape.
##
## NOTE: Attach this script to a GridContainer node for it to function.


func _notification(what: int):
	if what == NOTIFICATION_PRE_SORT_CHILDREN:
		var child_count := get_visible_child_count()
		columns = int(sqrt(child_count * size.aspect()))
		columns = clampi(columns, 1, child_count)


## Returns the number of visible children of this node.
## If include_internal is false, internal children are
## not counted (see add_child()'s internal parameter).
func get_visible_child_count(include_internal: bool = false) -> int:
	var child_count := 0
	for child in get_children(include_internal):
		if child.visible:
			child_count += 1
	return child_count
