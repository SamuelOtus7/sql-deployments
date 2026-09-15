-- ============================================================
-- BASELINE: dbo.fn_espelhos
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_espelhos]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_espelhos]
(
    @IdPeriodo int null
) 
RETURNS TABLE
AS
RETURN
select 
	mtn_cd_motorista_nfs
	,mtn_cd_motorista
	,mtn_cd_pgto_periodo
	,mtn_cd_status
	,mtn_vl_nfs
	,mtn_ds_link_nfs
	,mtn_dt_prazo_contestacao
	,mtn_dh_criacao
	,mtn_cd_usr_criacao
	,mtn_dh_modificacao
	,mtn_cd_usr_modificacao
	,mtn_in_excluido
	,mtn_cod_cliente
	,mtn_qt_rotas
	,mtn_cd_tipo_espelho
	,mtn_cd_cliente_transportadora
	,mtn_cd_base
	,mtn_in_gerar_pdf
	,mtn_ds_linkespelho
	,mtn_base_principal
	,mtn_nome_motorista
	,mtn_cd_status_pdf_massa
	,mtn_dt_data_criacao_pdf_massa
	,mtn_dh_envio_nfs
	,mtn_dh_envio_push_notification
	,mtn_vl_imposto
	,mtn_vl_liquido
	,mtn_ds_link_nfs_secundario
	,mtn_dh_envio_nfs_secundario
	,mtn_in_zerar_espelho
	,mtn_vl_desconto
	,mtn_cd_operacao
	,cast(case when b.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else b.pgp_dt_inicio end as datetime)  as DataAtualizacaoControlePowerBI
from tb_pag_espelhos as a
inner join tb_pgto_periodo as b with(nolock)
on a.mtn_cd_pgto_periodo = b.pgp_cd_periodo

where mtn_cd_pgto_periodo >= 370 
and (@IdPeriodo is null or mtn_cd_pgto_periodo = @IdPeriodo)
GO
