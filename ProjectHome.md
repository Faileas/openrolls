An addon that is meant to simplify distribution of loot that typically falls outside of normal loot rolls.  Examples would include BoE greens that get distributed randomly, passing unneeded loot to a designated disenchanter, and sending items to the guild banker.

To date, there is only one command: /openroll 

&lt;item&gt;

 

&lt;quantity&gt;

  which begins a 30 second roll on 

&lt;item&gt;

.

When looting, items eligable for master looting will pop up a window with the distribution options.

"Raid" performs a raid roll, giving the item to a random eligible member

"Open" performs an open roll, the same as the above chat command.  The duration of this roll is variable, and is set by the input box next to the "Open" button

"Bank" passes the item to the designated Banker; this player is set on the input box above the main loot window.  If the box is left blank, nothing happens.

"Disenchant" passes the item to the designated disenchante; this player is set on the input box above the main loot window.  If the box is left blank, nothing happens.

"Award" passes the item to the player indicated by the box next to the button.

There are a few configuration options, all accessable through the Blizzard options menu.

The default behavior has a 25 second period where nothing is output.  At the end of that period, anybody who has not rolled yet is printed to chat.  Following that, a 5 second countdown commences.

Example:

t=0 Begin roll on 1x[Prismatic Shard](Large.md)
t=8 Dawna rolls 55 [- 100](1.md)
t=23 Thugger rolls 1 [- 100](1.md)
t=25 The following players have not rolled:
t=25    Raam
t=25    Faileas
t=25 5
t=26 4
t=27 3
t=28 2
t=29 1
t=30 0
t=30 Dawna rolled a 55
t=30 Thugger rolled a 1
t=30 Dawna wins 1x[Prismatic Shard](Large.md)