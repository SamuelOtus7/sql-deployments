-- ============================================================
-- BASELINE: dbo.vw_operacoes_bases
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_operacoes_bases]    Script Date: 14/09/2026 12:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_operacoes_bases]
as
select
	b.bss_cod_cliente CodigoCliente
	,b.bss_ds_marketplace MarketPlace
	,b.bss_ds_sigla ServiceCenter
	,l.lst_cd_lista CodigoOperacao
	,l.lst_ds_label Operacao
from
	tb_bases b
	join tb_operacoes_bases ob on b.bss_cd_base = ob.opb_cd_base
	join tb_lista l on ob.opb_cd_operacao = l.lst_cd_lista
where
	b.bss_in_status = 1 
	and b.bss_in_excluido = 0
GO
