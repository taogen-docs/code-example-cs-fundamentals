import os
import shutil
from pathlib import Path

source_dir = str(Path.home()) + '/Desktop'

if not os.path.exists(source_dir) or not os.path.isdir(source_dir):
    raise Exception("source_dir {} do not exists!".format(source_dir))

destination_dir = 'D:/My Desktop'

if not os.path.exists(destination_dir) and not os.path.isdir(destination_dir):
    os.makedirs(destination_dir)
    print("Created dir " + destination_dir)

dir_list = os.listdir(source_dir)

print("Start to move files and directories on {} to {}".format(source_dir, destination_dir))

i = 0

for item in dir_list:
    source_item = source_dir+"/"+item
    item_type=""
    if os.path.isfile(source_item):
        item_type="file"
    if os.path.isdir(source_item):
        item_type="dir"
    if not os.path.exists(destination_dir+"/"+item):
        try:
            shutil.move(source_item, destination_dir)
        except PermissionError as e:
            print("Ignore PermissionError: file used by another process")
            pass
        finally:
            i += 1
            print('Moved {} {} to {}'.format(item_type, source_dir+"/"+item, destination_dir+"/"+item))

print("Move {} items to {}".format(i, destination_dir))
print("Done!")


