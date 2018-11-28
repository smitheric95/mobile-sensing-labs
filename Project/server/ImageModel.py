#!/usr/bin/env python

import pandas as pd
import numpy as np
from numpy import array
from skimage.io import imshow
from sklearn import metrics as mt
from keras.preprocessing.image import ImageDataGenerator
from matplotlib import pyplot as plt
from keras.layers import Reshape
from sklearn.preprocessing import LabelBinarizer
from keras.layers import Dense, Dropout, Activation, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras.models import Sequential
import seaborn as sns
from keras.models import load_model
import h5py


img_wh = 64
NUM_CLASSES = 88


# load the data generated from hdf5
hdf5_f = h5py.File("characters_all_64x64.hdf5", mode='r')

X = hdf5_f["X_train_aug"]
y = hdf5_f["y_train_aug"]

X_train = np.copy(X)
y_train = np.copy(y)

X = hdf5_f["X_test_aug"]
y = hdf5_f["y_test_aug"]

X_test = np.copy(X)
y_test = np.copy(y)

hdf5_f.close()


# one hot encode stuff
one_hot = LabelBinarizer()
y_train_ohe = one_hot.fit_transform(y_train)
y_test_ohe = one_hot.fit_transform(y_test)


# generate a list of classes
classes = [chr(x) for x in sorted(set(y_test))]

# image generator
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
    data_format="channels_first")

datagen.fit(X_train)


cnn = Sequential()
cnn.add(Conv2D(filters=32,
                input_shape = (1, img_wh,img_wh),
                kernel_size=(3,3), 
                padding='same', 
                activation='relu')) # more compact syntax

cnn.add(Conv2D(filters=64,
                kernel_size=(3,3), 
                padding='same', 
                activation='relu')) # more compact syntax
cnn.add(MaxPooling2D(pool_size=(2, 2), data_format="channels_first"))
    

# add one layer on flattened output
cnn.add(Dropout(0.25)) # add some dropout for regularization after conv layers
cnn.add(Flatten())
cnn.add(Dense(128, activation='relu'))
cnn.add(Dropout(0.5)) # add some dropout for regularization, again!
cnn.add(Dense(NUM_CLASSES, activation='softmax'))



# Let's train the model 
cnn.compile(loss='categorical_crossentropy', # 'categorical_crossentropy' 'mean_squared_error'
              optimizer='rmsprop', # 'adadelta' 'rmsprop'
              metrics=['accuracy'])

# the flow method yields batches of images indefinitely, with the given transformations
cnn.fit_generator(datagen.flow(X_train, y_train_ohe, batch_size=128), 
                   steps_per_epoch=int(len(X_train)/1024), # how many generators to go through per epoch
                   epochs=250, verbose=5,
                   validation_data=(X_test, y_test_ohe)
                  )


# generate confusion matrix
def summarize_net(net, X_test, y_test, title_text=''):
    plt.figure(figsize=(70,30))
    plt.rcParams.update({'font.size': 12})
    yhat = np.argmax(net.predict(X_test), axis=1)
    acc = mt.accuracy_score(y_test,yhat)
    cm = mt.confusion_matrix(y_test,yhat)
    cm = cm/np.sum(cm,axis=1)[:,np.newaxis]
    sns.heatmap(cm, annot=True, fmt='.2f', xticklabels=classes, yticklabels=classes)
    plt.title(title_text+'{:.4f}'.format(acc))
    plt.savefig('confusion_matrix.png')

summarize_net(cnn, X_test, y_test, title_text='CNN:')


# save model to disk
cnn.save('cnn.h5')

