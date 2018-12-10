from coremltools.converters import keras
from keras.models import load_model

MODEL_PATH = './'
MODEL_NAME = 'cnn2_100_early.h5'
k_model = load_model(MODEL_PATH + MODEL_NAME)

classes = open('classes.txt', 'r').read().strip().split()

model = keras.convert(k_model, image_input_names='img', input_names='img', class_labels=classes, image_scale=(1/255))

model.save(MODEL_PATH + 'PythonCodeModel.mlmodel')
