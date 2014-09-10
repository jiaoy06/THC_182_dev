# coding='utf-8'

import glob
import os
import Image

jpgNameList = glob.glob('*.jpg')
outDir = 'thumbnail'

for jpgName in jpgNameList:
    print jpgName
    im = Image.open(jpgName)
    print im.size
    # 滤镜缩放
    om = im.resize((45, 64), Image.ANTIALIAS)
    om.save(os.path.join(outDir, jpgName))