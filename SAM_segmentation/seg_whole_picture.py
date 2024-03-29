# -*- coding: utf-8 -*-
"""
Created on Thu Feb  8 08:58:52 2024

@author: Admin
"""

# -*- coding: utf-8 -*-
"""
@Time ： 2023/10/8 10:15
@Auth ： RS迷途小书童
@File ：Segment Anything Auto.py
@IDE ：PyCharm
@Purpose：Segment Anything Model自动全局语义分割
"""
import sys
import cv2
import random
import numpy as np
from osgeo import gdal
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from segment_anything import sam_model_registry, SamAutomaticMaskGenerator


def SAM_auto(image_path, model_path, model_type, device, out_path, out_path1, out_image_path):
    """
    :param image_path: 输入需要分割的影像
    :param model_path: 输入模型路径
    :param model_type: 输入模型类型
    :param device: 输入cpu or cuda
    :param out_path: 输出彩色掩膜文件
    :param out_path1: 输出单波段掩膜文件
    :param out_image_path: 输出叠加图片
    :return: None
    """

    def show_mask_auto(masks_data, out_mask_path, out_path_01):
        """
        :param masks_data: 掩膜数据
        :param out_mask_path: 输出彩色掩膜
        :param out_path_01: 输出单波段掩膜
        :return: None
        """
        if len(masks_data) == 0:
            return
        sorted_masks_data = sorted(masks_data, key=(lambda x: x['area']), reverse=True)  # 按照面积大小降序排列
        ax = plt.gca()  # 获取当前的轴（axes）
        ax.set_autoscale_on(False)  # 关闭轴的自动缩放功能
        img = np.ones((sorted_masks_data[0]['segmentation'].shape[0], sorted_masks_data[0]['segmentation'].shape[1], 4))
        # 创建了一个新的三维数组img。数组的形状是基于segmentation']的形状，其中四个通道通常代表红色、绿色、蓝色和透明度（RGBA）
        img[:, :, 3] = 0  # 将新创建的图像的第四个通道（也就是透明度通道）设置为0
        img_raster = np.zeros((sorted_masks_data[0]['segmentation'].shape[0],
                              sorted_masks_data[0]['segmentation'].shape[1]))
        # 创建一个二维数组，用于保存掩膜做栅格转面
        j = 1
        for sorted_mask_data in sorted_masks_data:
            # 循环所有类别的掩膜
            m = sorted_mask_data['segmentation']
            # 获取当前类别的二值mask图片
            color_mask = np.concatenate([np.random.random(3), [0.65]])
            # 随机生成的RGB颜色，它的形状为(3,)，0.65表示颜色的透明度。
            img[m] = color_mask
            # 将颜色赋予图片的数组
            img_raster[m] = j
            # 给掩膜赋值
            j += 1
        """for i in range(0, len(masks_data)):
            # 循环所有类别的掩膜
            rect = patches.Rectangle((masks_data[i]['bbox'][0], masks_data[i]['bbox'][1]), masks_data[i]['bbox'][2],
                                     masks_data[i]['bbox'][3], edgecolor=tuple(random.uniform(0, 1) for _ in range(3)),
                                     facecolor='none', linewidth=2)  # 绘制类别的外接矩形框
            ax.add_patch(rect)  # 将矩形添加到ax对象中"""
        plt.imshow(img, alpha=0.8)
        print("[%s]正在保存类别掩膜......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        driver = gdal.GetDriverByName('GTiff')  # 载入数据驱动，用于存储内存中的数组
        ds_result = driver.Create(out_mask_path, sorted_masks_data[0]['segmentation'].shape[1],
                                  sorted_masks_data[0]['segmentation'].shape[0], bands=4, eType=gdal.GDT_Float64)
        # 创建一个数组，宽高为原始尺寸
        for i in range(3):
            ds_result.GetRasterBand(i+1).SetNoDataValue(0)  # 将无效值设为0
            ds_result.GetRasterBand(i+1).WriteArray(img[:, :, i])  # 将结果写入数组
        ds_result_raster = driver.Create(out_path_01, sorted_masks_data[0]['segmentation'].shape[1],
                                         sorted_masks_data[0]['segmentation'].shape[0], bands=1, eType=gdal.GDT_Float64)
        # ds_result.SetGeoTransform(ds_geo)  # 导入仿射地理变换参数
        # ds_result.SetProjection(ds_prj)  # 导入投影信息
        ds_result_raster.GetRasterBand(1).SetNoDataValue(0)  # 将无效值设为0
        ds_result_raster.GetRasterBand(1).WriteArray(img_raster)  # 将结果写入数组
        del ds_result
        del ds_result_raster

    print("【程序准备阶段】")
    print("[%s]正在读取图片......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    try:
        image = cv2.imread(image_path)  # 读取的图像以NumPy数组的形式存储在变量image中
        print("[%s]正在转换图片格式......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)  # 将图像从BGR颜色空间转换为RGB颜色空间，还原图片色彩（图像处理库所认同的格式）
        print("[%s]正在初始化模型参数......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    except:
        print("图片打开失败！请检查路径！")
        pass
        sys.exit()
    sys.path.append("..")  # 将当前路径上一级目录添加到sys.path列表，这里模型使用绝对路径所以这行没啥用
    sam_checkpoint = model_path  # 定义模型路径

    sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
    sam.to(device=device)  # 定义模型参数
    mask_generator = SamAutomaticMaskGenerator(model=sam,  # 用于掩膜预测的SAM模型
                                               points_per_side=32,  # 图像一侧的采样点数，总采样点数是一侧采样点数的平方，点数给的越多，分割越细
                                               # points_per_batch=64,  # 设置模型同时运行的点的数量。更高的数字可能会更快，但会使用更多的GPU内存
                                               pred_iou_thresh=0.86,  # 滤波阈值，在[0,1]中，使用模型的预测掩膜质量0.86
                                               stability_score_thresh=0.92,
                                               # 滤波阈值，在[0,1]中，使用掩码在用于二进制化模型的掩码预测的截止点变化下的稳定性0.92
                                               # stability_score_offset=1.0,  # 计算稳定性分数时，对截止点的偏移量
                                               # box_nms_thresh=0.7,  # 非最大抑制用于过滤重复掩码的箱体IoU截止点
                                               crop_n_layers=1,  # 如果>0，蒙版预测将在图像的裁剪上再次运行。设置运行的层数，其中每层有2**i_layer的图像裁剪数1
                                               # crop_nms_thresh=0.7,  # 非最大抑制用于过滤不同作物之间的重复掩码的箱体IoU截止值
                                               # crop_overlap_ratio=512 / 1500,  # 设置作物重叠的程度
                                               crop_n_points_downscale_factor=2,
                                               # 在图层n中每面采样的点数被crop_n_points_downscale_factor**n缩减2
                                               # point_grids=None,  # 用于取样的明确网格的列表，归一化为[0,1]
                                               min_mask_region_area=20,
                                               # 如果>0，后处理将被应用于移除面积小于min_mask_region_area的遮罩中的不连接区域和孔。需要opencv。50
                                               # output_mode="binary_mask"  # 掩模的返回形式。
                                               # 可以是’binary_mask’, ‘uncompressed_rle’, 或者’coco_rle’。
                                               # coco_rle’需要pycocotools。对于大的分辨率，'binary_mask’可能会消耗大量的内存
                                               )  # 激活函数
    print("【模型预测阶段】")
    print("[%s]正在分割图片......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    masks = mask_generator.generate(image)  # 类别掩膜提取(包含所有的，可按照索引查看)

    # ---------------------------masks输出内容---------------------------
    # segmentation : np的二维数组，为二值的mask图片
    # area : mask的像素面积
    # bbox : mask的外接矩形框，为X Y WH格式
    # predicted_iou : 该mask的质量（模型预测出的与真实框的iou）
    # point_coords : 用于生成该mask的point输入
    # stability_score : mask质量的附加指标
    # crop_box : 用于以X Y WH格式生成此遮罩的图像裁剪
    # ------------------------------------------------------------------

    print("[%s]正在绘制图片......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    plt.figure(figsize=(20, 20))  # 创建一个新的图形窗口，设置其大小为10x10英寸
    plt.imshow(image)  # 使用imshow函数在创建的图形窗口中显示图像
    print("[%s]正在制作掩膜......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    print("【结果保存阶段】")
    show_mask_auto(masks, out_path, out_path1)
    plt.axis('on')  # 开启图像坐标轴，使得图像下的像素坐标可以显示出来
    print("[%s]正在保存叠加结果......" % datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    plt.savefig(out_image_path, dpi=300)
    plt.show()  # 显示已经创建的图形窗口和其中的内容
    print("-----------------------------------------语义分割已完成----------------------------------------")


if __name__ == "__main__":
    print("\n")
    print("--------------------------------------Segment Anything--------------------------------------")
    Image_path = 'result9/pic.png'  # 分割的影像
    Model_path = "sam_vit_l_0b3195.pth"  # 模型路径
    Out_mask_path = 'result9/mpic.tif'  # 彩色掩膜
    Out_mask_path1 = 'result9/mpic.tif'  # 二维掩膜用于转矢量
    Out_image_path = 'result9/mpic.png'  # 叠加结果
    Model_type = "vit_l"  # 定义模型类型
    Device = "cuda"  # "cpu"  or  "cuda"
    SAM_auto(Image_path, Model_path, Model_type, Device, Out_mask_path, Out_mask_path1, Out_image_path)
    # 图片，模型，类型，算力，彩色掩膜，黑白掩膜，叠加图片
