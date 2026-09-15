-- ============================================================
-- BASELINE: dbo.vw_Marketplace_periodo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_Marketplace_periodo]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_Marketplace_periodo] AS
SELECT
    p.pep_cd_periodo_pagamento AS CodPeriodoPagamento,
    lt.lst_ds_valor AS ClienteTransportadora,
    lo.lst_ds_valor AS Operacao
FROM tb_periodos_espelhos_pagamento p
JOIN tb_lista lt 
    ON lt.lst_cd_lista = p.pep_cd_cliente_transportadora
JOIN tb_lista lo 
    ON lo.lst_cd_lista = p.pep_cd_operacao;
GO
