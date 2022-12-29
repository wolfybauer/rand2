extends CanvasLayer

#class_name DebugOverlay

var stats = []

func _ready():
	pass 

# stat_ref = method or variable
func add_stat(stat_name, object, stat_ret, is_method):
	stats.append([stat_name, object, stat_ret, is_method])

func _process(delta):
	var label_text = ''
	
	for s in stats:
		var value = null
		
		# if object exists, and hasn't been queue freed
		if s[1] and weakref(s[1]).get_ref():
			if s[3]: # is method
				value = s[1].call(s[2]) # call member method
			else: # is var
				value = s[1].get(s[2]) # get member data
		# add to label text
		label_text += str(s[0], ': ', value)
		label_text += '\n'
	# print the text
	$Label.text = label_text
