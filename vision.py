from torchvision.models.alexnet import alexnet, AlexNet_Weights
import torch

a_net = alexnet(weights=AlexNet_Weights.DEFAULT)

print(a_net)