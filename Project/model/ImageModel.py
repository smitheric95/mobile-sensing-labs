#!/usr/bin/env python
# coding: utf-8

# In[46]:


import pandas as pd
import numpy as np
from numpy import array
from sklearn import metrics as mt
from keras.preprocessing.image import ImageDataGenerator
from matplotlib import pyplot as plt
from keras.layers import Reshape
from sklearn.preprocessing import LabelBinarizer
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras.models import Sequential
from keras.models import load_model
import random
import h5py


# In[84]:


#Example of cade to load the data generated from hdf5
hdf5_f = h5py.File("./Data/characters_all_64x64.hdf5", mode='r')

X = hdf5_f["X_train_aug"]
y = hdf5_f["y_train_aug"]
# print(X.shape, y.shape)
X_train = np.copy(X)
y_train = np.copy(y)

X = hdf5_f["X_test_aug"]
y = hdf5_f["y_test_aug"]
# print(X.shape, y.shape)
X_test = np.copy(X)
y_test = np.copy(y)

hdf5_f.close()

print("loaded data")

# Flip close brackets to produce open brackets

# In[86]:


# find close brackets
close_bracket_indices = list(np.where(y_train == ord(']'))[0])

# take random sample
random.shuffle(close_bracket_indices)
close_bracket_indices = close_bracket_indices[:int(len(close_bracket_indices)/2)]

for i in close_bracket_indices:
    X_train[i] = np.fliplr(X_train[i])
    y_train[i] = ord('[')
    
    
# find close brackets
close_bracket_indices = list(np.where(y_test == ord(']'))[0])

# take random sample
random.shuffle(close_bracket_indices)
close_bracket_indices = close_bracket_indices[:int(len(close_bracket_indices)/2)]

for i in close_bracket_indices:
    X_test[i] = np.fliplr(X_train[i])
    y_test[i] = ord('[')    


# In[87]:


one_hot = LabelBinarizer()
y_train_ohe = one_hot.fit_transform(y_train)
y_test_ohe = one_hot.fit_transform(y_test)
y_train_ohe.shape


# In[88]:


classes = [chr(x) for x in sorted(set(y_test))]


# In[89]:


img_wh = 64
NUM_CLASSES = len(classes)


# In[90]:


# Convert to channels last

# In[91]:



X_train = np.transpose(X_train, (0,2,3,1))
X_test = np.transpose(X_test, (0,2,3,1))

# normalize from 0 to 1
X_train = (X_train - X_train.min())/(X_train.max() - X_train.min())
X_test = (X_test - X_test.min())/(X_test.max() - X_test.min())

# In[92]:



# In[93]:


datagen = ImageDataGenerator(featurewise_center=False,
    samplewise_center=False,
    featurewise_std_normalization=False,
    samplewise_std_normalization=False,
    zca_whitening=False,
    rotation_range=5, # used, Int. Degree range for random rotations.
    width_shift_range=0.1, # used, Float (fraction of total width). Range for random horizontal shifts.
    height_shift_range=0.1, # used,  Float (fraction of total height). Range for random vertical shifts.
    shear_range=0., # Float. Shear Intensity (Shear angle in counter-clockwise direction as radians)
    zoom_range=0.,
    channel_shift_range=0.,
    fill_mode='nearest',
    cval=0.,
    horizontal_flip=False,
    vertical_flip=False,
    rescale=None,
    data_format="channels_last")

datagen.fit(X_train)

print("generator finished")
# In[94]:


cnn = Sequential()
cnn.add(Conv2D(filters=32,
                input_shape = (img_wh,img_wh, 1),
                kernel_size=(3,3), 
                padding='same', 
                activation='relu')) # more compact syntax

cnn.add(Conv2D(filters=64,
                kernel_size=(3,3), 
                padding='same', 
                activation='relu')) # more compact syntax
cnn.add(MaxPooling2D(pool_size=(2, 2), data_format="channels_last"))
    

# add one layer on flattened output
cnn.add(Dropout(0.25)) # add some dropout for regularization after conv layers
cnn.add(Flatten())
cnn.add(Dense(128, activation='relu'))
cnn.add(Dropout(0.5)) # add some dropout for regularization, again!
cnn.add(Dense(NUM_CLASSES, activation='softmax'))

# cnn.summary()


# In[97]:


# Let's train the model 
cnn.compile(loss='categorical_crossentropy', # 'categorical_crossentropy' 'mean_squared_error'
              optimizer='rmsprop', # 'adadelta' 'rmsprop'
              metrics=['accuracy'])

# the flow method yields batches of images indefinitely, with the given transformations
cnn.fit_generator(datagen.flow(X_train, y_train_ohe, batch_size=128), 
                   steps_per_epoch=int(len(X_train)/1024), # how many generators to go through per epoch
                   epochs=2000,verbose=2,
                   validation_data=(X_test, y_test_ohe)
                  )


# In[121]:



# In[122]:



# In[123]:


# save model to disk
cnn.save('cnn_2000.h5')


# ----

# _____________

# Import model from disk:

# In[125]:



# In[129]:



# In[ ]:




