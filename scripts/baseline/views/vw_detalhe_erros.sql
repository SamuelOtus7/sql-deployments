-- ============================================================
-- BASELINE: dbo.vw_detalhe_erros
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_detalhe_erros]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_detalhe_erros]
as
select  
 case when a.dec_cd_transportadora = cli_id_logistics then 'Mercado Livre' else 'Shopee' end as MarketPlace,
 b.cli_ds_nome
,dec_ds_tipo_coleta
,dec_ds_contexto
,dec_ds_erro
,dec_dt_referencia
,dec_dh_coleta
,dec_dh_escrita
,dec_nr_tentativas
from tb_dra_erros_coleta a
	join tb_clientes b on a.dec_cd_transportadora = cli_id_logistics or a.dec_cd_transportadora = cli_id_shopee
where dec_dt_referencia = cast(getdate() as date)
GO
