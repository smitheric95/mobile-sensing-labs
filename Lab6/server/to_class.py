classes = open('./Data/classes.txt', 'r').read().split()

def to_class(ohe_arr):
	return classes[ohe_arr.index(max(ohe_arr))]
