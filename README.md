# squeaker
Squeaker is an open-source Dialogue Editor made in Godot script for use in low-resolution games.

----------

This project is very incomplete!
It is not recommended you use this for any production or even recreational purposes.

It is just here because I spent a lot of time making it.
As it stands though, I will likely start over as the output format is completely incorrect. There are also a number of things I would rather improve on from a fundamental design standpoint.
One problem I did not forsee is that the format it should output to should be in a spreadsheet form. This is because Godot reads translation files in such a manner.
I developed this with the intent to use it back in Godot. I think it is of upmost importance that my dialogue data be compatible with the translation functions that Godot provides. Instead I wrote it to save to percentage encoded JSON. I could just use that as a save format and have the option to output to spreadsheets. I just don't know if it's wiser to fix or start over at this point to do that is all.

----------

Currently not working:
- When changing messages or the time/place, the portrait saved does not load
- Answer data does not save or load correctly yet

High priority BUGs & TODO

- load portrait saved on character choice switch
- load portrait saved on time/place choice switch
- load answers on character choice switch
- load answers on time/place choice switch
- load answers on message choice switch
- load answer on answer choice switch (proper!!)
- Save answer as answer choice is switched
- Save answers when the message is switched
- Save answers on quit
- Dialogue data output that's spreadsheet compatible
