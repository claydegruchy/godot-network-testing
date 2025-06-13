extends Node3D


@export var text_template = PackedScene
var target_log_container: Control


func initate_logger(target: Control):
	target_log_container = target


var logs = []

	
func update_logging_container():
	print("update_logging_container", logs)
	if target_log_container:
		var children = target_log_container.get_children()
		for child in children:
			child.free()
		for l in logs:
			var b = Label.new()
			b.text = l
			target_log_container.add_child(b)

			
# this is fucking stupid but so is not supporting varargs
func log(a1 = null, a2 = null, a3 = null, a4 = null, a5 = null, a6 = null, a7 = null, a8 = null, a9 = null, a10 = null, a11 = null, a12 = null, a13 = null, a14 = null, a15 = null, a16 = null, a17 = null, a18 = null, a19 = null, a20 = null, a21 = null, a22 = null, a23 = null, a24 = null, a25 = null, a26 = null, a27 = null, a28 = null, a29 = null, a30 = null, a31 = null, a32 = null, a33 = null, a34 = null, a35 = null, a36 = null, a37 = null, a38 = null, a39 = null, a40 = null, a41 = null, a42 = null, a43 = null, a44 = null, a45 = null, a46 = null, a47 = null, a48 = null, a49 = null, a50 = null):
	var args = [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20, a21, a22, a23, a24, a25, a26, a27, a28, a29, a30, a31, a32, a33, a34, a35, a36, a37, a38, a39, a40, a41, a42, a43, a44, a45, a46, a47, a48, a49, a50,
	]

	var l: String = ""
	for arg in args:
		if !arg:
			continue
		l += str(arg) + ", "
	print("LOG:	", l)
	logs.append(l)
	update_logging_container()
	return
