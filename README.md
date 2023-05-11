# ifcb-classifier

Dockerfile for WHOI's [ifcb_classifier](https://github.com/WHOIGit/ifcb_classifier)

## Building

To build and test run

```sh
docker build -t ifcb-classifier .
docker run --rm ifcb-classifier neuston_net.py --help
```

which should produce

```
usage: neuston_net.py [-h] [--batch SIZE] [--loaders N] {TRAIN,RUN} ...

Train, Run, and perform other tasks related to ifcb and general image
classification!

positional arguments:
  {TRAIN,RUN}   These sub-commands are mutually exclusive. Note: optional
                arguments (below) must be specified before "TRAIN" or "RUN"
    TRAIN       Train a new model
    RUN         Run a previously trained model

optional arguments:
  -h, --help    show this help message and exit

NN Common Args:
  --batch SIZE  Number of images per batch. Defaults is 108
  --loaders N   Number of data-loading threads. 4 per GPU is typical. Default
                is 4
```

## Running

Example backfill of IFCB 158 2021 data:

```sh
sudo docker run --rm -d --ipc=host --gpus all --name ifcbnn-158-backfill \
	-e STARTDATE='2021-01-01' \
	-e ENDDATE='2021-01-31' \
	-e CUDA_VISIBLE_DEVICES='0' \
	-v /mnt/store/data/ifcb/sccoos/CA-IFCB-158/2021/:/indata/:ro \
	-v /mnt/store/data/assets/ifcb/models/models/ifcb-socal/:/model/:ro \
	-v /mnt/store/data/assets/ifcb/classified-data/IFCB158/:/outdata/ \
	ifcb-classifier neuston_net.py RUN  \
	--outdir "/outdata/" \
	--outfile "{BIN_YEAR}/D{BIN_DATE}/{BIN_ID}_class.h5" \
	/indata \
	/model/20220416_Delmar_NES_1.ptl \
	ifcbnn-158-backfill \
	--filter IN /tmp/ifcb-classifier-dates
```

More usage details can be found in the `ifcb_classifier` [wiki](https://github.com/WHOIGit/ifcb_classifier/wiki/neuston_net-RUN). 
