* README.txt for Robotics Final Project
* Path Planning For Disc Robot
* Melissa Lopez & Eshan Saran
*
* Last Updated: Thursday, May 11

To run: type "GUI" into the Command Window in MATLAB, and the interface
will appear. To interact with the interface, the program will take a text
file in the form "envX.txt", where X is a number 0-4, for which we have
provided sample environment files.

Once an environment has been selected, the user may show the environment,
show the subdivisions made by the SSS algorithms, then display the path
taken by the robot.

What has not been fully implemented yet is the version of the SSS algorithm
that classifies boxes based on the presence of the Voronoi diagram.

* Some notes about each environment:
* env0.txt: works well, just takes quite a bit of time to find the path
  (approximately 2 minutes)
* env1.txt: no path
* env2.txt: start is not free
* env3.txt: works well, fairly quick
* env4.txt: easiest case with one obstacle