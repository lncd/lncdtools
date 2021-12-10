#!/usr/bin/env python3
import nibabel as nib
import numpy as np

def mknii(data, saveas):
    img = nib.Nifti1Image(data, np.eye(4), nib.Nifti1Header())
    nib.save(img, saveas)


def img3d(s):
    return np.array(
        [[[float(v) for v in r.split(',')]
         for r in x.split(";")]
         for x in s.split("|")])


if __name__ == "__main__":
    import sys
    data = np.array([[[1, 2], [3, 4]], [[5, 6], [7, 8]]])
    if not len(sys.argv) in [2, 3]:
        print(f"usage: {sys.argv[0]} outputname ['csv_row;csv_row|csv_row;csv_row|...']")
        sys.exit(1)
    if len(sys.argv) == 2:
        inputstr = '1,2;3,4|5,6;7,8'
    else:
        inputstr = sys.argv[2]

    mknii(img3d(inputstr), sys.argv[1])
