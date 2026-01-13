-- ============================================================
-- Hospital Performance SQL Analysis (CMS HRRP)
-- Goal: Evaluate excess 30-day readmissions across hospitals,
--       identify high-variability conditions, and surface outliers.
-- Database: SQLite (hospital.db)
-- Table: hrrp_readmissions
-- ============================================================

-- 0) Verify table exists
SELECT name
FROM sqlite_master
WHERE type = 'table';

-- 1) Quick peek at the data
SELECT *
FROM hrrp_readmissions
LIMIT 10;

-- 2) Coverage: How many hospitals are represented per state?
SELECT
  state,
  COUNT(DISTINCT facility_id) AS hospital_count
FROM hrrp_readmissions
GROUP BY state
ORDER BY hospital_count DESC;

-- 3) Condition-level performance: Which conditions have the highest average excess readmission ratio?
SELECT
  measure_name,
  ROUND(AVG(CAST(excess_readmission_ratio AS REAL)), 3) AS avg_excess_ratio,
  COUNT(*) AS rows_n
FROM hrrp_readmissions
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY measure_name
ORDER BY avg_excess_ratio DESC;

-- 4) Outliers: Hospitals with very high excess readmission ratios (flag potential QI targets)
SELECT
  facility_name,
  facility_id,
  state,
  measure_name,
  CAST(excess_readmission_ratio AS REAL) AS excess_readmission_ratio
FROM hrrp_readmissions
WHERE excess_readmission_ratio IS NOT NULL
  AND CAST(excess_readmission_ratio AS REAL) > 1.25
ORDER BY CAST(excess_readmission_ratio AS REAL) DESC
LIMIT 20;

-- 5) Rank hospitals WITHIN each condition (top 10 worst per measure)
WITH ranked AS (
  SELECT
    facility_name,
    facility_id,
    state,
    measure_name,
    CAST(excess_readmission_ratio AS REAL) AS excess_readmission_ratio,
    RANK() OVER (
      PARTITION BY measure_name
      ORDER BY CAST(excess_readmission_ratio AS REAL) DESC
    ) AS rank_within_condition
  FROM hrrp_readmissions
  WHERE excess_readmission_ratio IS NOT NULL
)
SELECT *
FROM ranked
WHERE rank_within_condition <= 10
ORDER BY measure_name, rank_within_condition;

-- 6) Flag hospitals as "Above Benchmark" vs "At/Below Benchmark" using CASE WHEN
--    (Benchmark interpretation: excess_readmission_ratio > 1 suggests worse-than-expected readmissions)
SELECT
  measure_name,
  SUM(CASE WHEN CAST(excess_readmission_ratio AS REAL) > 1.0 THEN 1 ELSE 0 END) AS above_benchmark_count,
  SUM(CASE WHEN CAST(excess_readmission_ratio AS REAL) <= 1.0 THEN 1 ELSE 0 END) AS at_or_below_benchmark_count,
  COUNT(*) AS total_rows
FROM hrrp_readmissions
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY measure_name
ORDER BY above_benchmark_count DESC;

-- 7) Identify hospitals that are repeatedly above benchmark across multiple conditions (HAVING)
--    (This surfaces hospitals that may need broader system-level interventions.)
WITH flagged AS (
  SELECT
    facility_id,
    facility_name,
    state,
    measure_name,
    CAST(excess_readmission_ratio AS REAL) AS excess_readmission_ratio
  FROM hrrp_readmissions
  WHERE excess_readmission_ratio IS NOT NULL
)
SELECT
  facility_id,
  facility_name,
  state,
  COUNT(*) AS conditions_reported,
  SUM(CASE WHEN excess_readmission_ratio > 1.0 THEN 1 ELSE 0 END) AS conditions_above_benchmark
FROM flagged
GROUP BY facility_id, facility_name, state
HAVING conditions_above_benchmark >= 3
ORDER BY conditions_above_benchmark DESC, conditions_reported DESC
LIMIT 25;

-- 8) Variability proxy by condition: spread = max - min excess ratio (simple descriptive variability)
SELECT
  measure_name,
  ROUND(MAX(CAST(excess_readmission_ratio AS REAL)) - MIN(CAST(excess_readmission_ratio AS REAL)), 3) AS spread,
  COUNT(*) AS rows_n
FROM hrrp_readmissions
WHERE excess_readmission_ratio IS NOT NULL
GROUP BY measure_name
ORDER BY spread DESC;