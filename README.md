# MLP for Function Estimation
 Multi-Layer Perceptron for Function Estimation with Various Parameters

The dataset "slice_localization_data.csv" used can be accessed here:
https://archive.ics.uci.edu/ml/datasets/Relative+location+of+CT+slices+on+axial+axis
It contains 53500 samples (rows) with 385 columns (features)
The last column (column #386) is the target value for samples, which is to be estimated by the MLP neural Network.

There are a number of parameters and options that can be decided on by the user through the GUI:

 - Number of hidden layers(up to 5 layers)
 - Number of neurons in each hidden layer
 - Different activation functions (Tanh, Sigmoid)
 - Initial weight selection method (Uniform, Nguyen-Widrow)
 - Using Batch Mode in training the neural network (and batch number)
 - Using Momentom in training the neural network (and the mu value)
 - Learning rate
 - The division ratios for splitting the data into training, validation, and test sets
 - The stopping condition for training (reaching maximum number of epochs, reaching threshold error rate)
 
 The figure shows the train and test error rates as the training progresses
 Minimum test and train rates during training and the training and testing time are displayed at the end of training

