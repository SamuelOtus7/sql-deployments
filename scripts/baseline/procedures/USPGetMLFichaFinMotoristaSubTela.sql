-- ============================================================
-- BASELINE: dbo.USPGetMLFichaFinMotoristaSubTela
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USPGetMLFichaFinMotoristaSubTela]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[USPGetMLFichaFinMotoristaSubTela] (
      @Transportadora int
    , @periodo VARCHAR(50)
    , @ServiceCenter VARCHAR(50)
) as 

-- declare 
--       @Transportadora int = 2087146923
--     , @ano int = 2024
--     , @mes int = 03
--     , @quinzena int = 2
--     , @ServiceCenter VARCHAR(50) = 'SMG8'
--     , @periodo VARCHAR(50) = 'Período Março Q2'
--     , @dataini date 
--     , @datafim date 

    declare @dataini date 
    , @datafim date 


set @dataini = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_cliente = 1 and pgp_nm_periodo  = @periodo)
set @datafim = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_cliente = 1 and pgp_nm_periodo  = @periodo)

drop table if exists #vw_resultado_financeiro
select top 50 * 
into #vw_resultado_financeiro
from vw_resultado_financeiro 
where IdTransportadora = @Transportadora
and DataReferencia between @dataini and @datafim
and ServiceCenter = @ServiceCenter
-- and pgtosaida > 0

-- select idrota, COUNT(*) from #vw_resultado_financeiro group by idrota having COUNT(*) > 1

select 
    --top 10 

    --dados gerais
     DataReferencia
    -- ,pgto.pgp_dt_inicio 
    -- ,pgto.pgp_dt_fim
    ,a.IdRota
    ,ServiceCenter
    ,'' XPT
    ,'' StatusRota	
    ,a.TipoVeiculo
    ,'' as RotaDividida
    ,a.FaixaKm
    ,CicloPM
    ,a.Motorista
    ,'' as placa
    ,'' as PossuiAjudante
    
    --Pacotes
    ,PacotesEntregues
    ,QuantidadeParadas
    ,QuantidadePacotes
    ,Insucessos
    ,NULLIF(PacotesEntregues,0) / CAST(NULLIF(QuantidadePacotes,0) as decimal(5,2)) as SuccessDelivery
    ,Pendentes
    ,TxAdicionalRisco
    
    --valores de pagamento
    ,PgtoSaida+PgtoParadas+PgtoRisco+PgtoAjudante PagtoTotal
    ,PgtoSaida
    ,PgtoSaidaKmMotorista
    ,PgtoSaidaKm0a100
    ,PgtoParadas
    ,PgtoRisco
    ,PgtoAjudante
    ,PgtoLancamentoManual
    ,MotivoPgtoLancamentoManual

    --informações base frete
    ,b.[bfm_vl_frete] as ValorFaixaKM
    ,b.TipoVeiculo
	,c.adicional_domingo
	,c.adicional_ciclo_pm
	,c.paradas0_60
	,c.paradas61_75
	,c.paradas76_85
	,c.paradas86_90
	,c.paradas_acima_90
	,c.adicional_ajudante
	,c.adicional_risco
	,c.insucesso

    --lancamentos manuais
    ,lancamentos.Data
    ,lancamentos.DataCriacao
    ,lancamentos.Ciclo
    ,lancamentos.Tipo
    ,lancamentos.RiscoAjudante 
    ,lancamentos.TotalPacotes
    ,lancamentos.Pontos
    ,lancamentos.observacao
    ,lancamentos.UsuarioCadastro
    ,lancamentos.DataModificao
    ,lancamentos.UsuarioModificao
    ,lancamentos.MotoristaApoio
    ,lancamentos.TipoValorApoio
    ,lancamentos.ValorApoio
    ,lancamentos.VeiculoNaoUtilizado
    ,lancamentos.DataNaoUtilizado

from vw_resultado_financeiro as a
left join (
    
			select 
				[a].[bfm_cd_transportadora],
				isnull([a].[bfm_cd_service_center],[a].[bfm_nm_cidade]) as base,				
				[b].[tvl_nm_tipo_veiculo] as TipoVeiculo,
				cast([a].[bfm_vl_inicio_faixa] as varchar(5)) + '/' + cast([a].[bfm_vl_fim_faixa] as varchar(5)) as FaixaKM,
				[a].[bfm_vl_frete]

			from tb_fin_base_frete_motorista as a

			inner join tb_dra_tipo_veiculo as b
			on a.bfm_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo

) as b
on a.TipoVeiculo = b.TipoVeiculo
and a.IdTransportadora = b.bfm_cd_transportadora
and a.ServiceCenter = b.base
and a.FaixaKm = b.FaixaKM

left join (


SELECT 
	 a.bfa_cd_transportadora
	,a.bfa_cd_service_center as base
	,b.[tvl_nm_tipo_veiculo] as TipoVeiculo
	,a.bfa_vl_adicional_domingo		adicional_domingo
	,a.bfa_vl_adicional_ciclo_pm	adicional_ciclo_pm
	,a.bfa_vl_paradas0_60			paradas0_60
	,a.bfa_vl_paradas61_75			paradas61_75
	,a.bfa_vl_paradas76_85			paradas76_85
	,a.bfa_vl_paradas86_90			paradas86_90
	,a.bfa_vl_paradas_acima_90		paradas_acima_90
	,a.bfa_vl_adicional_ajudante	adicional_ajudante
	,a.bfa_vl_adicional_risco		adicional_risco
	,a.bfa_vl_insucesso				insucesso

FROM tb_fin_base_frete_adicional_motorista as a

inner join tb_dra_tipo_veiculo as b
on a.bfa_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo

where bfa_cd_transportadora = 2087146923
and bfa_cd_service_center = 'SMG8'

) as c
on a.TipoVeiculo = c.TipoVeiculo
and a.IdTransportadora = c.bfa_cd_transportadora
and a.ServiceCenter = b.base

left JOIN
    (
        select 
            tlm_cd_cliente
            ,tlm_cd_rota as IdRota
            ,tlm_cd_service_center as Base
            ,tlm_cd_motorista as Motorista
            ,tlm_cd_periodo as Ciclo
            ,tlm_cd_tipo as Tipo
            ,tlm_cd_risco_ajudante as RiscoAjudante 
            ,tlm_cd_quantidade_pacotes	as TotalPacotes
            ,tlm_cd_pontos as Pontos
            ,tlm_ds_observacao as observacao
            ,b.usr_nm_usuario as UsuarioCadastro
            ,tlm_dh_criacao as DataCriacao
            ,tlm_cd_usuario_modificacao as 	UsuarioModificao
            ,tlm_dh_modificacao as DataModificao
            ,tlm_ds_motorista_apoio as MotoristaApoio
            ,tlm_tipo_valor_apoio as TipoValorApoio
            ,tlm_vl_valor_apoio as ValorApoio
            ,tlm_cd_tipo_veiculo_nao_utilizado as VeiculoNaoUtilizado
            ,tlm_dh_nao_utilizado as DataNaoUtilizado
            ,tlm_dh_referencia as Data
            -- , * 

        from [dbo].[tb_lancamentos_manuais] as a

        left join tb_usuario as b
        on a.tlm_cd_usuario_criacao = b.usr_cd_usuario

        where tlm_in_ativo = 1

    ) as lancamentos
    on a.IdRota = lancamentos.IdRota


-- where 1=1 
-- and IdTransportadora = @Transportadora
-- and a.DataReferencia between @dataini and @datafim
-- and pgp_nm_periodo = @periodo
-- and ano = @ano
-- and mes = @mes
-- and quinzena = @quinzena
-- and pgtosaida > 0
-- and ServiceCenter = @ServiceCenter




GO
