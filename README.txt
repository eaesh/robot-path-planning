4/27/2017
Homework 4 - Intro to Robotics
Melissa Lopez
es3990
No other sources have been consulted
This writeup is my own work alone, referencing only the sources described in the SOURCE STATEMENT above. Electronically Signed: Eshan Saran

Use the test() functions at the bottom of each file to test functionality of specific methods
within the file. Otherwise run SSS.test(), which by default sets up the Environment using the
'env0.txt' file. The default file can manually be changed within that test() function or
via the new setup option. When the correct Environment is set up, press '1' to run the mainloop
which finds the FREE Start and Goal boxes, finds a clear path between the two configurations, 
and animates the path for the robots to take.

*** Please ignore the findPath(), DFS(), findPath2(), and DFS2() functions within Subdiv2.m
They are experimental methods to search for a path, however the only one that works is the 
BFS() function.