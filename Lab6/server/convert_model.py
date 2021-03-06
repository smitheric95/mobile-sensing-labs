from coremltools.converters import keras
from keras.models import load_model

MODEL_PATH = 'models/'
MODEL_NAME = 'cnn_11_10_10epochs.h5'
k_model = load_model(MODEL_PATH + MODEL_NAME)

classes = open('classes.txt', 'r').read().split()

model = keras.convert(k_model, image_input_names='img', input_names='img', class_labels=classes)

model.save(MODEL_PATH + 'SymbolModel.mlmodel')
