
extends Node2D

#all the nodes
var current_portrait_node_name
var current_portrait_node
var portrait_selected_node_string
var portrait_selected_num
var dialogue_sample_text
var dialogue_sample_box
var question_panel
var answerboxes
var answer1_stylebox
var answer1_text
var answer2_stylebox
var answer2_text
var answer3_stylebox
var answer3_text
var answer4_stylebox
var answer4_text

#hammer nodes
var hammer_timer
var text_queue
var soundplayer
var playingchatter = false   #start as false
var chatter_voiceID = 0
var sound_margin

#question variables
var question_mode = false
var answerbox_loc

#hammer variables
var display_text
var hammer_pos

var main_panel
var current_portrait_choice

var portraitlost_warning = true

func _ready():
	
	#So that GUI scroller does not appear. I don't need mouse/tablet style interaction in game when the standard is a gamepad. If I were to use the scroller, I'd use a new custom theme.
	get_node("dialogue_output").set_scroll_active(false)
	answerbox_loc = "/root/main_node/main_panel/dialogue_node/answerboxes_node/"
	hammer_pos = 0
	sound_margin = 0
	set_process(true)
	
#############
# end of _ready

func _process(delta):
	
	#update size of the dialogue box if the portrait dialogue is checked to make room for a portrait
	#also update for question mode
	dialogue_sample_text = get_node("dialogue_output")
	dialogue_sample_box = get_node("dialogue_stylebox")
	answerboxes = get_node("answerboxes_node")
	
	question_panel = get_node("/root/main_node/main_panel/question_panel")  #to be able to hide or show the options
	main_panel = get_node("/root/main_node/main_panel")
	
	
	
	
	if question_mode == false:
		question_panel.hide()
		answerboxes.hide()
		
		dialogue_sample_text.set_margin(1,18)  #top margin
		dialogue_sample_text.set_margin(3,62) #bottom margin
		dialogue_sample_box.set_margin(1,8) #top margin for stylebox
		
		
		
		if get_node("/root/main_node/main_panel/portrait_checkbox").is_pressed():   #No questions with portrait
			dialogue_sample_text.set_margin(0,82) #left margin
			dialogue_sample_box.set_margin(0,72)
			
			portrait_selected_num = get_node("/root/main_node/main_panel/portrait_options").get_selected()
			current_portrait_node_name = get_node("/root/main_node/main_panel/portrait_options").get_item_text(portrait_selected_num)
			current_portrait_node = get_node("portrait_nodes/"+current_portrait_node_name)
			current_portrait_choice = get_node("/root/main_node/main_panel/portrait_options").get_selected()
			#print("Current portrait choice: ",current_portrait_choice)
			portrait_selected_node_string = main_panel.wholedic["portraits"][str(current_portrait_choice)]
			#print("selected portrait node: ",portrait_selected_node_string)
			
			if (main_panel.last_portrait_flip==true) && (main_panel.portrait_to_hide):   # if trigger for hiding the last portrait enabled & portrait_to_hide exists... disable last portrait
				get_node("portrait_nodes/"+main_panel.portrait_to_hide).hide()
			
			if portrait_selected_node_string:   #it could not exist, this prevents it
				get_node("portrait_nodes/"+portrait_selected_node_string).show()
			elif portraitlost_warning:
				print("Error! Dialogue box could not find the portrait to display!")
				print("Portrait that failed to load: ",portrait_selected_node_string)
				portraitlost_warning = false
			
			
		else: #No questions & no portrait allowed
			
			dialogue_sample_text.set_margin(0,18)
			dialogue_sample_box.set_margin(0,8) #left
			
			current_portrait_choice = get_node("/root/main_node/main_panel/portrait_options").get_selected_ID()
			
			if (main_panel.portrait_nodename_dic.has(current_portrait_choice)): #if the portrait name is available in the list
				portrait_selected_node_string = main_panel.portrait_nodename_dic[current_portrait_choice]
				#TODO to hide the portrait, it must be the LAST portrait used that needs to be addressed AS WELL as the current
				#print("selected portrait node: ",portrait_selected_node_string)
				if (main_panel.last_portrait_flip) && (main_panel.portrait_to_hide):   # if trigger for hiding the last portrait enabled & portrait_to_hide exists... disable last portrait
					get_node("portrait_nodes/"+main_panel.portrait_to_hide).hide()
					
				if portrait_selected_node_string:
					#print("... : ",main_panel.portrait_nodename_dic[current_portrait_choice].size())
					#print("just tried to hide: ",portrait_selected_node_string)
					get_node("portrait_nodes/"+portrait_selected_node_string).hide() # used to be like main_panel.portrait_last_selected
				elif portraitlost_warning:
					print("Error! Dialogue box could not find the portrait to hide!")
					print("Portrait that failed to load: ",main_panel.portrait_nodename_dic[current_portrait_choice])
					portraitlost_warning = false
			
	if question_mode == true:
	
		question_panel.show()
		answerboxes.show()
		
		current_portrait_node_name = get_node("/root/main_node/main_panel/portrait_options").get_text()
		current_portrait_node = get_node("portrait_nodes/"+current_portrait_node_name)
		
		dialogue_sample_text.set_margin(1,58)  #top margin
		dialogue_sample_text.set_margin(3,70) #bottom margin
		dialogue_sample_box.set_margin(1,55) #top
		
		answer1_stylebox = get_node(answerbox_loc+"answer1_stylebox")
		answer2_stylebox = get_node(answerbox_loc+"answer2_stylebox")
		answer3_stylebox = get_node(answerbox_loc+"answer3_stylebox")
		answer4_stylebox = get_node(answerbox_loc+"answer4_stylebox")
		answer1_text = get_node(answerbox_loc+"answer1_text")
		answer2_text = get_node(answerbox_loc+"answer2_text")
		answer3_text = get_node(answerbox_loc+"answer3_text")
		answer4_text = get_node(answerbox_loc+"answer4_text")
		
		current_portrait_choice = get_node("/root/main_node/main_panel/portrait_options").get_selected_ID()
		portrait_selected_node_string = main_panel.portrait_nodename_dic[current_portrait_choice]
		
		if get_node("/root/main_node/main_panel/portrait_checkbox").is_pressed():   #Questions with a portrait
			portrait_selected_num = get_node("/root/main_node/main_panel/portrait_options").get_selected()
			current_portrait_node_name = get_node("/root/main_node/main_panel/portrait_options").get_item_text(portrait_selected_num)
			current_portrait_node = get_node("portrait_nodes/"+current_portrait_node_name)
			current_portrait_choice = get_node("/root/main_node/main_panel/portrait_options").get_selected_ID()
			
			portrait_selected_node_string = main_panel.portrait_nodename_dic[current_portrait_choice]
			#print("selected portrait node: ",portrait_selected_node_string)
			#show in the GUI
			
			if (main_panel.last_portrait_flip) && (main_panel.portrait_to_hide):   # if trigger for hiding the last portrait enabled & portrait_to_hide exists... disable last portrait
				get_node("portrait_nodes/"+main_panel.portrait_to_hide).hide()
			
			if portrait_selected_node_string:   #it could not exist, which crashes this
				get_node("portrait_nodes/"+main_panel.portrait_nodename_dic[current_portrait_choice]).show()
			elif portraitlost_warning:
				print("Error! Dialogue box could not find the portrait to display!")
				print("Portrait that failed to load: ",main_panel.portrait_nodename_dic[current_portrait_choice])
				portraitlost_warning = false
			
			#resize all style boxes
			
			#question
			dialogue_sample_box.set_margin(0,72)
			
			#left side answers
			answer1_stylebox.set_margin(0,88)   #left margin
			answer1_stylebox.set_margin(2,220)  #right margin
			answer3_stylebox.set_margin(0,88)
			answer3_stylebox.set_margin(2,220)
			#right side answers
			answer2_stylebox.set_margin(0,236)
			answer4_stylebox.set_margin(0,236)
			
			#remargin all text
			#question
			dialogue_sample_text.set_margin(0,82) #left margin
			
			#left side answers
			answer1_text.set_margin(0,94) #left margin
			answer1_text.set_margin(2,216) #right margin
			answer3_text.set_margin(0,94)
			answer3_text.set_margin(2,216)
			#right side answers
			answer2_text.set_margin(0,242)
			answer4_text.set_margin(0,242)
			
			
		else:  #Questions without a portrait
		
			current_portrait_choice = get_node("/root/main_node/main_panel/portrait_options").get_selected_ID()
			#print("current portrait choice: ",current_portrait_choice)
			portrait_selected_node_string = main_panel.portrait_nodename_dic[current_portrait_choice]
			#print("selected portrait node: ",portrait_selected_node_string)
			if (main_panel.last_portrait_flip) && (main_panel.portrait_to_hide):   # if trigger for hiding the last portrait enabled & portrait_to_hide exists... disable last portrait
				get_node("portrait_nodes/"+main_panel.portrait_to_hide).hide()
			
			if portrait_selected_node_string:
				get_node( "portrait_nodes/"+portrait_selected_node_string).hide()
			elif portraitlost_warning:
				print("Error! Dialogue box could not find the portrait to hide!")
				print("Portrait that failed to load: ",main_panel.portrait_nodename_dic[current_portrait_choice])
				portraitlost_warning = false
			
			#styleboxes remargined
			#question
			dialogue_sample_box.set_margin(0,8)
			#left side answers
			answer1_stylebox.set_margin(0,24)  #left margin
			answer1_stylebox.set_margin(2,188)
			answer3_stylebox.set_margin(0,24)
			answer3_stylebox.set_margin(2,188)
			#right side answers
			answer2_stylebox.set_margin(0,204)
			answer4_stylebox.set_margin(0,204)
			
			#text remargined
			#question
			dialogue_sample_text.set_margin(0,18)
			
			#answers
			#left side
			answer1_text.set_margin(0,30)
			answer1_text.set_margin(2,152)
			answer3_text.set_margin(0,30)
			answer3_text.set_margin(2,152)
			#right side
			answer2_text.set_margin(0,210)
			answer4_text.set_margin(0,210)
	
	
	
############################
# end of _process


func _on_question_checkbox_toggled( pressed ):
	if pressed:
		question_mode = true
		portraitlost_warning = true
	else:
		question_mode = false
		portraitlost_warning = true
		
		
func _on_letter_timer_timeout():
	#need these nodes
	hammer_timer = get_node("letter_timer")
	dialogue_sample_text = get_node("dialogue_output")
	text_queue = get_node("/root/main_node/main_panel/dialogue_edit").get_text()
	soundplayer = get_node("dialogue_sounds")
	
	#show letters one by one
	display_text = text_queue.substr(0,hammer_pos)
	
	#update text and play a sound each time if it's not a space
	if hammer_pos <= text_queue.length():
		dialogue_sample_text.set_bbcode(display_text)
		if text_queue.substr(hammer_pos - 1,hammer_pos) != " "  && sound_margin == 2:   #detect space in case you want to only play a sound each time a letter is detected
			chatter_voiceID = soundplayer.play("chatterhighshort")  #should create a new voice, good in case the sounds merge a bit in timing before the sound is over
			playingchatter = true
		#sound margin so as to space out the sounds
		sound_margin += 1
		if sound_margin > 2:   # set the sounds apart enough so they sound out more like vowels and aren't too fast
			sound_margin = 0
	#stop hammer & sound
	else:    #aka   if hammer_pos > text_queue.length():
		hammer_timer.stop()
		if (playingchatter):   #if still playing the sound, stop
			#soundplayer.stop(chatter_voiceID)    #don't need to if you're using small sounds for each letter, they will just end
			playingchatter = false
			
			
	#print("Hammer position: ",hammer_pos)
	hammer_pos += 1
	
	#print("is soundplayer alive?: ",soundplayer.get_voice_count())
	#sound is optional, surely would get really annoying with much editing
	if (playingchatter):
		if get_node("/root/main_node/main_panel/sound_enabler").is_pressed():
			soundplayer.set_volume(chatter_voiceID, 0.6)
		else:
			soundplayer.set_volume(chatter_voiceID, 0)



