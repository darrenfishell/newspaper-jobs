import dlt
import requests
import pandas as pd
import zipfile

from io import BytesIO
from datetime import datetime
from pathlib import Path
from dlt.sources.rest_api import RESTClient
from tqdm import tqdm

db_name = 'newspaper_jobs' + '.duckdb'
raw_data_dir = Path(__file__).parents[1] / 'data' / 'raw_data'

def retrieve_csv(url, verify=True, filename=None, sep=','):

    if filename is None:
        filename = Path(url).name
    filepath = raw_data_dir / filename

    if not filepath.exists():
        session = requests.Session()
        session.verify = verify
        client = RESTClient(url, session=session)

        r = client.get(path='')
        r.raise_for_status()
        with open(filepath, 'w', encoding='utf-8') as outfile:
            outfile.write(r.text)

    df = pd.read_csv(filepath, sep=sep, low_memory=False)
    return df.to_dict(orient='records')

@dlt.source()
def qcew():

    # NAICS for newspaper + internet publishing
    # Ref: https://www.census.gov/naics/?input=51&chart=2022&details=513110

    newspaper_naics = {
        2021: [511110],
        2026: [513110]      # Adds online-only publishers
    }

    qcew_years = list(range(1990, datetime.now().year))

    @dlt.resource(
        write_disposition='merge',
        primary_key=['area_fips', 'own_code', 'industry_code', 'year', 'qtr'],
        parallelized=True
    )
    def qcew_statewide_annual_average():
        """
        :param area_list:
        :return: Industry totals and 2-digit NAICS totals
        from QCEW ZIP with parallelized CSV processing and filtering.
        """
        @dlt.defer
        def _process_csv(csv_bytes=None, filename=None):
            try:
                df = pd.read_csv(csv_bytes)
                yield df.to_dict(orient='records')
            except Exception as e:
                tqdm.write(f"❌ Error loading {filename}: {e}")

        for year in qcew_years:
            zip_url = f'https://data.bls.gov/cew/data/files/{year}/csv/{year}_annual_by_area.zip'
            tqdm.write(f'Downloading {zip_url}')
            zip_content = requests.get(zip_url).content
            tqdm.write(f'Download complete')

            naics_year = min(y for y in newspaper_naics.keys() if y >= year)
            naics_vals = newspaper_naics[naics_year]

            file_like_zip = BytesIO(zip_content)

            for naics in naics_vals:

                with zipfile.ZipFile(file_like_zip) as zf:
                    zip_paths = [file for file in zf.namelist() if 'Statewide' in file]
                    for file in zip_paths:
                        file_bytes = BytesIO(zf.read(file))
                        filename = Path(file).name
                        records = _process_csv(csv_bytes=file_bytes, filename=filename)
                        yield records

    return qcew_statewide_annual_average

def main(dev_mode=False):

    pipeline = dlt.pipeline(
        pipeline_name='newspaper_jobs',
        destination=dlt.destinations.duckdb(Path(__file__).parents[1] / 'data' / db_name),
        progress=dlt.progress.tqdm(colour='blue'),
        dataset_name='bronze',
        dev_mode=dev_mode
    )

    bronze_load_info = pipeline.run(qcew())
    print(bronze_load_info)

if __name__ == '__main__':
    main(dev_mode=False)