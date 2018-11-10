import cv2
import numpy as np
from matplotlib import pyplot as plt

# helper function for sorting sub images by X value
def sort_list(list1, list2):
    zipped_pairs = zip(list2, list1)
    z = [x for _, x in sorted(zipped_pairs)]

    return z


"""
input: path to image file
output: a unique image for each character detected in an image
"""
def get_split_images(image_full_path):
    with open(image_full_path, 'rb') as img_stream:
        file_bytes = np.asarray(bytearray(img_stream.read()), dtype=np.uint8)
        im = cv2.imdecode(np.fromstring(file_bytes,dtype=np.uint8),cv2.IMREAD_COLOR)
        # im = cv2.imread(image,0)
    
        # im = cv2.imdecode(np.frombuffer(image,dtype=np.uint8),0)
    
        imgray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY) # convert to greyscale
    
        # detect contours
        ret,thresh = cv2.threshold(imgray,127,255,0)
        im2, contours, hierarchy = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    
        output_contours = []
        output_hierarchy = []
        output_xs = []
    
        # for each contour found
        for i, contour in enumerate(contours):
    
            # get rectangle bounding contour
            [x,y,w,h] = cv2.boundingRect(contour)
    
            # discard areas that are too large
            if h > 300 and w > 300:
                continue
    
            # discard areas that are too small
            if h < 40 or w < 40:
                continue
    
            roi = im[y:y + h, x:x + w]
    
            # store the character's image, its hierarchy, and its X value
            output_contours.append(roi)
            output_hierarchy.append(hierarchy[0,i,3])
            output_xs.append(x)
    
    
        # sort contours by X values
        output_contours = sort_list(output_contours, output_xs)
        output_hierarchy = sort_list(output_hierarchy, output_xs)
    
        # find the top level contour
        min_hierarchy = min(output_hierarchy)
    
        result = []
        # output contours that are on the top level
        for i in range(len(output_contours)):
            if output_hierarchy[i] == min_hierarchy:
                # cv2.imwrite(str(i) + '.jpg', output_contours[i])
                b, g, r = cv2.split(output_contours[i])
                a = np.ones(b.shape, dtype=b.dtype) * 50

                final_img = cv2.merge((b, g, r))
                
                final_img = cv2.normalize(final_img, None, alpha = 0, beta = 1, norm_type = cv2.NORM_MINMAX, dtype = cv2.CV_32F)
                
                final_img = cv2.resize(final_img,(50,50))
            
                final_img = cv2.cvtColor(final_img,cv2.COLOR_BGR2GRAY)

                result.append(np.expand_dims(np.expand_dims(final_img,axis=-1),axis=0))
    
        return result