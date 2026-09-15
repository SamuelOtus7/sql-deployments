-- ============================================================
-- BASELINE: dbo.vw_bases
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_bases]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_bases] AS

select 
    bss_ds_marketplace	
    ,bss_cod_cliente	
    ,bss_cd_idtransportadora
    ,bss_ds_sigla	
    ,bss_ds_label
    ,bss_ds_nome
    ,bss_ds_nome_amigavel	
    ,bss_ds_regiao	
    ,bss_ds_cidade	
    ,bss_ds_estado
    ,bss_dc_longitude	
    ,bss_in_xpt

from tb_bases
where bss_in_excluido = 0
GO
