import pyfits
import numpy
import scipy
import matplotlib.pyplot as plt
import sys
import urllib as url
import string as str

# NOTE: Pixel size for 28mm lens on Nikon D3S: 62.17" per pixel; FOV: 3919.5 x 2783.8' = 65.325 x 46.397 degrees'

def x_transform(ra, dec, ra0, dec0):
	x = -(numpy.cos(dec)*numpy.sin(ra-ra0))/(numpy.cos(dec0)*numpy.cos(dec)*numpy.cos(ra-ra0)+numpy.sin(dec)*numpy.sin(dec0))*(3454./0.018)
	return (x)

def y_transform(ra, dec, ra0, dec0):
	y = (numpy.sin(dec0)*numpy.cos(dec)*numpy.cos(ra-ra0)-numpy.cos(dec0)*numpy.sin(dec))/(numpy.cos(dec0)*numpy.cos(dec)*numpy.cos(ra-ra0)+numpy.sin(dec)*numpy.sin(dec0))*(3454./0.018)
	return (y)

#RA ranges from 0-24 h, dec ranges from -90 to +90 deg
# convert everything to degrees, then back to RA/dec coords

#Resolution of search given below

star_database = numpy.genfromtxt("bright_star_coords.txt")
reduced_data = numpy.genfromtxt("reduced_star_list.txt")

output = open("residuals", "w")

RA_steps = 40
DEC_steps = 20
theta_steps = 20

pi = 3.14159265359

RA_grid = numpy.linspace(0., 360., RA_steps)
DEC_grid = numpy.linspace(-90., 90., DEC_steps)
theta_grid = numpy.linspace(0., 2.*pi, theta_steps)

# centre of Nikon D3S frame:
x0 = 2128.
y0 = 1416.

#focal length and pixel size in mm:
f = 28.
p = 0.00845

total_soln_vector = []

for n in range(len(RA_grid)):
	print n
	for m in range(len(DEC_grid)):
		for h in range(len(theta_grid)):
			database_starlist_inframe = []
			for i in range(len(star_database)):
				ra_rad_star = pi/180.*15.*(star_database[i][0]+star_database[i][1]/60.+star_database[i][2]/3600.)
				dec_rad_star = pi/180.*star_database[i][3]+star_database[i][4]/60.+star_database[i][5]/3600.
				
				ra_rad_center = pi/180.*RA_grid[n]
				dec_rad_center = pi/180.*DEC_grid[m]

				#unscaled coordinates:
				X_star_unscaled = x_transform(ra_rad_star, dec_rad_star, ra_rad_center, dec_rad_center)
				Y_star_unscaled = y_transform(ra_rad_star, dec_rad_star, ra_rad_center, dec_rad_center)

				#scaled and rotated coordinates:
				x_star = f/p*(X_star_unscaled*numpy.cos(theta_grid[h])-Y_star_unscaled*numpy.sin(theta_grid[h])) + x0
				y_star = f/p*(X_star_unscaled*numpy.sin(theta_grid[h])+Y_star_unscaled*numpy.cos(theta_grid[h])) + y0

				if x_star <= 2.*x0 and y_star <= 2.*y0: # the following is reversed; fix this later (although it doesnt really matter; just a definition of theta
					database_starlist_inframe.append([y_star, x_star])

			distance_sum = 0.
			for j in range(len(reduced_data)):
				distances = []
				for k in range(len(database_starlist_inframe)):
					distances.append((reduced_data[j][0]-database_starlist_inframe[k][0])**2.+(reduced_data[j][1]-database_starlist_inframe[k][1])**2.)
				nearest_distance = numpy.amin(distances)
				distance_sum+=nearest_distance
			total_soln_vector.append(distance_sum)
			print >> output, RA_grid[n], DEC_grid[m], theta_grid[h], distance_sum
print "minimized residual is", numpy.amin(total_soln_vector)
