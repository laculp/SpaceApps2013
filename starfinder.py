import pyfits
import numpy
import scipy
import matplotlib.pyplot as plt
import sys
import urllib as url
import string as str

##outputname = "star_list_SNR7_dakota.txt"
##filepath = 'ISS030-E-53334_small.fit'
##
## NOTE: Pixel size for 28mm lens on Nikon D3S: 62.17" per pixel;   FOV: 3919.5 x 2783.8' = 65.325 x 46.397 degrees'
##
##print pyfits.open(filepath)[0].header
##data = pyfits.getdata(filepath)
##
##print len(data)
##print len(data[0])
##
##text_file = open(outputname, "w")
##
##avg_bg_box_size = 4
##
##fwhm_box_size = 1
##
##threshold_SNR = 9.
##
##for x in range(avg_bg_box_size, len(data)-avg_bg_box_size):
##	print x
##	for y in range(avg_bg_box_size, len(data[0])-avg_bg_box_size):
##		avg_bg_box = []
##		for i in range(-avg_bg_box_size, avg_bg_box_size):
##			for j in range(-avg_bg_box_size, avg_bg_box_size):
##				avg_bg_box.append(data[x+i][y+j])
##		avg_bg = numpy.median(avg_bg_box)
##		fwhm_box = []
##		for i in range(-fwhm_box_size, fwhm_box_size):
##			for j in range(-fwhm_box_size, fwhm_box_size):
##				fwhm_box.append(data[x+i][y+j])
##		avg_fwhm = numpy.mean(fwhm_box)
##		if avg_fwhm > threshold_SNR*avg_bg:
##			print "found a star!"
##			print >> text_file, x-1, y-1
##
##text_file.close()

outputname = "star_list_SNR7_dakota.txt"
filepath = 'ISS030-E-53334_small.fit'

# NOTE: Pixel size for 28mm lens on Nikon D3S: 62.17" per pixel;   FOV: 3919.5 x 2783.8' = 65.325 x 46.397 degrees'

print pyfits.open(filepath)[0].header
data = pyfits.getdata(filepath)

star_list = numpy.genfromtxt("star_list_SNR7_dakota.txt")

star_list_x = []
star_list_y = []

for n in range(len(star_list)):
        star_list_x.append(star_list[n][1])
        star_list_y.append(star_list[n][0])
			
plt.figure()
plt.imshow(data, cmap=plt.cm.gray_r)
plt.colorbar()
plt.scatter(star_list_x, star_list_y, edgecolors = 'r')
plt.show()


