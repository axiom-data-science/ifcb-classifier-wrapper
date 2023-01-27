# ifcb-classifier

Dockerfile for WHOI's [ifcb_classifier](https://github.com/WHOIGit/ifcb_classifier)

## Usage

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

More usage details can be found in the `ifcb_classifier` [wiki](https://github.com/WHOIGit/ifcb_classifier/wiki/neuston_net-RUN). 
