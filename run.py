import click
from datetime import datetime, timedelta
from pathlib import Path
import neuston_net as nn
import os
import sys
import tempfile
import yaml


def yaml_config_callback(ctx, param, value):
    # load config from yaml file if provided
    if value:
        with open(value) as f:
            ctx.default_map = yaml.safe_load(f)


@click.command()
@click.option('--start-date', type=click.DateTime(formats=['%Y-%m-%d']))
@click.option('--end-date', type=click.DateTime(formats=['%Y-%m-%d']))
@click.option('--since-days', type=click.INT)
@click.option('--run-id', type=click.STRING)
@click.option('--config', type=click.Path(exists=True, dir_okay=False), callback=yaml_config_callback, is_eager=True)
@click.option('--force/--no-force', '--clobber', default=False)
@click.option('--pid', type=click.STRING)
@click.argument('ifcb_data_dir', type=click.Path(exists=True, file_okay=False, path_type=Path))
@click.argument('output_dir', type=click.Path(file_okay=False, path_type=Path))
@click.argument('ifcb_classify_model_path', type=click.Path(dir_okay=False, path_type=Path))
@click.pass_context
def cli(
    ctx,
    start_date: datetime,
    end_date: datetime,
    since_days: int,
    run_id: str,
    config: Path,
    force: bool,
    pid: str,
    ifcb_data_dir: Path,
    output_dir: Path,
    ifcb_classify_model_path: Path,
):
    if not run_id:
        run_id = f'{ifcb_data_dir.name.split("/")[-1]}-{int(datetime.now().timestamp())}'

    run_args = [
        'run.py',
        'RUN',
        '--outfile', '{BIN_YEAR}/D{BIN_DATE}/{BIN_ID}_class.h5',
        '--outdir', str(output_dir),
        str(ifcb_data_dir),
        str(ifcb_classify_model_path),
        run_id,
    ]

    if force:
        run_args.append("--clobber")

    filter_file = None
    if pid:
        run_args.extend(['--filter', 'IN', pid])
    else:
        if not start_date and since_days:
            start_date = datetime.now().date() - timedelta(days=since_days)
        if start_date:
            if not end_date:
                end_date = datetime.now().date()

            if isinstance(start_date, datetime):
                start_date = start_date.date()
            if isinstance(end_date, datetime):
                end_date = end_date.date()

            # ifcb_classifier can't just be given start and end dates. You can either point it at an
            # entire directory or pass individual dates to --filter IN that you want included.
            # Alternatively you can pass a file with a date per line; that's what we're doing here
            # since the list could potentially include hundreds of dates.
            filter_dates = [(start_date + timedelta(days=d)).strftime("%Y%m%d") for d in range((end_date - start_date).days + 1)]
            filter_file = tempfile.NamedTemporaryFile(mode='w', delete=False)
            filter_file.write('\n'.join(filter_dates))
            filter_file.close()
            run_args.extend(['--filter', 'IN', filter_file.name])

    # replace sys.argv with our constructed args as if they were passed on the cli
    sys.argv = run_args
    print(f'Running neuston_net with adjusted arguments: {sys.argv}')

    # run ifcb-classify (adapted from neuston_net __main__)
    parser = nn.argparse_nn()
    input_args = parser.parse_args()
    nn.argparse_nn_runtimeparams(input_args)
    nn.main(input_args)

    # clean up filter file if present
    if filter_file and os.path.exists(filter_file.name):
        os.remove(filter_file.name)


def cli_wrapper():
    # detect --config-dir argument before parsing args, and batch discovered config files if found
    config_dir = None
    for i, arg in enumerate(sys.argv):
        if arg == '--config-dir' and len(sys.argv) > i+1:
            config_dir = Path(sys.argv[i+1])
            del sys.argv[i:i+2]
            break

    if config_dir:
        if not config_dir.exists():
            raise ValueError(f'config-dir {config_dir} not found')

        orig_args = sys.argv
        for config_yml in sorted(config_dir.rglob('*.yml')):
            sys.argv = orig_args + ['--config', config_yml]
            cli(standalone_mode=False)
    else:
        cli()


if __name__ == '__main__':
    cli_wrapper()
