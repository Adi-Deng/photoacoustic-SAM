# Applications of Foundation Models in Photoacoustic Image Segmentation

## Installing Dependencies

#### 1 Python

* This code requires `python>=3.8`, as well as `pytorch>=1.7` and `torchvision>=0.8`. Click [here](https://pytorch.org/get-started/locally/) to ensure the correct installation of PyTorch and TorchVision dependencies.
* Install `gdal`:
  
  ```
  conda install -c conda-forge gdal
  ```
* Create a local git repository:
  
  ```
  git clone git@github.com:Adi-Deng/photoacoustic-SAM.git
  ```

#### 2 Matlab

* Matlab version: `Matlab R2021a`

---

## Mouse Outer Contour Segmentation

* Open the `SAM_segmentation` folder: `cd SAM_segmentation`;
* Set the prompt: Change the `input_point` and `input_label` variables in `seg_multiple_prompt.py`;
* Segmentation: `python seg_multiple_prompt.py`;

## Photoacoustic Multiple Vessel Segmentation

* Place the images to be segmented in the `\SAM_segmentation\result9` directory;
* Open the `SAM_segmentation` folder: `cd SAM_segmentation`;
* Segmentation: `python seg_whole_picture.py`;
* Open the `multi_vessel_seg` folder;
* Run `vessel_segmentation.m`;

## 3D Reconstruction

* Place the images to be segmented in the `\data\jpg3d` directory;
* Open the `SAM_segmentation` folder: `cd SAM_segmentation`;
* Segmentation: `python seg_3d.py`;
* Open the `3D_reconstruction` folder, run `3DReconstruction.m`;

## Mouse Dual Speed of Sound Reconstruction

#### 1 Single Speed of Sound Reconstruction

* Place the `.mat` files of the Sinogram to be reconstructed in the `data` path;
* Open the `double_mouse_photoacoustic` folder;
* Modify the required parameters, run `mouse_1sos_reconstruction.m`

#### 2 SAM Segmentation

* Open the `SAM_segmentation` folder: `cd SAM_segmentation`;
* Convert the single speed of sound reconstructed `.mat` file to `.png` format: `python mat2png.py`;
* Set the prompt and segmentation: `python seg_multiple_prompt.py`;

#### 3 Feature Extraction Based on SAM Segmentation Mask and Dual Speed of Sound Reconstruction

* Open the `double_mouse_photoacoustic` folder;
* Modify the required speed of sound and parameters, run `mouse_2sos_reconstruction.m`;
  
  ## Contributors
  
  This project was made possible with the help of many contributors (alphabetical):
  Handi Deng, Wubin Fu, Yucheng Zhou,Jiaxuan Xiang, Yan Luo, Xuanhao Wang.
  Special thanks to [Segment-Anything](https://segment-anything.com/) for foundation model and [RS迷途小书童](https://blog.csdn.net/m0_56729804) for contributions made in model deployment

