-- ============================================================
-- Data Platform: Incremental CAB-Gated
-- Object: ORGANIZATION_VW (Gold View)
-- Target: &gold_database.DIMENSIONS.ORGANIZATION_VW
-- Purpose: Always reflects latest Silver Dynamic Table data
-- Pattern: View (no compute cost, no scheduling needed)
-- Source: &silver_database.FACETS.ORGANIZATION_DT
-- ============================================================

CREATE OR REPLACE VIEW <%gold_database %>.DIMENSIONS.ORGANIZATION_VW AS
SELECT
    Org_Key,
    Org_ID,
    Org_Name,
    Tax_Legal_Name,
    Org_Type,
    Org_Subtype_Code,
    Org_Subtype_Desc,
    Hierarchy_Path,
    Hierarchy_Level,
    TIN,
    NPI_Number,
   -- NPI_Type,
    Status,
    Effective_Date,
    Termination_Date,
    Source_System_Key,
    ROW_HASH,
    CREATED_DATE,
    CREATED_BY
FROM <%silver_database %>.FACETS.ORGANIZATION_DT;