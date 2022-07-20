#!/usr/bin/env python3
import pydicom
import numpy as np
from pydicom.dataset import Dataset
from pydicom.uid import ExplicitVRLittleEndian
import pydicom._storage_sopclass_uids


def img_dcm(image2d, PatientName="World^Hello", ID="123456"):
    """from
    https://stackoverflow.com/questions/14350675/create-pydicom-file-from-numpy-array
    /users/231422/corvin
    """
    image2d = image2d.astype(np.uint16)

    meta = pydicom.Dataset()
    meta.MediaStorageSOPClassUID = pydicom._storage_sopclass_uids.MRImageStorage
    meta.MediaStorageSOPInstanceUID = pydicom.uid.generate_uid()
    meta.TransferSyntaxUID = pydicom.uid.ExplicitVRLittleEndian  

    ds = Dataset()
    ds.file_meta = meta

    ds.is_little_endian = True
    ds.is_implicit_VR = False

    ds.SOPClassUID = pydicom._storage_sopclass_uids.MRImageStorage
    ds.PatientName = PatientName
    ds.PatientID = ID

    ds.Modality = "MR"
    ds.SeriesInstanceUID = pydicom.uid.generate_uid()
    ds.StudyInstanceUID = pydicom.uid.generate_uid()
    ds.FrameOfReferenceUID = pydicom.uid.generate_uid()

    ds.BitsStored = 16
    ds.BitsAllocated = 16
    ds.SamplesPerPixel = 1
    ds.HighBit = 15

    ds.ImagesInAcquisition = "1"

    ds.Rows = image2d.shape[0]
    ds.Columns = image2d.shape[1]
    ds.InstanceNumber = 1

    ds.ImagePositionPatient = r"0\0\1"
    ds.ImageOrientationPatient = r"1\0\0\0\-1\0"
    ds.ImageType = r"ORIGINAL\PRIMARY\AXIAL"

    ds.RescaleIntercept = "0"
    ds.RescaleSlope = "1"
    ds.PixelSpacing = r"1\1"
    ds.PhotometricInterpretation = "MONOCHROME2"
    ds.PixelRepresentation = 1

    pydicom.dataset.validate_file_meta(ds.file_meta, enforce_standard=True)

    ds.PixelData = image2d.tobytes()
    return(ds)


if __name__ == "__main__":
    import sys
    if not len(sys.argv) in [2, 3]:
        print(f"usage: {sys.argv[0]} outputname ['csv_row;csv_row;...']")
        sys.exit(1)
    if len(sys.argv) == 2:
        image2d = np.array([[0, 1], [2, 0]])
    else:
        image2d = np.array(
            [[float(v) for v in r.split(',')]
             for r in sys.argv[2].split(";")])

    outname = sys.argv[1]
    ds = img_dcm(image2d, "Example", "123456")
    ds.save_as(filename=outname, write_like_original=False)
