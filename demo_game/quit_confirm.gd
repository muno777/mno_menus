extends MnoMenu
tool


func tick(should_read_inputs: bool = true) -> void:
	.tick(should_read_inputs)
	
	if mno_master.slide_progress != 0 && mno_master.get_current_menu() == self:
		var real_progress: int = int(max(abs(mno_master.slide_progress) - mno_master.TRANSITION_DELAY, 0))
		var distance: float = ease(real_progress / float(mno_master.SLIDE_LENGTH), 0.5)
		if sign(mno_master.slide_progress) == 1.0:
			distance = 1 - distance
#		if get_node_or_null("BlurRect") != null:
#			$BlurRect.material.set_shader_param("blur_size", int(32 * (1 - distance)))
		$ColorRect.color = Color(0.0, 0.0, 0.0, (1 - distance) * 0.5)
