import os
import cv2
import sys
import torch
import numpy as np
from datetime import datetime
import matplotlib.pyplot as plt
from torch import logit
import scipy.io as io

from segment_anything import sam_model_registry, SamPredictor


def show_mask(mask, ax, random_color=False):
    if random_color:
        color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0)
    else:
        color = np.array([30 / 255, 144 / 255, 255 / 255, 0.6])
    h, w = mask.shape[-2:]
    mask_image = mask.reshape(h, w, 1) * color.reshape(1, 1, -1)
    ax.imshow(mask_image)


def show_points(coords, labels, ax, marker_size=375):
    pos_points = coords[labels == 1]
    neg_points = coords[labels == 0]
    ax.scatter(pos_points[:, 0], pos_points[:, 1], color='green', marker='*', s=marker_size, edgecolor='white',
               linewidth=1.25)
    ax.scatter(neg_points[:, 0], neg_points[:, 1], color='red', marker='*', s=marker_size, edgecolor='white',
               linewidth=1.25)


def show_box(box, ax):
    x0, y0 = box[0], box[1]
    w, h = box[2] - box[0], box[3] - box[1]
    ax.add_patch(plt.Rectangle((x0, y0), w, h, edgecolor='green', facecolor=(0, 0, 0, 0), lw=2))

if __name__ == '__main__':
    result_path='../data/sam_segmentation/result'# segmentation result path
    mask_path='../data/sam_segmentation/mat_mask'# segmentation mask path
    imagepath='../data/jpg_1sos/1sos_figure.png'
    image = cv2.imread(imagepath)#figure path
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)  # BGR2RGB
    sam_checkpoint = './sam_vit_l_0b3195.pth'
    model_type = "vit_l"
    device = "cuda"  # "cpu"  or  "cuda"
    sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
    sam.to(device=device)
    predictor = SamPredictor(sam)
    predictor.set_image(image)
    input_point = np.array([[25,25],[375,25],[25,375],[375,375]])#position of prompt
    input_label = np.array([1,1,1,1])

    masks, _, _ = predictor.predict(
        point_coords=input_point,
        point_labels=input_label,
        #mask_input=mask_input[None, :, :],
        multimask_output=False,
    )
    # print(masks.shape)  # output: (1, 600, 900)

    plt.figure(figsize=(10, 10))
    plt.imshow(image)
    show_mask(masks, plt.gca())
    show_points(input_point, input_label, plt.gca())
    plt.axis('off')
    plt.savefig(os.path.join(result_path,'test2_sam_result.jpg'))
    plt.show()
    plt.close()
    mask1=masks[0,:,:]
    io.savemat(os.path.join(mask_path,'test2_sam_mask.mat'),{'data':mask1})