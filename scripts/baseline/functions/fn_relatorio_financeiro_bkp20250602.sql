-- ============================================================
-- BASELINE: dbo.fn_relatorio_financeiro_bkp20250602
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_relatorio_financeiro_bkp20250602]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fn_relatorio_financeiro_bkp20250602](
    @IdPeriodo int null,
    @Rota varchar(50) null
) 
RETURNS TABLE
AS
RETURN

--declare @idperiodo int = 393
--, @rota int = null

select distinct 
     ppr_cd_pagamento_rota
    ,cli_cd_codigo_cliente as TenantId
    ,ppr_cd_periodo
    ,pgp_nm_periodo
	,mtn_cd_status as Status
	,cast(mtn_dt_prazo_contestacao as date) as DataContestacao
	,case when getdate() >= mtn_dt_prazo_contestacao  
				then 0 else DATEDIFF(day,getdate(), cast(mtn_dt_prazo_contestacao as date)) end as DiasContestacao
    ,ppr_data_referencia    as Data
    ,ppr_nome_motorista     as Motorista
	,ppr_cd_motorista		as Usuario
    ,ppr_cd_rota            as Rota
    ,ppr_base_principal     as SVC
    ,ppr_cd_faixa_km        as Faixa_KM
    ,ppr_ds_tipo_veiculo    as Tipo_Veiculo
	,ppr_nm_cidade 	        as Cidade
    ,ppr_ds_ciclo	        as Ciclo
    ,pre.CicloPM          as CicloPMFatura
    ,ppr_qt_pacotes	        as Pacotes
    ,ppr_qt_pacotes_entregues as PacotesEntregues
    ,ppr_qt_pontos	    as Pontos
    ,ppr_qt_paradas     as QuantidadeParadas
    ,ppr_vl_base	    as Base
    ,ppr_vl_paradas	    as Paradas
    ,ppr_vl_risco	    as Risco
    ,ppr_vl_ajudante    as Ajudante	
    ,ppr_vl_dom_fer	    as Dom_Fer
    ,ppr_vl_lancamentos as Lancamentos
    ,ppr_vl_bonus       as Bonus
    ,ppr_vl_total       as Total
    ,c.RecebMeli        as RecebMeli
    ,c.RecebimentoParadas as RecebimentoParadas
    ,c.RecebimentoRisco as RecebimentoRisco
    ,c.RecebimentoDomingo as RecebimentoDomingo
    ,c.ValorFinal - ppr_vl_total as DeltaRecebPagto
    
    ,case when ppr_vl_base = 0 or ppr_vl_base is null then 1 else 0 end as Base_Zerado
    ,case when ppr_vl_base > 0 then 1 else 0 end as Base_Com_Valor
    ,case when ppr_vl_paradas = 0 or ppr_vl_paradas is null then 1 else 0 end as Parada_Zerado
    ,case when ppr_vl_paradas > 0 then 1 else 0 end as Parada_Com_Valor
    ,case when ppr_cd_rota is not null then 1 else 0 end  as TotalRotas
    
    --crie um case when para validar os case acima e me indique o status de retorno
    ,case when ppr_vl_base = 0 or ppr_vl_base is null then 'Base Zerado'
    when ppr_vl_base > 0 then 'Base Com Valor'
    when ppr_vl_paradas = 0 or ppr_vl_paradas is null then 'Parada Zerado'
    when ppr_vl_paradas > 0 then 'Parada Com Valor'
    when ppr_cd_rota is not null then 'Total Rotas'
    when ppr_vl_base > 0 and ppr_vl_paradas > 0 and ppr_cd_rota is not null then 'Tudo Certo'
    else 'Validar' end as StatusPagamento

    ,case when pre.Total = 0 then 1 else 0 end as RecebMeli_Zerado
    ,case when pre.Total > 0 then 1 else 0 end as RecebMeli_Com_Valor
    ,case when VLParada = 0 then 1 else 0 end as RecebimentoParadas_Zerado
    ,case when VLParada > 0 then 1 else 0 end as RecebimentoParadas_Com_Valor
    ,case when RecebimentoRisco = 0 then 1 else 0 end as RecebimentoRisco_Zerado
    ,case when RecebimentoRisco > 0 then 1 else 0 end as RecebimentoRisco_Com_Valor 
    ,case when RecebimentoDomingo = 0 then 1 else 0 end as RecebimentoDomingo_Zerado
    ,case when RecebimentoDomingo > 0 then 1 else 0 end as RecebimentoDomingo_Com_Valor
    ,case when pre.Total > 0 and VLParada > 0  then 1 else 0 end as RecebimentoTotal
    ,case when pre.Total > 0 and VLParada > 0  then 'Tudo Certo' else 'Validar' end as StatusRecebimento

    ,pre.total as RecebimentoPrefatura
    ,0 AusenteIrisys
    ,ppr_dh_modificacao as DataAtualizacao
	,pre.ServiceCenter as SVCPreFatura
	,pre.IntervaloFaixa as FaixaPreFatura
	,pre.Veiculo + case when pre.ContinuacaoVeiculo is not null then ' - ' + pre.ContinuacaoVeiculo else '' end TipoVeiculoPreFatura
	,ppr_total_km as KmTotal
	,case when ppr_total_km > 100 then ppr_total_km-100 else 0 end  as KmTotalExcedente
	,ppr_vl_desconto  Desconto
	,ppr_lcto_observacao Observacao
	,ppr_ds_placa Placa
    --,cast(ppr_dh_modificacao as date) as DataAtualizacaoControlePowerBI
    ,cast(case when b.pgp_dt_inicio >= dateadd(day,-60,cast(getdate() as date)) then cast(getdate() as date) else b.pgp_dt_inicio end as datetime) DataAtualizacaoControlePowerBI
	,case when pre.KmCiclo = 'AMBULANCE' then 'Sim' else 'Não' end AmbulanciaPreFatura
	,ppr_vl_pedagio Pedagio
	,ppr_vl_recarga AS RecargaEletrica
	,case when isnull(ppr_vl_lancamentos,0) > 0 then ppr_vl_lancamentos end LancamentosPositivos
	,case when ppr_vl_lancamentos < 0 then ppr_vl_lancamentos end LancamentosNegativos
	,m.Banco
	,m.NomeTitular
	,m.CpfTitular
	,m.CnpjTitular
	,m.Agencia
	,m.Conta
	,m.TipoConta
	,m.TipoChavePix
	,m.ChavePix
	,adiantamentos.ValorAdiantado
	,ppr_vl_total - isnull(adiantamentos.ValorAdiantado,0) TotalLiquido
	,case when ppr_ds_tipo_veiculo is not null or pre.Veiculo is not null then case when ppr_ds_tipo_veiculo = pre.Veiculo + case when pre.ContinuacaoVeiculo is not null then ' - ' + pre.ContinuacaoVeiculo else '' end then 'Igual' else 'Diferente' end end ValidacaoVeiculoPreFatura
	,a.ppr_nm_cluster
	,a.ppr_total_km_meli
	,a.ppr_total_km_rtt
	,m.CnpjEmpresa
	,m.RazaoSocial
	,m.NomeFantasia

from tb_pgto_periodo_rota a with(nolock)

inner join tb_pag_espelhos as pag
on ppr_cd_motorista_nfs = mtn_cd_motorista_nfs

inner join tb_pgto_periodo as b with(nolock)
on a.ppr_cd_periodo = b.pgp_cd_periodo

left join tb_clientes as cli
on b.pgp_cd_cliente = cli.cli_cd_codigo_cliente

left join vw_resultado_financeiro as c
on a.ppr_cd_rota = c.IdRota

left join tb_fin_prefatura as pre with(nolock)
on a.ppr_cd_rota = pre.IdRota

--Inclusão para pegar dados de pagamentos dos motoristas solicitado pela 50+
left join vw_dados_motoristas m on a.ppr_cd_motorista = m.CodigoUsuario and b.pgp_cd_cliente = m.IdCliente

--Inclusão de adiantamentos da 50+ enquanto o módulo não é desenvolvido. Esses tipos de lançamentos não são inclusos no cálculo de pagamentos
left join (select
			lan.tlm_cd_rota Rota
			,sum(lan.tlm_vl_valor_descontos) ValorAdiantado
		from 
			tb_lancamentos_manuais lan with(nolock)
			join tb_aprovacao_lancamento_manual apr with(nolock) on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
		where 
			lan.tlm_cd_cliente = 11
			and lan.tlm_cd_tipo = 233
			and apr.alm_ds_status = 'Aprovado'
			and lan.tlm_cd_rota <> 'null'
		group by
			lan.tlm_cd_rota
) adiantamentos on a.ppr_cd_rota = adiantamentos.Rota and b.pgp_cd_cliente = 11



where pgp_cd_status = 1
and pgp_cd_periodo >= 370 
and (@IdPeriodo is null or ppr_cd_periodo = @IdPeriodo)
--and (ppr_cd_periodo = 393)
and (@Rota is null or ppr_cd_rota = @Rota)
and ppr_in_excluido = 0 
and (b.pgp_in_excluido = 0 or pgp_cd_periodo = 625)
--and ppr_cd_rota is not null

--union all

--select  
--    null ppr_cd_pagamento_rota
--    ,periodo.idtransportadora
--    ,pgp_cd_periodo
--    ,pgp_nm_periodo
--    ,pre.DataInicio
--    ,pre.Motorista
--    ,pre.IdRota
--    ,pre.ServiceCenter
--    ,pre.IntervaloFaixa
--    ,pre.veiculo
--    ,null cidade
--    ,null ciclo
--    ,pre.CicloPM as CicloPMFatura
--    ,null Pacotes
--    ,null PacotesEntregues
--    ,null Pontos
--    ,null QuantidadeParadas
--    ,null Base
--    ,null Paradas
--    ,null Risco
--    ,null Ajudante
--    ,null Dom_Fer
--    ,null Lancamentos
--    ,null Bonus
--    ,null Total
--    ,null RecebMeli
--    ,null RecebimentoParadas
--    ,null RecebimentoRisco
--    ,null RecebimentoDomingo
--    ,null DeltaRecebPagto
--    ,null Base_Zerado
--    ,null Base_Com_Valor
--    ,null Parada_Zerado
--    ,null Parada_Com_Valor
--    ,null TotalRotas
--    ,null StatusPagamento
--    ,null RecebMeli_Zerado
--    ,null RecebMeli_Com_Valor
--    ,null RecebimentoParadas_Zerado
--    ,null RecebimentoParadas_Com_Valor
--    ,null RecebimentoRisco_Zerado
--    ,null RecebimentoRisco_Com_Valor
--    ,null RecebimentoDomingo_Zerado
--    ,null RecebimentoDomingo_Com_Valor
--    ,null RecebimentoTotal
--    ,null StatusRecebimento
--    ,pre.Total RecebimentoPrefatura
--    ,1 AusenteIrisys
--    ,DataAtualizacao
--	,null ServiceCenter
--	,null FaixaPreFatura
--	,null TipoVeiculoPreFatura
--	,0 as KmTotal
--	,0 as KmTotalExcedente

--from (
--SELECT 
--     DataInicio
--    ,Motorista
--    ,IdRota
--    ,ServiceCenter
--    ,IntervaloFaixa
--    ,veiculo
--    ,Total
--    ,cli_cd_codigo_cliente idtransportadoraFiltro
--    ,DataAtualizacao
--    ,CicloPM
--from tb_fin_prefatura  as a with(nolock)
--inner join tb_clientes  as b 
--on a.idtransportadora = b.cli_id_logistics
    
--union all 

--select  

--     DataEntrega DataInicio
--    ,null Motorista
--    ,Rota IdRota
--    ,Hub ServiceCenter
--    ,null IntervaloFaixa
--    ,TipoVeiculo as veiculo
--    ,TarifaAplicada
--    ,cli_cd_codigo_cliente idtransportadoraFiltro
--    ,getdate() DataAtualizacao
--    ,null CicloPM

--from tb_fin_spe_prefatura as a
--inner join tb_clientes  as b 
--    on a.idtransportadora = b.cli_id_shopee

--) as pre
--inner JOIN
--(
--    select 
--        pgp_cd_periodo
--        ,pgp_nm_periodo
--        ,pgp_dt_inicio
--        ,pgp_dt_fim
--        ,pgp_cd_cliente as idtransportadora
        
--    from tb_pgto_periodo as a
--    inner join tb_clientes as b on a.pgp_cd_cliente = b.cli_cd_codigo_cliente
--    where pgp_cd_periodo > 250
--   -- and  pgp_cd_periodo = 161
--    and pgp_cd_status = 1

--) as periodo 
--on pre.idtransportadoraFiltro = periodo.idtransportadora

--left join tb_pgto_periodo_rota as pgto  with(nolock)
--on pgto.ppr_cd_rota = pre.idrota
--and periodo.pgp_cd_periodo = pgto.ppr_cd_periodo

--where  pre.datainicio between periodo.pgp_dt_inicio and periodo.pgp_dt_fim
--and pgto.ppr_cd_rota is null
--and  (@IdPeriodo is null or ppr_cd_periodo = @IdPeriodo)
--and (@Rota is null or ppr_cd_rota = @Rota)
--and ppr_in_excluido = 0 
GO
