-- ============================================================
-- BASELINE: dbo.vw_coletar_detalhe_pacotes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_coletar_detalhe_pacotes]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_coletar_detalhe_pacotes]
as
--select distinct
--		   pacotes.IdTransportadora,
--		   pacotes.IdPacote,
--		   pacotes.DataReferencia
--	from tb_ml_pacotes as pacotes with(nolock)
--		left join tb_ml_detalhes_pacotes as detalhes with(nolock)
--		on pacotes.IdPacote = detalhes.IdPacote
--        inner join tb_clientes as cli with(nolock)
--        on pacotes.IdTransportadora = cli.cli_id_logistics
--	where DataReferencia >= '2025-09-01'
--		 -- and pacotes.IdTransportadora in( 643493085)
--		--  and StatusEntrega = 'not_delivered'
--		  and detalhes.IdPacote is null
--		--   and pacotes.IdPacote = 44492953024
--          and Excluido = 0
--          and cli.cli_in_ativo = 1

--		--  and DataReferencia >='2025-08-01' 
WITH base AS (
    SELECT
        p.IdTransportadora,
        p.IdPacote,
        p.DataReferencia,
        ROW_NUMBER() OVER (
            PARTITION BY p.IdTransportadora, p.IdPacote
            ORDER BY 
                p.DataReferencia DESC,
                -- desempate determinístico (ajuste para um campo de auditoria se houver):
                p.IdPacote
                -- exemplo: , p.IdRegistro DESC
        ) AS rn
    FROM dbo.tb_ml_pacotes AS p
    LEFT JOIN dbo.tb_ml_detalhes_pacotes AS d
        ON d.IdPacote = p.IdPacote
    INNER JOIN dbo.tb_clientes AS cli
        ON cli.cli_id_logistics = p.IdTransportadora
    WHERE   p.DataReferencia >= '2025-09-01' 
      	  
	  AND p.Excluido = 0
      AND cli.cli_in_ativo = 1
	  and p.idtransportadora  in (1025381599)
      AND d.TelefoneContato1 IS NULL  -- sem relacionamento em detalhes
      AND (
            p.StatusEntrega = 'not_delivered'
            --OR NOT EXISTS (SELECT 1
            --               FROM dbo.tb_ml_pnr AS pnr
            --               WHERE pnr.IdPacote = p.IdPacote)
          )
)
SELECT distinct top 0
    IdTransportadora,
    IdPacote,
    DataReferencia
FROM base
WHERE rn = 1;
GO
