import scipy.io
import os
import matplotlib.pyplot as plt
data_dir = '../data/mat_raw'
figure_dir = '../data/jpg_1sos'
# 遍历data文件夹下的所有文件
for file in os.listdir(data_dir):
    if file.endswith("1sos.mat"):
        file_path = os.path.join(data_dir, file)
        mat_data = scipy.io.loadmat(file_path)
        x = mat_data['sos1data']
        #new_file_name = file[:-4] + "_figure.jpg"
        new_file_name = "1sos_figure"
        new_file_path = os.path.join(figure_dir, new_file_name)
        plt.figure(figsize=(4,4),dpi=100)#size of the FOV
        plt.gca().xaxis.set_major_locator(plt.NullLocator())
        plt.gca().yaxis.set_major_locator(plt.NullLocator())
        plt.subplots_adjust(top = 1, bottom = 0, right = 1, left = 0, hspace = 0, wspace = 0)
        plt.margins(0,0)
        plt.imshow(x, cmap='gray', vmin=-0.02, vmax=0.05)
        plt.savefig(new_file_path,pad_inches=0)
        plt.show()