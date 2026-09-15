-- ============================================================
-- BASELINE: dbo.vw_rel_ambulancias
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rel_ambulancias]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*and RecebMeli > 0
--and r.idtransportadora  = 1731064496*/
CREATE VIEW [dbo].[vw_rel_ambulancias]
AS
SELECT   cli.cli_cd_codigo_cliente AS TenantId, r.IdRota, r.DataReferencia, r.NomeMotorista, r.TipoVeiculo, r.Placa, CASE WHEN r.ServiceCenter <> r.OrigemSaida OR
                LEFT(OrigemSaida, 1) <> 'B' THEN r.OrigemSaida ELSE r.ServiceCenter END AS Base, amb.amb_pagamento AS Pagamento, r.TotalPacotes, r.PacotesEntregues, ISNULL(receb.RecebMeli, 0) AS RecebMeli, amb.amb_svc, amb.amb_id_motorista, 
                CASE WHEN amb.amb_motivo IS NULL THEN 'Sem motivo' ELSE amb.amb_motivo END AS Motivo, 
                CASE WHEN amb.amb_pagamento = '0' THEN 'Pendente de análise' WHEN amb.amb_pagamento = 'Sim' THEN 'Pagamento aprovado' WHEN amb.amb_pagamento = 'Não' THEN 'Pagamento recusado' ELSE 'Situação desconhecida' END AS StatusPagamento,
        cast(amb_data_etl as date) Atualizacao
FROM      dbo.tb_ml_rotas AS r WITH (NOLOCK) LEFT OUTER JOIN
                dbo.tb_fin_resultado_financeiro AS receb ON CAST(r.IdRota AS varchar(50)) = receb.IdRota INNER JOIN
                dbo.tb_looker_ambulancias AS amb ON amb.amb_id_rota = r.IdRota INNER JOIN
                dbo.tb_clientes AS cli ON r.IdTransportadora = cli.cli_id_logistics
WHERE   (1 = 1) AND (r.Excluido = 0) AND (r.StatusRota <> 'planned')

GO
