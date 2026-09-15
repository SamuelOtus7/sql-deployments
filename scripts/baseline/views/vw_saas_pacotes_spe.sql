-- ============================================================
-- BASELINE: dbo.vw_saas_pacotes_spe
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_pacotes_spe]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_saas_pacotes_spe]
as
SELECT
    IdRotaInterno
    --,CodigoRota
    ,IdTransportadora
    ,CodigoPacote
    ,DataReferencia
    ,StatusEntrega
    ,SubStatus
    ,DataHoraEntrega
    --,DataAtualizacao
    --,URLImagem
    ,StatusEntregaShopee
    ,SubStatusShopee
    ,CEP
    ,StatusPacote
    ,CicloPM
    ,Turno
FROM 
    vw_pacotes_spe_v4 WITH(NOLOCK)
where
    DataReferencia >= DATEADD(MONTH, -3, GETDATE())
GO
