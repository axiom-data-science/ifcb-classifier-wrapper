# ifcb-classifier

Dockerfile for WHOI's [ifcb_classifier](https://github.com/WHOIGit/ifcb_classifier),
with wrapper to facilitate bulk classification.

## Building

To build and test run

```sh
docker build -t ifcb-classifier .
docker run --rm ifcb-classifier neuston_net.py --help
```

which should produce

```
Usage: run.py [OPTIONS] IFCB_DATA_DIR OUTPUT_DIR IFCB_CLASSIFY_MODEL_PATH

Options:
  --start-date [%Y-%m-%d]
  --end-date [%Y-%m-%d]
  --since-days INTEGER
  --run-id TEXT
  --config FILE
  --force, --clobber / --no-force
  --pid TEXT
  --help                          Show this message and exit.
```

## Running

Example classification of last week of data:

```sh
docker run --rm --gpus all --name ifcb-recent-classify \
	-e CUDA_VISIBLE_DEVICES='0' \
	-v /path/to/ifcb/raw:/data/ifcb/raw:ro \
	-v /path/to/ifcb/model:/data/ifcb/model:ro \
	-v /path/to/ifcb/classified:/data/ifcb/classified \
	ifcb-classifier \
	--since-days 7 \
  /data/ifcb/raw \
  /data/ifcb/classified \
  /data/ifcb/model/themodel.ptl
```

For a full backfill, omit `--since-days`.
For a specify date range, omit `--since-days` and provide `--start-date` and `--end-date` instead (`YYYY-MM-DD`).
To force generation of existing class files, set `--force`.

More usage details can be found in the `ifcb_classifier` [wiki](https://github.com/WHOIGit/ifcb_classifier/wiki/neuston_net-RUN). 
