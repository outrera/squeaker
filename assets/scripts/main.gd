
################################################################################
#                                 Meep                                         #
#       This program named 'Meep' is a Dialogue Editor designed for            #
#    low resolution game developement. It was made in Godot using GDscript.    #
#      This program outputs a JSON file containing all the dialogue data.      #
# You can then use that same file to add dialogue, portraits and questions to  #
# your own game. It was designed for an unnamed game currently in development. #
################################################################################
#             Created in 2015 by AGAaron & Akkhima of "VAR Team"               #
#     Licensed under the MIT license: http://opensource.org/licenses/MIT       #
################################################################################

const program_version = "0.68"

#Currently not working:
# - When changing messages or the time/place, the portrait saved does not load
# - Answer data does not save or load correctly yet

##############################
# high priority BUGs & TODO
##########

# - load portrait saved on character choice switch
# - load portrait saved on time/place choice switch
# - load answers on character choice switch
# - load answers on time/place choice switch
# - load answers on message choice switch
# - load answer on answer choice switch (proper!!)
# - Save answer as answer choice is switched
# - Save answers when the message is switched
# - Save answers on quit
# - Dialogue data output that's spreadsheet compatible

##############################
# low priority
##########

# - Last edited message feature, store to JSON file just one variable that points
#       us to which message was edited last before saved. This message will be reopened 
#       when the file is reopened (currently on program open)
# - Read the portraits from the save file & compare the list in there with
#       what's found in the portrait folder.
# - Allow option to change the portrait folder
# - Allow adding individual portraits, which will just copy into the portraits folder anyways

extends Panel

#nodes & associated variables
var dialogue_editor
var dialogue_editor_text

#default values
var example_character = ""
var example_place = ""
var example_portrait_name = ""
var example_text = ""
var example_answer1 = ""
var example_answer2 = ""
var example_answer3 = ""
var example_answer4 = ""


#TODO Some garbage variables may be loose, clean up


#to detect when quitting, polls notifications
var cur_notif

#questions logic
var answer_selection


var last_character_choice
var last_timeplace_choice
var last_message_choice
var last_portrait_choice
var last_answer_choice
var triggertype

var timeplace_add_loop
var current_timeplace_key

var character_choice
var timeplace_choice
var message_choice
var portrait_choice
var answer_choice
var newportrait


var save_character_name
var encoded_save_character_name
var save_timeplace_name
var save_message_choice
var save_portrait_choice
var saved_portrait_option_number
var node_matching_saved_portrait
var saved_portrait

var messagechange_trigger = false
var save_portrait_trigger = false
var save_answer_trigger = false

#collect portrait nodes function
var portrait_foldernode = 0
var portrait_node_count = 0
var portrait_nodename_dic = {}
var portrait_load_count = 0
var portrait_choiceadded_count
var current_portrait_node_name
var encoded_portrait_name

var char_encoded
var wherewhen_encoded
var changemessage_decoded

var autoload_ready = false
var hard_coded = true   #for when you want to hardcode values in the dictionaries frome _ready()

#load up variables
var charlist
var charcount = 0
var current_character

var portrait_num_found = false


var dics_populated = false

#stuff to refer to and save to JSON later
var save_json   #call as a dictionary before saving, place all other dictionaries and save data into it
var current_id = 0    #the ID is the key to all of the dictionaries
#character choice integer
var wherewhendic = {}    #The place or time, so that new messages will be displayed as the game progresses or after talking to the character once
var portraitdic = {}   #stores an integer indicating the portrait used for each message

var portrait_name_dic
var portrait_name_dic_keys
var add_portrait_choice
var current_portrait_choice
var portrait_to_hide
var portrait_load_loop
var portrait_load_num

var id_key = 0
var char_key = 0
var wherewhen_key = 0
var mod_key = 0

var last_char_choice
var last_tp_choice
var last_msg_choice

var answer_save_slot = "2"  #1st answer slot



var edited_text
var encoded_text
var char_selection
var wherewhen_selection
var portrait_selection

#For use of the dialogue box 
#This code here was designed for preview purposes for this program,
#but it can be adapted for game use if similar code is produced to plug in the variables
var displayed_text_mem
var hammer_timer
var playingchatter
var chatter_voiceID
var soundplayer
#variable to tell when to hide the last portrait
var last_portrait_flip

var wholedic
var jsonfile
var jsonstring
var output_dir
var output_directory_loc

#for loading the data
var decoded_character_name
var decoded_timeplace_name
var char_read_counter
var char_list
var timeplace_read_counter
var timeplace_list
var options_counter
var message_read_counter
var message_list
var portrait_list
var portrait_read_counter
var portrait_name
var answer1_list
var answer2_list
var answer3_list
var answer4_list
var character_string
var timeplace_string
var character_decoded
var timeplace_decoded
var portrait_load_choice
var portrait_load_decoded
var portrait_keys
var portrait_load_choice_num

#editor variables for percent-encoding/decoding
var full_message
var formatted_message

#adding characters or places
var add_character_mode = false
var add_timeplace_mode = false
var newname
var newtimeplace
var excused_change = false
var item_loop
var current_character_name
var encoded_character_name
var newly_selected_name
var current_timeplace_name
var encoded_timeplace_name
var newly_selected_timeplace

#example default variables
var example_character1
var example_c1_tp1
var example_c1_tp2
var example_c1_port1
var example_c1_port2
var example_c1_tp1_text1
var example_c1_tp1_text2
var example_c1_tp2_text1
    #example char 2
var example_character2
var example_c2_tp1
var example_c2_tp2
var example_c2_port1
var example_c2_port2
var example_c2_tp1_text1
var example_c2_tp1_text2
var example_c2_tp2_text1
var encoded_example_name



#all the information required to sort save data
var character_name
var has_empty_name
var timeplace_name
var save_value_type
var slot
var save_value
var character_encoded
var timeplace_encoded
var message_encoded



const DICTIONARY_TYPE = typeof({})

# Recreate the structure of a dictionary, maintaining references to all leaf-level values.
# HACK: A workaround is used in place until bug #2381 is cleared by copying the dictionary back into itself:   https://github.com/okamstudio/godot/issues/2381
func copy_dictionary(dictionary):
   var output = {}
   for key in dictionary.keys():
      var value = dictionary[key]
      if typeof(value) == DICTIONARY_TYPE:
         output[key] = copy_dictionary(value)
      else:
         output[key] = value
   return output




func _ready():
	
	#the menu option apparently does nothing...
	get_tree().set_auto_accept_quit(false)
	
	load_data()   #autoload the data at the beginning of runtime
	
	last_character_choice = get_node("character_options").get_text()
	last_timeplace_choice = get_node("timeplace_options").get_text()
	last_message_choice = get_node("messagenum_options").get_value()   #grab this beforehand so the comparison done later in the main loop spares us of detecting a difference
	last_portrait_choice = get_node("portrait_options").get_text()
	last_answer_choice = (get_node("question_panel/answer_options").get_selected_ID() + 2)  #by default first answer slot
	
	
	#a good place to put all the answer options... which are just static numbers of 1-4
	get_node("question_panel/answer_options").add_item("#1",0)
	get_node("question_panel/answer_options").add_item("#2",1)
	get_node("question_panel/answer_options").add_item("#3",2)
	get_node("question_panel/answer_options").add_item("#4",3)
	get_node("question_panel/answer_options").select(0)
	
	set_process(true)
#########################
#end of ready



#main loop
func _process(delta):
	
	#It is crucial these declarations stay in this scope and not below as it insures that 
	#  the timeplace dictionaries don't bleed into other characters
	character_choice = get_node("character_options").get_text()
	timeplace_choice = get_node("timeplace_options").get_text()
	message_choice = get_node("messagenum_options").get_value()
	portrait_choice = get_node("portrait_options").get_text()
	answer_choice = (get_node("question_panel/answer_options").get_selected_ID() + 2)
	
	#update answer slot based on the text that's currently in the answer edit box
	if get_node("question_checkbox").is_pressed():  #if question mode is enabled
		answer_selection = get_node("question_panel/answer_options").get_selected_ID() + 1
		print ("Question selected: ",get_node("question_panel/answer_options").get_selected_ID() + 1 )
		if (get_node("question_panel/answer_edit").get_text()):
			get_node( "dialogue_node/answerboxes_node/answer"+str(answer_selection)+"_text" ).set_bbcode( get_node("question_panel/answer_edit").get_text() )
		else:
			get_node( "dialogue_node/answerboxes_node/answer"+str(answer_selection)+"_text" ).set_bbcode("")
	
	
	
	#on change, be sure to save
	#excused changes bypass this regular save process, mostly used for deletion
	if excused_change != true:  #if not an excused change...
		
		messagechange_trigger = false
		save_portrait_trigger = false
		save_answer_trigger = false
		
		
		if last_character_choice != character_choice:
			messagechange_trigger = true  #The massage_change_trigger not only saves the message itself, but also the portrait choice & answers.
			triggertype = 0
		
		elif last_timeplace_choice != timeplace_choice:
			messagechange_trigger = true
			triggertype = 1
		
		elif last_message_choice != message_choice:
			messagechange_trigger = true
			triggertype = 2
			
		elif last_portrait_choice != portrait_choice:
			save_portrait_trigger = true  #saves ONLY the portrait choice
			last_portrait_flip = true  #used by dialogue_box.gd to hide the last and show the new
			triggertype = 3
			
		elif last_answer_choice != answer_choice:
			save_answer_trigger = true #saves ONLY the last answer
			triggertype = 4
			
		if messagechange_trigger == true:
			#What does this do again...? Save the last message? Guessing so.
			messagenum_changed(last_character_choice,last_timeplace_choice,last_message_choice,last_portrait_choice,triggertype)	
			
			#set all last to current now so that last doesn't become LAST last and so on
			character_choice = get_node("character_options").get_text()
			timeplace_choice = get_node("timeplace_options").get_text()
			message_choice = get_node("messagenum_options").get_value()
			portrait_choice = get_node("portrait_options").get_text()
			
			last_character_choice = character_choice
			last_timeplace_choice = timeplace_choice
			last_message_choice = message_choice
			last_portrait_choice = portrait_choice
			messagechange_trigger = false
		
		
		if save_portrait_trigger == true:
			#print("last portrait choice: ",last_portrait_choice)
			portrait_to_hide = last_portrait_choice
			get_node("dialogue_node/portraits/"+portrait_to_hide).hide()
			character_choice = get_node("character_options").get_text()
			timeplace_choice = get_node("timeplace_options").get_text()
			message_choice = get_node("messagenum_options").get_value()
			portrait_choice = get_node("portrait_options").get_text()
			#save the value using the above current info along with the CURRENT portrait, not the last
			save_to_script(character_choice,timeplace_choice,"1",message_choice,portrait_choice)
			
			last_portrait_choice = portrait_choice
			
			save_portrait_trigger = false
		
		
		var last_answer
		if save_answer_trigger == true:
			
			character_choice = get_node("character_options").get_text()
			timeplace_choice = get_node("timeplace_options").get_text()
			message_choice = get_node("messagenum_options").get_value()
			portrait_choice = get_node("portrait_options").get_text()
			last_answer = get_node("question_panel/answer_edit").get_text()
			
			#save the value using the above current info along with the CURRENT answer chosen, not the last
			save_to_script(character_choice,timeplace_choice,str(answer_save_slot),message_choice,last_answer)
			
			answer_choice = (get_node("question_panel/answer_options").get_selected_ID() + 2)
			var next_answer_text
			#Set the newly selected answer data into the editor box
			character_encoded = character_choice.percent_encode()
			timeplace_encoded = timeplace_choice.percent_encode()
			if (wholedic["script"][character_encoded][timeplace_encoded][str(answer_choice)].has(str(message_choice)) ): #if this entry exists...
				#set selected entry into edit box
				next_answer_text = wholedic["script"][character_encoded][timeplace_encoded][str(answer_choice)][str(message_choice)]
				next_answer_text = next_answer_text.percent_decode()
				get_node("question_panel/answer_edit").set_text(next_answer_text)
			else:
				get_node("question_panel/answer_edit").set_text("")
			
			
			last_answer_choice = answer_choice
			save_answer_trigger = false
		
		#add/remove functionality
		#add character
		if get_node("new_character_popup/add_char_confirm_button").is_pressed() == true && add_character_mode == true:
			add_character()
		if get_node("new_character_popup/add_char_cancel_button").is_pressed() == true && add_character_mode == true:
			cancel_add_character()
		#add time/place
		if get_node("new_timeplace_popup/add_timeplace_confirm_button").is_pressed() == true && add_timeplace_mode == true:
			add_timeplace()
		if get_node("new_timeplace_popup/add_cancel_button").is_pressed() == true && add_timeplace_mode == true:
			cancel_add_timeplace()
		
		
		#####################
		#IMPORTANT  This code is what needs to be replicated in some form to trigger the dialogue node visual in-game
		dialogue_editor_text = get_node("dialogue_edit").get_text()   #stores whatever is in the upper left editable box
		
		if displayed_text_mem != dialogue_editor_text:   # if the dialogue edit box (the big one in the top left) 
				# changes from what's stored in memory (ANY typing should trigger this again) then update by
				# typing the whole message out again
			get_node("dialogue_node").hammer_pos = 0
			hammer_timer = get_node("dialogue_node/letter_timer")
			displayed_text_mem = dialogue_editor_text   #displayed_text_mem is the same as text_queue later
			hammer_timer.start()  #start if stopped
			
			
		###########################################
		# end of migration code
		
		
	else:   #if excused as a manual change in the save data (applies to adding and removing characters & times/places so far)
		#reset the variables so they won't trigger
		last_character_choice = character_choice
		last_timeplace_choice = timeplace_choice
		last_message_choice = message_choice
		last_portrait_choice = portrait_choice
		last_answer_choice = answer_choice
		messagechange_trigger = false
		excused_change = false
		
		
		
	
####################################
#   End of _process


#portrait change
func portraitnum_changed():
	newportrait = get_node("portrait_options").get_text()
	

#Character, time/place or message change updates
#when the message number changes, it should both save the message from the editor box as well as clear it
func messagenum_changed(last_char_choice,last_tp_choice,last_msg_choice,last_port_choice,triggertype):
	dialogue_editor = get_node("dialogue_edit")
	edited_text = dialogue_editor.get_text() 
	encoded_text = edited_text.percent_encode()
	
	# These current GUI values will not be correct for either the last or message. The message that was changed needs to be segragated
	# and overwritten, but the rest of the last values should stay, so they will be kept not changed as their trigger type would indicate
	save_character_name = get_node("character_options").get_text()
	save_timeplace_name = get_node("timeplace_options").get_text()
	save_message_choice = get_node("messagenum_options").get_value()
	save_portrait_choice = get_node("portrait_options").get_text()
	
	#get current values from GUI
	char_selection = get_node("character_options").get_text()
	wherewhen_selection = get_node("timeplace_options").get_text()
	portrait_selection = get_node("portrait_options").get_text()
	message_choice = get_node("messagenum_options").get_value()
	
	#load from the big dictionary
	char_encoded = char_selection.percent_encode()
	wherewhen_encoded = wherewhen_selection.percent_encode()
	timeplace_list = wholedic["script"][char_encoded].keys()
	print("Character: ",char_selection,"    Timeplace list: ",timeplace_list)
	
	if triggertype == 0:   #character change triggered this, therefore update what can be in the time/place list
		save_character_name = last_char_choice
		save_timeplace_name = last_tp_choice
		save_message_choice = int(last_msg_choice)
		save_portrait_choice = last_portrait_choice
		
		#empty out the times/places, they change as characters change
		get_node("timeplace_options").clear()
		
		#add times & places for the current character
		   #do while less than the total size of the recorded times/places for this new character
		timeplace_add_loop = 0
		while timeplace_add_loop < wholedic["script"][char_encoded].size():
			current_timeplace_key = timeplace_list[timeplace_add_loop]
			
			get_node("timeplace_options").add_item( current_timeplace_key.percent_decode() )
			print("  Added this location (on character change): \"", current_timeplace_key.percent_decode(),"\" from character: ", char_selection)
			timeplace_add_loop += 1
		
		#choose first in the list because it's a new character:
		wherewhen_encoded = timeplace_list[0]
		changemessage_decoded = wholedic["script"][char_encoded][wherewhen_encoded]["0"][str(message_choice)]
		changemessage_decoded = changemessage_decoded.percent_decode()
		dialogue_editor.set_text(changemessage_decoded)  #put the loaded text into the editor
		
		#reset timeplace menu
		#I don't know if I'm doing this all safely. What about later messages traversing to other characters?
		#Does it actually reset or just change the value? Does the change trigger? I think it might do so automatically.
		#This is why you don't wait 2 years to finish your dialogue editor.
		get_node("timeplace_options").select(0)
		get_node("messagenum_options").set_value(0)
		
		update_portrait()
		#Update portrait
		
		
		
	
	if triggertype == 1:   #time/place change triggered it
		print("Time/place change trigger")
		save_timeplace_name = last_tp_choice
		save_message_choice = int(last_msg_choice)
		save_portrait_choice = last_portrait_choice
		
		#much like the next trigger type, update the editor box if it's both existant & not empty
		if (wholedic["script"][char_encoded][wherewhen_encoded]["0"].has(str(message_choice))) && wholedic["script"][char_encoded][wherewhen_encoded]["0"][str(message_choice)] != "":
			changemessage_decoded = wholedic["script"][char_encoded][wherewhen_encoded]["0"]["0"]  #set to zero because it's the time/place
			changemessage_decoded = changemessage_decoded.percent_decode()
			dialogue_editor.set_text(changemessage_decoded)
		else:   #if non-existant or empty, set to blank
			dialogue_editor.set_text("")
			get_node("dialogue_node/dialogue_output").set_bbcode("")
			
		#reset messages to first choice
		get_node("messagenum_options").set_value(0)
		
		#Update portrait
		#Hide last portrait
		get_node("dialogue_node/portraits/"+last_portrait_choice).hide()
		#If the entry exists, load it up
		if wholedic["script"][char_encoded][wherewhen_encoded]["1"].has("0"):
			saved_portrait = wholedic["script"][char_encoded][wherewhen_encoded]["1"]["0"]
			for node_matching_saved_portrait in range(0,get_node("dialogue_node/portraits").get_child_count()):
				if get_node("dialogue_node/portraits").get_child(node_matching_saved_portrait).get_name() == saved_portrait:
					saved_portrait_option_number = node_matching_saved_portrait
					break
				print("Coming through")
			#Set drop down menu for portrait selection to the saved selection
			get_node("portrait_options").select(saved_portrait_option_number)
			#Show the correct portrait
			get_node("dialogue_node/portraits/"+saved_portrait).show()
		else: #the entry doesn't exist
			print("No record of a portrait for this message")
			#set selection to "none"
			get_node("portrait_options").select(0)
			portrait_choice = "None"
			#hide
	if triggertype == 2:   #message number change triggered it
		#for some reason, this keeps coming out as a 'real' number rather than an 'int'
		
		save_message_choice = int(last_msg_choice)
		save_portrait_choice = last_portrait_choice
		print("Last portrait choice...: "+str(last_portrait_choice))
		#Some code around here keeps overwriting lower numbered saved messages
		# which is super fucked up and totally needs fixing
		#Fixthisshitrightnow()
		
		#if this message exists, decode and put it in the editor box
		if (wholedic["script"][char_encoded][wherewhen_encoded]["0"].has(str(message_choice))):
			#update GUI
			changemessage_decoded = wholedic["script"][char_encoded][wherewhen_encoded]["0"][str(message_choice)]
			changemessage_decoded = changemessage_decoded.percent_decode()
			dialogue_editor.set_text(changemessage_decoded)  #put the loaded text into the editor
			
		else:   #if empty, set to blank
			dialogue_editor.set_text("")
			get_node("dialogue_node/dialogue_output").set_bbcode("") #it won't update to blank if you don't do this
			get_node("portrait_options").select(0)
		
		#Update portrait
		#Hide last portrait
		get_node("dialogue_node/portraits/"+last_portrait_choice).hide()
		#If the entry exists, load it up
		if wholedic["script"][char_encoded][wherewhen_encoded]["1"].has(str(message_choice)):
			saved_portrait = wholedic["script"][char_encoded][wherewhen_encoded]["1"][str(message_choice)]
			for node_matching_saved_portrait in range(0,get_node("dialogue_node/portraits").get_child_count()):
				if get_node("dialogue_node/portraits").get_child(node_matching_saved_portrait).get_name() == saved_portrait:
					saved_portrait_option_number = node_matching_saved_portrait
					break
				print("Coming through")
			#Set drop down menu for portrait selection to the saved selection
			get_node("portrait_options").select(saved_portrait_option_number)
			#Show the correct portrait
			get_node("dialogue_node/portraits/"+saved_portrait).show()
		else: #the entry doesn't exist
			print("No record of a portrait for this message")
			#set selection to "none"
			get_node("portrait_options").select(0)
			portrait_choice = "None"
		
	if triggertype == 3:   #it's a portrait choice
		#for saving
		save_portrait_choice = last_port_choice
		
		
	
	
	# save the message data at the end, so that the proper values are available, namely the timeplace
	# also cover the portrait
	#print("Data now saved under character: ", save_character_name,"  & time/place: ",save_timeplace_name)
	save_to_script(save_character_name,save_timeplace_name,"0",str(save_message_choice),edited_text) #overwrite last message with new last message
	save_to_script(save_character_name,save_timeplace_name,"1",str(save_message_choice),save_portrait_choice) #save portrait choice too
	if question_mode == true:
		save_answer1    = get_node("dialogue_node/answerboxes_node/answer1_text")
		save_answer2    = get_node("dialogue_node/answerboxes_node/answer2_text")
		save_answer3    = get_node("dialogue_node/answerboxes_node/answer3_text")
		save_answer4    = get_node("dialogue_node/answerboxes_node/answer4_text")
		save_to_script(save_character_name,save_timeplace_name,"2",save_message_choice,save_answer1)
		save_to_script(save_character_name,save_timeplace_name,"3",save_message_choice,save_answer2)
		save_to_script(save_character_name,save_timeplace_name,"4",save_message_choice,save_answer3)
		save_to_script(save_character_name,save_timeplace_name,"5",save_message_choice,save_answer4)

##############################
# Update the memory

#places any new data into the big dictionary, should fill up at the beginning & when changing attributes on the right of the frontend
#this was very stressful to make     update: this continues to pwn my brain
func save_to_script(character_name,timeplace_name,save_value_type,msg_slot,save_value):
	print("Value: \"",save_value, "\"  of type: ",save_value_type ," soon to be saved to this slot: ",str(msg_slot))
	message_encoded = save_value.percent_encode()
		#print("Message encoded (unless a portrait number): ",message_encoded)
	#checks every layer for dictionaries and creates them where necessary & changing the GUI to the proper values
	#NOTE: Use curly braces when using .has or other functions for dictionaries, but when looking up directly instead use brackets like normal... I know! Confusing!!
	   #in case the name has apostrophes, as they often do... so I will use percantage encoding
	character_encoded = character_name.percent_encode()
	if !( wholedic["script"].has(character_encoded) ):   #if it does not have this character, add the character key and time/place dictionary
		#set all GUIs to reflect any new data
		get_node("character_options").add_item(character_name) 
		wholedic["script"][character_encoded] = {}   #The index should contain percentage encoded character names... so we encode first and send it off
		#print("Added character: ", character_name)
		
	#Create place if it does not exist as well as all the data type dictionaries
	timeplace_encoded = timeplace_name.percent_encode()
	if !( wholedic["script"][character_encoded].has( timeplace_encoded ) ):   #If it does not have this  time/place, add it
		#Time & place must be updated only as characters change.
		wholedic["script"][character_encoded][timeplace_encoded] = {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{}}  #might as well add all these subdictionaries!
		#print("Added time or place (with data dictionaries): ",timeplace_name)
	
	if !( wholedic["script"][character_encoded][timeplace_encoded].has(save_value_type) ) :    #if it doesn't have that save value type... somehow
		print("Error!: The Time/Place dictionary is missing all of the value dictionaries! Resetting them...")
		wholedic["script"][character_encoded][timeplace_encoded] = {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{}}   #add them all in
		
	save_value = save_value.percent_encode()   #since all the data end types are strings, no check is needed and they can all be stored in pencent encoding
	msg_slot = str(msg_slot)
	#overwrite old message
	if !( wholedic["script"][character_encoded][timeplace_encoded][save_value_type].has(msg_slot) ):   #if there is no message like data here...
		wholedic["script"][character_encoded][timeplace_encoded][save_value_type][msg_slot] = message_encoded #save the new message
		
	else: #else there is data, but might as well just overwrite it
		wholedic["script"][character_encoded][timeplace_encoded][save_value_type] = {msg_slot:message_encoded} #finally, store the value
	
	#print("Added: ", save_value, " to dictionary: ", wholedic)
		
#########################################################################
#save everything to the JSON file
func save_data():

	#integrate current message into save data
	save_character_name = get_node("character_options").get_text()
	save_timeplace_name = get_node("timeplace_options").get_text()
	save_message_choice = get_node("messagenum_options").get_value()
	save_message        = get_node("dialogue_edit").get_text()
	
	#save current message
	save_to_script(save_character_name,save_timeplace_name,"0",str(save_message_choice),save_message)
	
	#if the question mode checkbox is checked, then save all the current answer data
	if question_mode == true:
		save_answer1    = get_node("dialogue_node/answerboxes_node/answer1_text")
		save_answer2    = get_node("dialogue_node/answerboxes_node/answer2_text")
		save_answer3    = get_node("dialogue_node/answerboxes_node/answer3_text")
		save_answer4    = get_node("dialogue_node/answerboxes_node/answer4_text")
		save_to_script(save_character_name,save_timeplace_name,"2",str(save_message_choice),save_answer1)
		save_to_script(save_character_name,save_timeplace_name,"3",str(save_message_choice),save_answer2)
		save_to_script(save_character_name,save_timeplace_name,"4",str(save_message_choice),save_answer3)
		save_to_script(save_character_name,save_timeplace_name,"5",str(save_message_choice),save_answer4)
	
	jsonfile = File.new()
	output_dir = Directory.new()
	#if !(output_dir.dir_exists("res://output/")):   #if the directory doesn't exist
	#	output_dir.make_dir("res://output/")  #then make it
		
	jsonfile.open("user://dialogue_data.json",File.WRITE)  
	jsonfile.store_string(wholedic.to_json()) #convert the data in memory to json format and put it in a string
	jsonfile.close()
	print("Database file saved.")


#initial loading of data from the JSON file
func load_data():
	
	#Explaining the layout of the "script" portion of the dictionary after it's created...
	#wholedic =   {"script"      { char_key : { wherewhen_key : {   mod_key : {         id_key : {}, id_key : {},      id_key:{},id_key:{},id_key:{},id_key:{} } } } }
	#              which listing   character    where/when          modify which dic    messages     portrait choice   answer1   ...2      ...3      ...4
	wholedic = {}   #initialize the dictionary which holds all data in mem
	jsonfile = File.new()
	if jsonfile.file_exists("user://dialogue_data.json"):
		################################################
		# Parse from JSON file into a master dictionary
		
		jsonfile.open("user://dialogue_data.json",File.READ)
		wholedic.parse_json(jsonfile.get_as_text())  #recover file into dictionary
		#print("Loaded this JSON:",jsonfile,"     into this dic: ",wholedic)
		jsonfile.close()
		
		
		#HACK, until .erase() works with JSON parsed dictionaries... I need to remake the whole dictionary
		wholedic = copy_dictionary(wholedic)
		
		#call function that tallies the portrait list into the GUI
		populate_portrait_lists()
		
		################################################  read all character entries to put in the GUI
		char_read_counter = 0  #initialize the character loop
		char_list = wholedic["script"].keys() #gnabs the character names
		while char_read_counter < char_list.size():  #put the names into the GUI options lists & the dictionary
			decoded_character_name = char_list[char_read_counter].percent_decode()
			get_node("character_options").add_item(decoded_character_name,char_read_counter)  #update GUI with each character entry
			
			char_read_counter += 1
		
		#go through each time/place in ONLY THE FIRST character's dictionary as that's what should be now selected
		#print(wholedic["script"])
		#update timeplace list
		
		get_node("character_options").select(0) #Selects the first entry for load up
		current_character = get_node("character_options").get_text()
		current_character = current_character.percent_encode()
		#timeplace_keys = char_list[0].keys()  #notice this also says zero, because this is load up! May it default to zero...
		timeplace_list = wholedic["script"][current_character].keys() #for current character, which is zero from above
		
		#pretty similar to above code, but will only list the first character's times/places
		# as this is an initial load state. This will change when you implement 
		timeplace_read_counter = 0
		while timeplace_read_counter < timeplace_list.size():
			decoded_timeplace_name = timeplace_list[timeplace_read_counter].percent_decode()
			#print("added new place: ", decoded_timeplace_name, " to character: ", char_list[0])
			print("  Added this location (auto-loaded): \"", decoded_timeplace_name,"\" from character: ", current_character)
			get_node("timeplace_options").add_item(decoded_timeplace_name,timeplace_read_counter)
			
			timeplace_read_counter += 1
		get_node("timeplace_options").select(0)   #reset it's selection
		
		################################################
		
		# Load loop for all of the messages, portrait names & answers
		char_read_counter = 0
		while char_read_counter < char_list.size():
			character_string = char_list[char_read_counter]
			character_decoded = character_string.percent_decode() #get those strings
			timeplace_list = wholedic["script"][character_string].keys() #gets the time/place names
			timeplace_read_counter = 0
			#print("Next character loading         : ",character_string)
			
			while timeplace_read_counter < timeplace_list.size():
				#update timeplace_string to reflect the subdictionary of that specific character
				timeplace_string = timeplace_list[timeplace_read_counter]
				timeplace_decoded = timeplace_string.percent_decode()
				
				#print("Next place loading         : ", timeplace_string)
				#print("It should be one of these : ", wholedic["script"][character_string].keys())
				
				options_counter = 0
				while options_counter < 6:  #go through each option until you get to portraits, the only one that needs to list out into the GUI
					# If the options dictionary doesn't exist, error. Otherwise carry on.
					if !( wholedic["script"][character_string][timeplace_string].has( str( options_counter ) ) ):
						print("Error!: Options data is missing! Should contain a dictionary for option number ", str(options_counter), " under here.")
					else:   
						message_read_counter = 0
						while message_read_counter <  ( wholedic["script"][character_string][timeplace_string][str(options_counter)].size() ):
							#print("Confirm, the main dictionary 'has' the option: ", wholedic["script"][character_string][timeplace_string][options_counter])
							
							if (wholedic["script"][character_string][timeplace_string][str(options_counter)].has(str(message_read_counter)) ): #if this message or data exists
								
								
								################################
								#go through each option
								if options_counter == 0: #if it's a message
									full_message = wholedic["script"][character_string][timeplace_string]["0"][str(message_read_counter)]
									formatted_message = full_message.percent_decode()   #formatted to work with the percentage encoding
									#print( "About to add message for character: ", character_decoded," & time/place: ", timeplace_decoded)
									
									if character_decoded == get_node("character_options").get_text():
										if timeplace_decoded == get_node("timeplace_options").get_text():
											if message_read_counter == get_node("messagenum_options").get_value():  #if it's the same entry as the message numberbox...
												dialogue_editor = get_node("dialogue_edit")
												dialogue_editor.set_text(formatted_message)  #put the loaded text into the editor
												#print("Set the dialogue editor to this message: ", formatted_message)
								
								if options_counter == 1: #if portrait
									#read from BOTTOM level list, the reference to what's saved
									portrait_load_choice = wholedic["script"][character_string][timeplace_string]["1"][str(message_read_counter)]  
									portrait_load_decoded = portrait_load_choice.percent_decode()
									
									
											
									if character_decoded == get_node("character_options").get_text(): #if it's in the same place as selected on startup...
										if timeplace_decoded == get_node("timeplace_options").get_text():
											if message_read_counter == get_node("messagenum_options").get_value():
												#LOOP to find the portrait's number
												portrait_load_loop = 0
												
												while portrait_load_loop < wholedic["portraits"].size():
													if wholedic["portraits"][str(portrait_load_loop)] == portrait_load_decoded:
														
														#TODO just make sure this works after messing with more things
														#set current portrait choice in the dropdown options
														get_node("portrait_options").select(portrait_load_loop) 
													#print("portrait load loop...: ",portrait_load_loop)
													portrait_load_loop += 1
								
								var current_answer_text
								var current_answer_decoded
								var current_answer_node
								#loads all current answers and put them into the answer sample textboxes
								if options_counter >= 2 && options_counter <= 5:
									
									current_answer_text = wholedic["script"][character_string][timeplace_string][str(options_counter)][str(message_read_counter)]
									current_answer_decoded = current_answer_text.percent_decode()
									
									#if same character, time/place & message as the currently selected... then load up the answers
									if character_decoded == get_node("character_options").get_text(): #if it's in the same place as selected on startup...
										if timeplace_decoded == get_node("timeplace_options").get_text():
											if message_read_counter == get_node("messagenum_options").get_value():
												current_answer_node = str("dialogue_node/answerboxes_node/answer"+str(options_counter - 1)+"_text")
												
												if (get_node(current_answer_node)):  #if the node exists...
													get_node(current_answer_node).set_bbcode(current_answer_decoded)
													print ("current answer loaded (from auto-load): ", current_answer_decoded)
													if options_counter == 2:   #only load current for the auto-load
														get_node("question_panel/answer_edit").set_text(current_answer_decoded)
							
							#taking these increments away kills the computer with infinite loops
							message_read_counter += 1
						options_counter += 1
				timeplace_read_counter += 1
			char_read_counter += 1
		char_list = wholedic.keys()
		#print("Character list after initial load", char_list)
		
		
		#select current portrait
		#select_current_portrait()
	
	#####################
	# If no file exists, it will default to inserting & showing the examples
	else:  
		wholedic = {"script":{},"portraits":{},"last edited":"0"} #initialize all the save data
		example_defaults()
		#print("no file portrait list test, should be empty: ",wholedic["portraits"])
		#call function that tallies the portrait list into the GUI
		populate_portrait_lists()
	
	
	#################### does the code below even do anything?
	
	#charcount = 0
	#charlist = wholedic.keys()
	#print("Keylist size: ",charlist.size())
	
	#also needs to load each character into the GUI list
	#while (charcount < charlist.size()):
	#	current_character = charlist[charcount]
	#	
	#	charcount += 1
		#load each location
		



####################################
# end of load_data



############################################
# Manually load in example code for testing purposes


func example_defaults():
	#TODO, make it so we can somehow keep a default sort by entry time, for not only this dictionary, but users as well
	#This here right below is just a cheap hack to get by, sacrificing some room to number them all
	example_character1 = "1: Demo-tan"     #all messages are segregated by a character dictionary
	example_c1_tp1 = "1: Virtual Realm"    #organized by the time or place dictionary
	example_c1_tp2 = "2: Thinking Room"
	
	example_c1_tp1_text1 = "This is an example text. \nThe bottom displays the example \nas it should look at 2x zoom."
	example_c1_tp1_text2 = "Text information is seperated not only by characters, \nbut their own locations/times as well."
	
	example_c1_tp2_text1 = "Am I supposed to show you the question example here?"
	example_answer1 = "I think so...?"
	example_answer2 = "Yes, this feature looks sufficient."
	example_answer3 = "Where's the action?!"
	example_answer4 = "Choices are handled in game code."   
	#only one question example for now because I'd have to manually type out each
	
	
	#Demo-kun exemplifies the effects of switching characters
	example_character2 = "2: Demo-kun"
	example_c2_tp1 = "1: Virtual Realm (closet)"
	example_c2_tp2 = "2: Earth (dining hall)"
	
	example_c2_tp1_text1 = "Questions are rather strained for size, so it is best to be succinct and use the preview to gauge how long the message is."
	example_c2_tp1_text2 = "If the answers are left blank it will stay in message mode, but for any that are filled, it will go into question mode. It will only display the answers you have filled out."
	example_c2_tp2_text1 = "For now portraits have to be added manually as nodes before compilation!\nLoading and saving portraits is not yet supported, but there are plans to change this."
	
	############################## portrait data
	
	example_c1_port1 = "demotan-helpful"   #are allowed an optional emotion/portrait/gesture/avatar/etc
	example_c1_port2 = "demotan-confused"  #to show switchable avatars, also appropriate for the question
	example_c2_port1 = "demokun-helpful"   
	example_c2_port2 = "demokun-relieved"
	
	
	#Save ALL that data to the main dictionary
	#mind you 'slot' has to remain a string even though it increments with numbers.
	#Type is an integer and refers to the index of the type of data, each of them all stored in dictionaries.
	#                       char            place      type   slot       data
	save_to_script(example_character1,example_c1_tp1,  "1",    "0",    example_c1_port1)   # 2 portraits, 3 texts & 4 answers equal 9 manual entries
	save_to_script(example_character1,example_c1_tp2,  "1",    "1",    example_c1_port2)
	
	save_to_script(example_character1,example_c1_tp1,  "0",    "0",    example_c1_tp1_text1)
	save_to_script(example_character1,example_c1_tp1,  "0",    "1",    example_c1_tp1_text2)  #since it's a different place, it's a different message dictionary being referred
	save_to_script(example_character1,example_c1_tp2,  "0",    "0",    example_c1_tp2_text1)  #which is why I did not increment to the slot number (and why doing this manually is probably easier)
	
	save_to_script(example_character1,example_c1_tp2,  "2",    "0",    example_answer1)  #all the answers are associated with the message dictionary
	save_to_script(example_character1,example_c1_tp2,  "3",    "0",    example_answer2)  #each answer has their own dictionary, hence why I do not change slots
	save_to_script(example_character1,example_c1_tp2,  "4",    "0",    example_answer3)  #their keys are to align with the question's keys to share the same slot number
	save_to_script(example_character1,example_c1_tp2,  "5",    "0",    example_answer4)
	
	save_to_script(example_character2,example_c2_tp1,  "1",    "0",    example_c2_port1)   #Demo-kun's info starts here
	save_to_script(example_character2,example_c2_tp2,  "1",    "1",    example_c2_port2)
	
	save_to_script(example_character2,example_c2_tp1,  "0",    "0",    example_c2_tp1_text1)
	save_to_script(example_character2,example_c2_tp1,  "0",    "1",    example_c2_tp1_text2)
	save_to_script(example_character2,example_c2_tp2,  "0",    "0",    example_c2_tp2_text1)
	
	
	#don't need to add most stuff to the GUI, save_to_script helps by doing that with each character, time/place & portrait entry
	get_node("dialogue_edit").set_text(example_c1_tp1_text1)   # only needs currently selected, updates according to the message selector
	#get_node("question_panel/answer_edit").set_text(example_answer1)   # same
	#set GUI to defaults
	get_node("character_options").select(0)   #select first example, aka encoded_example_name
	#set up the timeplace options only for the first character, as it was just force selected in the code above
	get_node("timeplace_options").clear()
	
	encoded_example_name = example_character1.percent_encode()
	timeplace_list = wholedic["script"][encoded_example_name].keys()
	timeplace_add_loop = 0
	while timeplace_add_loop < timeplace_list.size():
		current_timeplace_key = timeplace_list[timeplace_add_loop]
		print("  Added this location (Default addition) :", current_timeplace_key.percent_decode(),"   to character: ", encoded_example_name)
		get_node("timeplace_options").add_item( current_timeplace_key.percent_decode() )
		timeplace_add_loop += 1
	#set rest of GUI to defaults
	get_node("timeplace_options").select(0)
	get_node("messagenum_options").set_value(0)
	
	
	#print("After initial saving, the first time/place list looks like: ... ", timeplace_list)
	#finally save all those changes to the JSON file
	save_data()
	
	
######################### end of example_defaults

var save_message
var save_answer1
var save_answer2
var save_answer3
var save_answer4
var question_mode = false
#when either checking the question mode checkbox or switching between messages, immediately set focus to the answer editor box
func _on_question_checkbox_toggled( pressed ):
	if (pressed):
		get_node("question_checkbox").set_focus_mode(0)
		get_node("question_panel/answer_edit").grab_focus()
		question_mode == true
	else:
		get_node("question_panel/answer_edit").release_focus()
		question_mode == false

func _on_answer_options_item_selected( ID ):
	get_node("question_panel/answer_options").set_focus_mode(0)
	get_node("question_panel/answer_edit").grab_focus()
	


#######################################################################

func populate_portrait_lists():
	
	"""
	TODO change this code almost completely so it supports 
	files inside the 'portraits' folder.
	
	steps left:
	
	- Include default 'None'
	- obsoleces the need for a checkbox to disable/enable so get rid of that
	- put all valid portrait files in an array
	- populate the list using the file array
	
	not tested:
	create folder if it's not present
	"""
	
	var portrait_folder_path
	portrait_folder_path = ("res://portraits/")
	
	#Start up a directory stream so we can scan for the folder then scan for portrait files.
	var directory_stream = Directory.new()
	
	if (directory_stream.dir_exists(portrait_folder_path)):
		pass #good
	else: #If it can't find the portraits folder, it will create it
		directory_stream.make_dir("portraits")
		#Check to see if the creation worked
		if (directory_stream.dir_exists(portrait_folder_path)):
			print ("Created missing 'portraits' directory.")
		else:
			print ("Error!: Failed to create missing 'portraits' directory.")
			
	#End of portrait folder creation
	
	
	#Start scanning for files and organizing them in each list
	#Start up the directory stream for use with the portrait file scan
	directory_stream.change_dir(portrait_folder_path)
	directory_stream.list_dir_begin() #Alternatively: print ("Directory list stream beginning = "+str(directory_stream.list_dir_begin()))
	
	#initialize variables
	portrait_nodename_dic = {}  #for keeping track of names of each portrait's node
	wholedic["portraits"] = {}  #initialize the save list
	var current_portrait_file
	var current_portrait_node
	var encoded_portrait_name
	var portrait_file_list = [] #for keeping track of the file names of each portrait
	var portrait_file_counter = 0 #eh, easier than doing "portrait_nodename_dic.size()" everytime
	
	#Add the 'None' option which disables the portrait altogether.
	#This is an opportunity to explain what each of these lists keep track of.
	#Note: The 'None' option is not added to the portrait_file_list dictionary because
	# it is not associated with any texture file.
	#Add 'none' to the master dictionary/save file
	wholedic["portraits"]["0"] = "None"
	#Add 'none' to the portrait options
	get_node("portrait_options").add_item("None")
	#Create a sprite node
	current_portrait_node = Sprite.new()
	current_portrait_node.set_name("None")
	get_node("dialogue_node/portraits").add_child(current_portrait_node)
	#Add 'none' to the node name list so they can be referenced in code easily
	portrait_nodename_dic[0] = "None"
	#Note: Would normally set a texture here, if "None" had one, but it does not.
	#current_portrait_node.set_texture("res:///portraits/"+"None")
	#Note: Would normally adjust coords, if needed
	#Note: Would normally hide the resulting texture as it's not necessarily the currently
	#  chosen one option (but "None" is the default case, so it should be that)
	
	while (true): #Keep reading files until there's no more, then break.
		#gotta break out of this one, list_dir_begin returns "false" 
		#as it stands and may change.
		
		current_portrait_file = directory_stream.get_next()
		#print("Current portrait file being processed: "+current_portrait_file)
		
		#Reached end of file list
		if current_portrait_file == "": #Directory stream gives this when out of files
			directory_stream.list_dir_end()
			print("All portrait files have been processed.")
			break
			
		#Confirmed new portrait, add to lists
		#Use match so you can compare using wildcard asterisks (*)
		if (current_portrait_file.match("*.png")):
			
			#Add each to portrait_file_list
			portrait_file_list.append(current_portrait_file)
			#Encode & then add 'none' to the master dictionary/save file (+1 because "None" is in this list
			#  yet takes no part in the file counter)
			encoded_portrait_name = current_portrait_file.percent_encode()
			wholedic["portraits"][str(portrait_file_counter+1)] = encoded_portrait_name
			#Add 'none' to the portrait options
			get_node("portrait_options").add_item(current_portrait_file)
			#Create a sprite node.
			current_portrait_node = Sprite.new()
			current_portrait_node.set_name(current_portrait_file)
			get_node("dialogue_node/portraits").add_child(current_portrait_node)
			#Add each to the nodename_dic (+1 because None is in this same list, but 
			#  doesn't take part of the file counter)
			portrait_nodename_dic[portrait_file_counter+1] = current_portrait_file
			#Set the texture into the new sprite node
			current_portrait_node.set_texture(load("res:///portraits/"+current_portrait_file))
			#Adjust coords? Should be in place based on the parent node... so do nothing?
			#Hide it on completion
			current_portrait_node.hide()
			portrait_file_counter = portrait_file_counter + 1
			
			
		#Most likely a non-portrait file, such as the instructions text
		#TODO make a case for if a .gif, .jpg or any other file formats are found and
		#  raise a dialogue box explaining the user's error
		else:
			print("Invalid portrait file detected: "+str(current_portrait_file)+" .")
		
	print("Results: "+str(portrait_nodename_dic))
	
#############################################################################




########################### add/remove time/place functions

func update_portrait():
	#Hide last portrait
	get_node("dialogue_node/portraits/"+last_portrait_choice).hide()
	#Figure out the option number that matches the portrait selection saved
	#"1" being where the portrait info is stored.
	#"0" being the first message. Since it's a character change it will reset to the first.
	#If the entry exists, load it up
	if wholedic["script"][char_encoded][wherewhen_encoded]["1"].has("0"):
		saved_portrait = wholedic["script"][char_encoded][wherewhen_encoded]["1"]["0"]
		for node_matching_saved_portrait in range(0,get_node("dialogue_node/portraits").get_child_count()):
			if get_node("dialogue_node/portraits").get_child(node_matching_saved_portrait).get_name() == saved_portrait:
				saved_portrait_option_number = node_matching_saved_portrait
				break
			#print("Really? It works? I'm still not certain.")
		#Set drop down menu for portrait selection to the saved selection
		get_node("portrait_options").select(saved_portrait_option_number)
		#Show the correct portrait
		get_node("dialogue_node/portraits/"+saved_portrait).show()
	else: #the entry doesn't exist
		print("No record of a portrait for this message")
		#set selection to "none"
		get_node("portrait_options").select(0)
		portrait_choice = "None"


func _on_add_timeplace_button_pressed():
	get_node("focus_panel").show()
	get_node("add_timeplace_button").set_focus_mode(0)  #gets rid of button focus so spaces and enter from the line edit node doesn't press the button again
	get_node("new_timeplace_popup").show()
	get_node("new_timeplace_popup/new_timeplace_addition_edit").clear()
	get_node("new_timeplace_popup/new_timeplace_addition_edit").grab_focus()
	add_timeplace_mode = true

func _on_new_timeplace_addition_edit_text_entered( text ):
	add_timeplace()

func add_timeplace():
	current_character = get_node("character_options").get_text()
	encoded_character_name = current_character.percent_encode()
	get_node("focus_panel").hide()
	get_node("new_timeplace_popup/add_timeplace_confirm_button").set_focus_mode(0)  #gets rid of button focus
	get_node("new_timeplace_popup").hide()
	
	newtimeplace = get_node("new_timeplace_popup/new_timeplace_addition_edit").get_text()
	newtimeplace = newtimeplace.percent_encode()
	# add character and (so it doesn't crash) default time/place to the GUI list
	wholedic["script"][encoded_character_name][newtimeplace] =  {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{}}
	print("New character added, here's the full script: ",wholedic["script"])
	
	#add to GUI
	get_node("timeplace_options").add_item(newtimeplace.percent_decode())
	#select it
	item_loop = 0
	while item_loop < get_node("timeplace_options").get_item_count():
		if get_node("timeplace_options").get_item_text(item_loop) == newtimeplace.percent_decode():
			get_node("timeplace_options").select(item_loop)
		item_loop += 1
		
	#clear out the editable text and replace it with instructions
	get_node("dialogue_edit").set_text("Okay, I will now have something to say in "+newtimeplace.percent_decode()+".")
	
	excused_change = true
	add_timeplace_mode = false
	
	
func cancel_add_timeplace():
	get_node("focus_panel").hide()
	get_node("new_timeplace_popup/add_cancel_button").set_focus_mode(0)  #no cancel button focus when returning (just in case I guess)
	get_node("new_timeplace_popup").hide()
	add_character_mode = false

func _on_sub_timeplace_button_pressed():
	
	dialogue_editor = get_node("dialogue_edit")
	
	current_character_name = get_node("character_options").get_text()
	encoded_character_name = current_character_name.percent_encode()
	
	current_timeplace_name = get_node("timeplace_options").get_text()
	encoded_timeplace_name = current_timeplace_name.percent_encode()
	print("Time/place to delete: ",current_timeplace_name)
	
	#remove item from the dictionary
	#TODO: when the bug upstream is fixed get rid of the commands higher up that don't work with a bare dictionary parsed from a JSON file. .erase() is one such command that will not work as well as .clear().
	#wholedic["script"][encoded_character_name].erase(encoded_timeplace_name)
	wholedic["script"][encoded_character_name].erase(encoded_timeplace_name)
	if wholedic["script"][encoded_character_name].has(encoded_timeplace_name):
		print("Despite erasure, it contains the (encoded) time/place "+encoded_timeplace_name+" still!")
		print("The whole script: ",wholedic["script"])
	else:
		print("Successful erasure.")
		
	#clear the time/place GUI list out and then refill it so that the ranking is reset
	get_node("timeplace_options").clear()
	for timeplace_loop in wholedic["script"][encoded_character_name]:   #makes timeplace loop through each time/place that is under this characters dictionary
		get_node("timeplace_options").add_item(timeplace_loop.percent_decode())
	
	#get_node("timeplace_options").select(0)
	newly_selected_timeplace = get_node("timeplace_options").get_text()
	print("newly selected time/place: ",newly_selected_timeplace)
	
	
	get_node("messagenum_options").set_value(0)                   # specifying...   data slot & msg num  
	changemessage_decoded = wholedic["script"][encoded_character_name][newly_selected_timeplace.percent_encode()]["0"]["0"]
	changemessage_decoded = changemessage_decoded.percent_decode()
	dialogue_editor.set_text(changemessage_decoded)  #put the loaded text into the editor
	
	excused_change = true # so as not to trigger the character change thereby saving the last character (the just deleted one! Do not want!)




########################### end of add/remove time/place functions


# add/remove character functions
func _on_add_character_button_pressed():
	get_node("focus_panel").show()
	get_node("add_character_button").set_focus_mode(0)  #gets rid of button focus so space and enter don't interact with it anymore
	get_node("new_character_popup").show()
	get_node("new_character_popup/new_character_addition_edit").clear()
	get_node("new_character_popup/new_character_addition_edit").grab_focus()
	add_character_mode = true
	
func _on_new_character_addition_edit_text_entered( text ):
	add_character()
	
	
func add_character():
	get_node("focus_panel").hide()
	get_node("new_character_popup/add_char_confirm_button").set_focus_mode(0)  #gets rid of button focus
	get_node("new_character_popup").hide()
	
	newname = get_node("new_character_popup/new_character_addition_edit").get_text()
	newname = newname.percent_encode()
	# add character and (so it doesn't crash) default time/place to the GUI list
	wholedic["script"][newname] = {}
	wholedic["script"][newname]["Wherever"] = {"0":{},"1":{},"2":{},"3":{},"4":{},"5":{}}
	print("New character added, here's the full script: ",wholedic["script"])
	
	#add to GUI
	get_node("character_options").add_item(newname.percent_decode())
	#reset time/place list then add in the wherever
	get_node("timeplace_options").clear()
	get_node("timeplace_options").add_item("Wherever")
	get_node("timeplace_options").select(0)
	#select it
	item_loop = 0
	while item_loop < get_node("character_options").get_item_count():
		if get_node("character_options").get_item_text(item_loop) == newname.percent_decode():
			get_node("character_options").select(item_loop)
		item_loop += 1
		
	#clear out the editable text and replace it with instructions
	get_node("dialogue_edit").set_text("For every character added, there needs to be at least one time/place available.")
	
	excused_change = true
	add_character_mode = false

func cancel_add_character():
	get_node("focus_panel").hide()
	get_node("new_character_popup/add_char_cancel_button").set_focus_mode(0)  #no cancel button focus when returning
	get_node("new_character_popup").hide()
	add_character_mode = false



func _on_sub_character_button_pressed():
	current_character_name = get_node("character_options").get_text()
	dialogue_editor = get_node("dialogue_edit")
	encoded_character_name = current_character_name.percent_encode()
	print("Character to delete: ",encoded_character_name)
	
	
	#remove item from the dictionary
	#TODO: upstream bug, maybe modify when fixed
	#wholedic["script"].erase(encoded_character_name)
	wholedic["script"].erase(encoded_character_name)
	if wholedic["script"].has(encoded_character_name):
		print("It has the name still!")
		print("The whole script: ",wholedic["script"])
	else:
		print("Successful erasure.")
		
	#clear the GUI list out and refill character list
	get_node("character_options").clear()
	for character_loop in wholedic["script"]:
		get_node("character_options").add_item(character_loop.percent_decode())
	
	
	#get_node("character_options").select(0)
	newly_selected_name = get_node("character_options").get_text()
	print("newly selected name: ",newly_selected_name)
	#empty out the times/places, they change as characters change
	get_node("timeplace_options").clear()
	
	
	timeplace_list = wholedic["script"][newly_selected_name.percent_encode()].keys()
	#add times & places for the newly selected character
	#do while less than the total size of the recorded times/places for this character
	timeplace_add_loop = 0
	while timeplace_add_loop < wholedic["script"][newly_selected_name.percent_encode()].size():
		current_timeplace_key = timeplace_list[timeplace_add_loop]
		
		get_node("timeplace_options").add_item( current_timeplace_key.percent_decode() )
		print("  Added this location (on character removal): \"", current_timeplace_key.percent_decode(),"\" from character: ", char_selection)
		timeplace_add_loop += 1
	#choose first in the list, somewhat important:
	get_node("timeplace_options").select(0)
	
	wherewhen_encoded = timeplace_list[0]
	get_node("messagenum_options").set_value(0)
	changemessage_decoded = wholedic["script"][newly_selected_name.percent_encode()][wherewhen_encoded]["0"]["0"]
	changemessage_decoded = changemessage_decoded.percent_decode()
	dialogue_editor.set_text(changemessage_decoded)  #put the loaded text into the editor
	
	excused_change = true # so as not to trigger the character change thereby saving the last character (the just deleted one! Do not want!)

################# end of character add/remove functions



func _notification(cur_notif):
	#print("Okay what notification do you have for me?: ",cur_notif)
	if (cur_notif==MainLoop.NOTIFICATION_WM_QUIT_REQUEST):    #on user quit...
		print("Successful quit.")
		save_data()
		get_tree().quit()
		
		



