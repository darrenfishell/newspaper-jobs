SELECT
    split_part(area_title, ' --', 1) AS area,
    year as year,
    industry_code,
    industry_title,
    annual_avg_estabs_count,
    annual_avg_emplvl,
    total_annual_wages,
    avg_annual_pay,
    lq_avg_annual_pay,
    lq_annual_avg_emplvl
FROM {{ source('qcew', 'qcew_statewide_annual_average') }}
WHERE (agglvl_code = 51 AND own_code = 5)
OR (agglvl_code = 58
    AND industry_code IN (511110, 513110)
    AND own_code =5)