-- ============================================================
-- BASELINE: dbo.vw_adiantamentos_aprovados
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_adiantamentos_aprovados]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_adiantamentos_aprovados]
as
select
	lan.tlm_cd_cliente IdCliente
	,m.CnpjEmpresa
	,m.NomeTitular
	,m.CnpjTitular
	,m.CpfTitular
	,m.Banco
	,m.Agencia
	,m.TipoConta
	,m.Conta
	,m.TipoChavePix
	,m.ChavePix
	,lan.tlm_cd_lancamento_manual CodigoLancamento
	,lan.tlm_cd_rota Rota
	,lan.tlm_cd_Motorista Motorista
	,lan.tlm_cd_service_center ServiceCenter
	,r.DataReferencia DataRota
	,cast(lan.tlm_dh_referencia as date) DataAdiantamento
	,lan.tlm_vl_valor_descontos ValorAdiantado
from 
	(select 
		tlm_cd_lancamento_manual 
		,tlm_cd_rota
		,tlm_cd_Motorista
		,tlm_cd_service_center
		,tlm_dh_referencia
		,tlm_vl_valor_descontos
		,tlm_cd_cliente
	from 
		tb_lancamentos_manuais with(nolock) 
	where 
		tlm_cd_cliente = 11 
		and tlm_cd_tipo = 233 
		and tlm_cd_rota <> 'null'
		and try_cast(tlm_cd_rota as int) is not null
	) lan
	join tb_aprovacao_lancamento_manual apr with(nolock) on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
	join vw_rotas r on lan.tlm_cd_rota = r.idrota
	left join vw_dados_motoristas m on r.UsuarioDA = m.CodigoUsuario and lan.tlm_cd_cliente = m.IdCliente
where 
	apr.alm_ds_status = 'Aprovado'
GO
