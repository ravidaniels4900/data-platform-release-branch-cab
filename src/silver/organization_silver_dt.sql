-- ============================================================
-- Data Platform: Release Branch CAB-Gated
-- Object: ORGANIZATION_DT (Silver Dynamic Table)
-- Target: <%silver_database %>.FACETS.ORGANIZATION_DT
-- Purpose: Incremental transformation of raw provider/org data
-- Pattern: Dynamic Table (replaces stored proc + task)
-- Source: RAW.FACETS (CMC_PRPR_PROV and related tables)
-- ============================================================

CREATE OR REPLACE DYNAMIC TABLE <%silver_database %>.FACETS.ORGANIZATION_DT
    TARGET_LAG = '1 hour'
    WAREHOUSE = COMPUTE_WH
AS
WITH MinNetworkDates AS (
    SELECT
        PRPR_ID,
        MIN(NWPR_EFF_DT) AS Min_NWPR_Date
    FROM <%source_database %>.FACETS.CMC_NWPR_RELATION
    WHERE NWPR_EFF_DT NOT IN ('1900-01-01', '1753-01-01', '9999-12-31')
    GROUP BY PRPR_ID
),
MinRelationDates AS (
    SELECT
        PRPR_ID,
        MIN(PRER_EFF_DT) AS Min_PRER_Date
    FROM <%source_database %>.FACETS.CMC_PRER_RELATION
    WHERE PRER_EFF_DT NOT IN ('1900-01-01', '1753-01-01', '9999-12-31')
    GROUP BY PRPR_ID
),
MinAgreementDates AS (
    SELECT
        nw.PRPR_ID,
        MIN(ag.AGAG_EFF_DT) AS Min_AGAG_Date
    FROM <%source_database %>.FACETS.CMC_NWPR_RELATION nw
    INNER JOIN <%source_database %>.FACETS.CMC_AGAG_AGREEMENT ag
        ON nw.AGAG_ID = ag.AGAG_ID
    WHERE ag.AGAG_EFF_DT NOT IN ('1900-01-01', '1753-01-01', '9999-12-31')
    GROUP BY nw.PRPR_ID
)

SELECT
    ROW_NUMBER() OVER (ORDER BY p.PRPR_ID)::INT AS Org_Key,
    p.PRPR_ID::VARCHAR(50) AS Org_ID,
    p.PRPR_NAME::VARCHAR(255) AS Org_Name,
    NULL::VARCHAR(255) AS Tax_Legal_Name,

    CASE p.PRPR_ENTITY
        WHEN 'I' THEN 'IPA'
        WHEN 'G' THEN 'Provider Group'
        WHEN 'F' THEN 'Facility'
        ELSE 'Other Organization'
    END::VARCHAR(50) AS Org_Type,

    p.PRPR_MCTR_TYPE::VARCHAR(4) AS Org_Subtype_Code,
    mctr.MCTR_DESC::VARCHAR(70) AS Org_Subtype_Desc,

    ''::VARCHAR(255) AS Hierarchy_Path,
    '1'::VARCHAR(10) AS Hierarchy_Level,

    p.MCTN_ID::VARCHAR(50) AS TIN,
    p.PRPR_NPI::VARCHAR(20) AS NPI_Number,
    '2'::VARCHAR(30) AS NPI_Type,

    CASE
        WHEN p.PRPR_STS IN ('P', 'A') THEN 'Active'
        ELSE 'Terminated'
    END::VARCHAR(30) AS Status,

    CAST(
        COALESCE(
            CASE
                WHEN p.PRPR_ENTITY = 'I' THEN LEAST(
                    NULLIF(nw.Min_NWPR_Date, '9999-12-31'::DATE),
                    NULLIF(ag.Min_AGAG_Date, '9999-12-31'::DATE)
                )
                WHEN p.PRPR_ENTITY = 'G' THEN rel.Min_PRER_Date
                WHEN p.PRPR_ENTITY = 'F' THEN nw.Min_NWPR_Date
                ELSE NULL
            END,
            '1900-01-01'
        ) AS DATE
    ) AS Effective_Date,

    COALESCE(CAST(p.PRPR_TERM_DT AS DATE), '9999-12-31'::DATE) AS Termination_Date,

    1 AS Source_System_Key,

    MD5(
        COALESCE(p.PRPR_NAME,'') || '|' ||
        COALESCE(p.PRPR_ENTITY,'') || '|' ||
        COALESCE(p.PRPR_MCTR_TYPE,'') || '|' ||
        COALESCE(p.MCTN_ID,'') || '|' ||
        COALESCE(p.PRPR_NPI,'') || '|' ||
        COALESCE(p.PRPR_STS,'')
    ) AS ROW_HASH,

    CURRENT_TIMESTAMP() AS CREATED_DATE,
    CURRENT_USER() AS CREATED_BY

FROM <%source_database %>.FACETS.CMC_PRPR_PROV p
LEFT JOIN <%source_database %>.FACETS.CMC_MCTR_CD_TRANS mctr
    ON p.PRPR_MCTR_TYPE = mctr.MCTR_VALUE
    AND mctr.MCTR_ENTITY = 'PRAC'
    AND mctr.MCTR_TYPE = 'TYPE'
LEFT JOIN MinNetworkDates nw
    ON p.PRPR_ID = nw.PRPR_ID
LEFT JOIN MinRelationDates rel
    ON p.PRPR_ID = rel.PRPR_ID
LEFT JOIN MinAgreementDates ag
    ON p.PRPR_ID = ag.PRPR_ID
WHERE p.PRPR_ENTITY IN ('I', 'G', 'F');