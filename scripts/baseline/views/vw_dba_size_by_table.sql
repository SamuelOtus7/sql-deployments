-- ============================================================
-- BASELINE: dbo.vw_dba_size_by_table
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dba_size_by_table]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_dba_size_by_table]
as
SELECT top 999999
    s.name AS Esquema,
    t.name AS Tabela,
    t.create_date AS DataCriacao,
    p.Registros,
    CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(18,2)) AS EspacoTotal,
    CAST(
        SUM(a.total_pages) * 1.0 /
        NULLIF((SELECT SUM(size) FROM sys.database_files WHERE type_desc = 'ROWS'), 0) * 100
        AS DECIMAL(5,2)
    ) AS PercentualEspaco,
	max(last_seek) as UltimoSeek,
	max(last_scan) as UltimoScan,
	max(last_lookup) as UltimoLoockup,
	max(last_update) as UltimoUpdate
FROM
    sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    -- Corrige contagem de registros pegando de uma subquery agrupada
    INNER JOIN (
        SELECT object_id, SUM(rows) AS Registros
        FROM sys.partitions
        WHERE index_id IN (0,1)
        GROUP BY object_id
    ) p ON t.object_id = p.object_id
    -- cálculo de espaço
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN sys.partitions pt ON i.object_id = pt.object_id AND i.index_id = pt.index_id
    INNER JOIN sys.allocation_units a ON pt.partition_id = a.container_id
	left join (
-- Último uso por índice (bom proxy)
		SELECT 
		  object_id,
		  MAX(us.last_user_seek)  AS last_seek,
		  MAX(us.last_user_scan)  AS last_scan,
		  MAX(us.last_user_lookup)AS last_lookup,
		  MAX(us.last_user_update)AS last_update
		FROM sys.dm_db_index_usage_stats us
		GROUP BY object_id
	) as ultimo_uso
	on t.object_id = ultimo_uso.object_id
GROUP BY
    s.name, t.name, t.create_date, p.Registros
ORDER BY
    5 DESC;
	
GO
