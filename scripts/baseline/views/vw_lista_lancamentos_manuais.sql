-- ============================================================
-- BASELINE: dbo.vw_lista_lancamentos_manuais
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lista_lancamentos_manuais]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- dbo.vw_lista_lancamentos_manuais fonte

-- dbo.vw_lista_lancamentos_manuais fonte

-- dbo.vw_lista_lancamentos_manuais fonte

-- dbo.vw_lista_lancamentos_manuais fonte

-- dbo.vw_lista_lancamentos_manuais fonte

-- dbo.vw_lista_lancamentos_manuais fonte

-- dbo.vw_lista_lancamentos_manuais fonte

CREATE       view [dbo].[vw_lista_lancamentos_manuais]
as
select
	l.tlm_cd_lancamento_manual IdLancamentoManual
	,l.tlm_cd_cliente CodigoCliente
	,case when l.tlm_cd_rota = 'null' then null else l.tlm_cd_rota end Rota
	,cast(l.tlm_dh_referencia as date) DataReferencia
	,l.tlm_cd_service_center ServiceCenter
	,t.plm_nm_tipo TipoLancamento
	,case when l.tlm_ds_placa = 'null' then null else l.tlm_ds_placa end Placa
	,l.tlm_cd_motorista MotoristaOriginal
	,l.tlm_ds_motorista_apoio MotoristaApoio
	,l.tlm_in_marketplace Marketplace
	,l.tlm_cd_tipo Tipo
	,l.tlm_cd_periodo Periodo
	,l.tlm_cd_risco_ajudante RiscoAjudante
	,l.tlm_cd_quantidade_pacotes QuantidadePacotes
	,l.tlm_cd_pontos Pontos
	,l.tlm_ds_observacao Observacao
	,l.tlm_cd_transportadora CodTransportadora
	,l.tlm_cd_tipo_veiculo_nao_utilizado CodTipoVeiculoNaoUtilizado
	,l.tlm_dh_nao_utilizado DhNaoUtilizado
	,l.tlm_ds_motorista_secundario MotoristaSecundario
	,l.tlm_tipo_valor_apoio TipoValorApoio
	,l.tlm_cd_arquivo CodArquivo
	,l.tlm_cd_cliente_transportadora CodClienteTransportadora
	,l.tlm_in_ativo Ativo
	,lt.lst_ds_label TipoOperacaoName
	,l.tlm_cd_operacao TipoOperacao
	,u.usr_nm_usuario UsuarioCriacao
	,l.tlm_dh_criacao DataHoraCriacao
	,u2.usr_nm_usuario UsuarioAprovacao
	,a.alm_dh_aprovacao DataAprovacao
	,a.alm_ds_status StatusLancamento
	,isnull(l.tlm_vl_valor_apoio,0) + isnull(l.tlm_vl_valor_rota,0) + ISNULL(l.tlm_vl_valor_adicional,0) + ISNULL(l.tlm_vl_valor_descontos*-1,0) ValorLancamento
	,isnull(l.tlm_vl_valor_apoio,0) ValorApoio
	,isnull(l.tlm_vl_valor_rota,0) ValorRota
	,ISNULL(l.tlm_vl_valor_adicional,0) ValorAdicional
	,ISNULL(l.tlm_vl_valor_descontos*-1,0) ValorDescontos
	,isnull(p.PeriodoPagamento,p2.PeriodoPagamento) PeriodoPagamento
	,isnull(p.StatusPagamento,p2.StatusPagamento) StatusPagamento
	,m.Matricula
	,m.CodigoMotorista
	,m.Banco
	,m.NomeTitular
	,m.CpfTitular
	,m.CnpjTitular
	,m.Agencia
	,m.Conta
	,m.TipoConta
	,m.TipoChavePix
	,m.ChavePix
	,l.tlm_tp_credito_debito as TipoPagamento
	,p2.PeriodoPagamentoCod as PeriodoPagamentoCod
from
	tb_lancamentos_manuais l with(nolock)
	left join tb_tipos_lancamentos_manuais t with(nolock) on l.tlm_cd_tipo = t.plm_cd_tipo_lancamento_manual  
	left join tb_usuario u with(nolock) on l.tlm_cd_usuario_criacao = u.usr_cd_usuario
	left join tb_aprovacao_lancamento_manual a with(nolock) on l.tlm_cd_lancamento_manual = a.alm_cd_lancamento_manual   
	left join tb_usuario u2 with(nolock) on a.alm_cd_usuario_aprovacao = u2.usr_cd_usuario
	left join tb_lista lt with(nolock) on l.tlm_cd_operacao = lt.lst_cd_lista
	left join vw_dados_motoristas m on --l.tlm_cd_motorista = m.Motorista 
								--and l.tlm_cd_cliente = m.IdCliente
								--and m.OrdemNomeMotorista = 1
								l.tlm_cd_mot = m.CodigoUsuario
								
	left join (
		select
			per.pgp_cd_cliente IdCliente
			,pgp_nm_periodo PeriodoPagamento
			,lt2.lst_ds_label StatusPagamento
			,ppr_lcto_cd_lancamento
			,ROW_NUMBER() over (partition by per.pgp_cd_cliente, ppr_lcto_cd_lancamento order by per.pgp_dt_inicio desc) as PagamentoLancamentoAtual
			,pgp_cd_periodo PeriodoPagamentoCod
		from
			tb_pgto_periodo_rota p with(nolock)
			join tb_pag_espelhos esp with(nolock) on p.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
			left join tb_lista lt2 with(nolock) on esp.mtn_cd_status = lt2.lst_cd_lista
			join tb_pgto_periodo per with(nolock) on p.ppr_cd_periodo = per.pgp_cd_periodo 
		where
			p.ppr_in_excluido = 0
			and esp.mtn_in_excluido = 0
			and per.pgp_cd_status = 1
			and per.pgp_in_excluido = 0
			and p.ppr_lcto_cd_lancamento is not null
	) p on l.tlm_cd_lancamento_manual = p.ppr_lcto_cd_lancamento and t.plm_nm_tipo <> 'Apoio' and p.PagamentoLancamentoAtual = 1 and l.tlm_cd_cliente = p.IdCliente
	left join (
		select
			per.pgp_cd_cliente IdCliente
			,pgp_nm_periodo PeriodoPagamento
			,lt2.lst_ds_label StatusPagamento
			,ppr_cd_rota
			,ROW_NUMBER() over (partition by per.pgp_cd_cliente, ppr_cd_rota order by per.pgp_dt_inicio desc) as PagamentoRotaAtual
			,pgp_cd_periodo PeriodoPagamentoCod
		from
			tb_pgto_periodo_rota p with(nolock)
			join tb_pag_espelhos esp with(nolock) on p.ppr_cd_motorista_nfs = esp.mtn_cd_motorista_nfs
			left join tb_lista lt2 with(nolock) on esp.mtn_cd_status = lt2.lst_cd_lista
			join tb_pgto_periodo per with(nolock) on p.ppr_cd_periodo = per.pgp_cd_periodo 
		where
			p.ppr_in_excluido = 0
			and esp.mtn_in_excluido = 0
			and per.pgp_cd_status = 1
			and per.pgp_in_excluido = 0
			and p.ppr_cd_rota is not null
			and ppr_lcto_cd_lancamento is null
	) p2 on l.tlm_cd_rota = p2.ppr_cd_rota and l.tlm_cd_rota <> 'null' and p2.PagamentoRotaAtual = 1 and l.tlm_cd_cliente = p2.IdCliente
where
	tlm_in_ativo = 1
	and tlm_in_excluido = 0;
GO
