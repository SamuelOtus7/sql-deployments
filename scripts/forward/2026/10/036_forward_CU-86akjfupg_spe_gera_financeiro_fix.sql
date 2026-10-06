/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akjfupg
  Autor        : Samuel Nogueira (Devin)
  Data         : 2026-10-06
  Descricao    : Corrige 3 bugs que impedem a geracao do resultado financeiro
                 SPE (UspSPEGeraResultadoFinanceiro) com dados do modelo v5:
                 1) DELETE ineficaz: a procedure recebe @IdTransportadora como
                    cli_id_shopee, mas tb_fin_resultado_financeiro grava
                    cli_cd_codigo_cliente — o delete nunca encontrava linhas e
                    re-gerar uma quinzena DUPLICAVA todos os registros
                    (duplicidades ja existem em 2025-03 Q1 em ambiente).
                    Agora resolve cli_cd_codigo_cliente e filtra idmktplace=152
                    (Shopee) para nao remover linhas ML do mesmo cliente.
                 2) @idrota int -> varchar(50): rotas SPE sao alfanumericas
                    ('AT...'); regeneracao por rota unica estava quebrada.
                 3) INSERT falhava com rotas sem motorista atribuido
                    (Motorista NOT NULL na tabela; na v5, rotas placeholder
                    'Aguardando informacoes da rota' tem Motorista NULL).
                    Aplica ISNULL(r.Motorista,'') — mantem a rota na grade.
                 Validado em QAS: exec de ago/2026 Q1 p/ Parceiro Spot falhava
                 com 'Cannot insert NULL into column Motorista'.
  Rollback     : scripts/rollback/2026/10/036_rollback_CU-86akjfupg_spe_gera_financeiro_fix.sql
  Objetos      : dbo.UspSPEGeraResultadoFinanceiro
  Dependencias : dbo.vw_rotas_spe_v5, dbo.tb_clientes, dbo.tb_lista,
                 dbo.tb_fin_resultado_financeiro (idmktplace=152 = Shopee)
  ==============================================================================*/

SET NOCOUNT ON;
GO

--============================================================================
-- 1. PRE-CHECKS
--============================================================================
BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspSPEGeraResultadoFinanceiro'))
        THROW 50001, 'Procedure dbo.UspSPEGeraResultadoFinanceiro nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tb_fin_resultado_financeiro') AND name = 'idmktplace')
        THROW 50002, 'Coluna tb_fin_resultado_financeiro.idmktplace nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.tb_lista WHERE lst_nm_lista = 'Clientes transportadoras' AND lst_ds_label = 'Shopee' AND lst_cd_lista = 152)
        THROW 50003, 'Label Shopee (152) nao encontrada em tb_lista.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

--============================================================================
-- 2. SCRIPT PRINCIPAL
--============================================================================

CREATE OR ALTER PROCEDURE [dbo].[UspSPEGeraResultadoFinanceiro] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint,
	@idrota varchar(50) = null
)
as



 --declare @ano int = 2025
 --declare @mes int = 02
 --declare @Quinzena tinyint = 1
 --declare @idrota varchar(50) 
 --declare @IdTransportadora int = 20230009


declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)
declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end



drop table if exists #vw_rotas_spe_v4
select a.* ,c.lst_cd_lista, cli_cd_codigo_cliente as IdTransportadoraClic
into #vw_rotas_spe_v4

from vw_rotas_spe_v5  as a

inner join tb_clientes as b
on a.idtransportadora = b.cli_id_shopee

inner join tb_lista as c
on b.cli_cd_codigo_cliente = c.lst_cd_cliente
and lst_nm_lista = 'Clientes transportadoras'
and lst_ds_label = 'Shopee'

where idtransportadora = @IdTransportadora
and DataReferencia between @data_inicial and @data_final
and (@idrota is null or codigorota = @idrota)


update a 
set a.IdTransportadora = b.cli_cd_codigo_cliente
from #vw_rotas_spe_v4 as a
inner join tb_clientes as b
on a.idtransportadora = b.cli_id_shopee
where a.idtransportadora = @IdTransportadora;



-- CU-86akjfupg: o parametro chega como cli_id_shopee, mas a tabela grava
-- cli_cd_codigo_cliente. Resolve antes do delete e limita a idmktplace=152
-- (Shopee) para nao remover linhas ML do mesmo cli_cd_codigo_cliente.
declare @IdTransportadoraClic int;
select @IdTransportadoraClic = cli_cd_codigo_cliente
from dbo.tb_clientes
where cli_id_shopee = @IdTransportadora;

delete tb_fin_resultado_financeiro 
	where IdTransportadora = @IdTransportadoraClic
	and idmktplace = 152
	and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	and (@idrota is null or IdRota = @idrota)

insert into tb_fin_resultado_financeiro (	IdTransportadora
,	Ano
,	Mes
,	Quinzena
,	IdRota
,	DataReferencia
,	ServiceCenter
,	XPT
,	Base
,   Placa
,	Motorista
,	TipoVeiculo
, 	CicloPM
,	DomingoOuFeriado
,	TipoPagamentoFrete
,	TipoPagamentoAdicional
,	QuantidadePacotes
,	PacotesEntregues
,	Insucessos
,	Pendentes
,	QuantidadeParadas	
,	QuantidadePontos	
,	PgtoSaida
,	PgtoParadas
,	Adicional
,	KmColetado
,	LinkMapa
,	FaixaKm
,	RecebMeli
,	RecebimentoDomingo
,	RecebimentoRisco
,	DescontoCicloPM
,	Pedagio
,	ReceitaTotal
,	PgtoLancamentoManual
,	PgtoValorManual
,	RecebimentoLancamentoManual
,	RecebimentoValorManual
,	RecebMeli0a100
,	DataHoraInicio
,	TxAdicionalDomingo
,	TxAdicionalCiclo_pm
,	TxAdicionalAjudante
,	TxAdicionalRisco
,	idmktplace
, 	DataAtualizacao
,	ValorPreFatura
)

 --drop table if EXISTS #tabela
	select distinct 
		IdTransportadora,
		Ano,
		Mes,
		Quinzena,
		IdRota,
		DataReferencia,
		ServiceCenter,
		XPT,
		Base,
		'' Placa,
		Motorista,
		-- Destino,
		-- Cluster,
		TipoVeiculo,
		'' CicloPM,
		DomingoOuFeriado,
		TipoPagamentoFrete,
		TipoPagamentoAdicional,
		QuantidadePacotes,
		PacotesEntregues,
		Insucessos,
		Pendentes,
		0 QuantidadeParadas	,
		0 QuantidadePontos	,
		PgtoSaida,
		PgtoParadas,
		Adicional,
		isnull(KmColetado,0) as KmColetado ,
		LinkMapa,
		-- case when UsouAPP = 'Não' then null else FaixaKm end as FaixaKm,
        FaixaKm,
		isnull(RecebMeli,0) RecebMeli,
		-- isnull(RecebFrete,0) RecebFrete,
		
		-- isnull(RecebimentoParadas,0) RecebimentoParadas,
		isnull(RecebimentoDomingo,0) RecebimentoDomingo,
		isnull(RecebimentoRisco,0) RecebimentoRisco,
		-- isnull(RecebimentoAjudante,0) RecebimentoAjudante,
		DescontoCicloPM,
		isnull(Pedagio,0) Pedagio,
		isnull(RecebMeli,0) /*+ isnull(RecebimentoParadas,0) */ + isnull(RecebimentoDomingo,0) + isnull(RecebimentoRisco,0) /* + isnull(RecebimentoAjudante,0) */+ isnull(Pedagio,0) - isnull(DescontoCicloPM,0) ReceitaTotal,
		null PgtoLancamentoManual,
		0 PgtoValorManual,
		null RecebimentoLancamentoManual,
		0 RecebimentoValorManual,
		isnull(RecebMeli0a100,0) RecebMeli0a100,
        /*
		isnull(FretePreFatura,0) FretePreFatura,
		isnull(RecebimentoDomingoPrefatura,0) RecebimentoDomingoPrefatura,
		isnull(DescontoCicloPMPrefatura,0) DescontoCicloPMPrefatura,
        */
		-- ValorAdicional0_60,
		-- ValorAdicional61_90,
		-- ValorAdicionalAcima_90,

		DataHoraInicio,
		tx_adicional_domingo TxAdicionalDomingo,
		tx_adicional_ciclo_pm TxAdicionalCiclo_pm,
		tx_adicional_ajudante TxAdicionalAjudante,
		tx_adicional_risco TxAdicionalRisco,
		idmktplace,
		GETDATE() DataAtualizacao,
		TarifaAplicada ValorPreFatura
		-- UsouAPP,
		-- VersaoDA,
		-- case when UsouAPP = 'Não' then 0 else KmColetado end as KmColetadoNovo,
        -- FaixaPrimeiroUltimoPacote

	from
	(
		select
			r.IdTransportadora,
			@Ano Ano,
			@Mes Mes,
			@Quinzena Quinzena,
			r.CodigoRota as IdRota,
            -- FaixaPrimeiroUltimoPacote,
			-- isnull(alteracao.DataReferencia,r.DataReferencia) as DataReferencia,
			r.DataReferencia as DataReferencia,
			r.DataHoraInicio,
			 --isnull(alteracao.ServiceCenter,isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center)) as ServiceCenter
			r.NomeHub as ServiceCenter,
			null XPT,
			NomeHub Base,
			-- r.Placa,
			isnull(r.Motorista,'') Motorista,
			-- r.CidadeBase Destino,
			-- r.TipoRota Cluster,

			-- isnull(r.TipoVeiculoAlterado,r.TipoVeiculo) as TipoVeiculo,
			isnull(null,r.TipoVeiculo) as TipoVeiculo,

			-- isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) CicloPM,
			
            ISNULL( alteracao.DomingoOuFeriado , case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then 'Sim' else 'Não' end) DomingoOuFeriado,
			case when frete_diaria.bft_cd_base_frete_transportadora is not null then 'Frete Diária'
			else case when frete_faixa.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM'
			-- else case when frete_faixa_estado.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM por Estado'
			else case when frete_faixa_svc.bft_cd_base_frete_transportadora is not null then 'Frete por Faixa KM por SVC'
			end end end /* end */ TipoPagamentoFrete,
			
			case isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) when 1 then 'Pagamento por Parada' when 0 then 'Pagamento por Ponto' else null end TipoPagamentoAdicional,
			
			isnull(null , r.TotalPacotes) QuantidadePacotes,

			isnull(alteracao.PacotesEntregues,r.PacotesEntregues ) PacotesEntregues,
			-- isnull(null ,r.PacotesEntregues ) PacotesEntregues,

			r.PacotesNaoEntregue Insucessos,
			r.PacotesPendentes Pendentes,
			
			-- isnull(alteracao.QuantidadeParadas, r.QuantidadeParadas ) as QuantidadeParadas,
			-- isnull(alteracao.QuantidadePontos , r.QuantidadePontos ) as QuantidadePontos ,
			
			
			null PgtoSaida,
			null PgtoParadas,
			null Adicional,

			r.KmColetado,
			--r.pontosAppRotasTotalVoltaKm as KmColetadoNovo,

             isnull(alteracao.LinkMapa  ,r.LinkMapa  ) as LinkMapa,

			
			cast(COALESCE(frete_faixa.bft_vl_inicio_faixa /*, frete_faixa_estado.bft_vl_inicio_faixa */, frete_faixa_svc.bft_vl_inicio_faixa) as varchar) + '/' +
			cast(COALESCE(frete_faixa.bft_vl_fim_faixa /*, frete_faixa_estado.bft_vl_fim_faixa */, frete_faixa_svc.bft_vl_fim_faixa) as varchar) FaixaKm,
		
			COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete /*, frete_faixa_estado.bft_vl_frete*/, frete_faixa_svc.bft_vl_frete) RecebMeli,
			frete_faixa_prefatura.bft_vl_frete RecebFrete,
            /* recebimento por parada
			case when isnull(adicional.bfa_calcula_por_parada,adicional_svc.bfa_calcula_por_parada) = 1 then
				case when r.QuantidadeParadas > 60 then 60 else r.QuantidadeParadas end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)
				+
				case when r.QuantidadeParadas > 60 then case when r.QuantidadeParadas >= 90 then 30 else r.QuantidadeParadas - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)
				+
				case when r.QuantidadeParadas > 90 then r.QuantidadeParadas - 90 else 0 end * isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)
			else
				case when r.QuantidadePontos > 60 then 60 else r.QuantidadePontos end * isnull(adicional.bfa_vl_paradas0_60,adicional_svc.bfa_vl_paradas0_60)
				+
				case when r.QuantidadePontos > 60 then case when r.QuantidadePontos >= 90 then 30 else r.QuantidadePontos - 60 end else 0 end * isnull(adicional.bfa_vl_paradas61_90,adicional_svc.bfa_vl_paradas61_90)
				+
				case when r.QuantidadePontos > 90 then r.QuantidadePontos - 90 else 0 end *isnull(adicional.bfa_vl_paradas_acima_90,adicional_svc.bfa_vl_paradas_acima_90)
			end RecebimentoParadas,
*/
			
			case when (alteracao.DomingoOuFeriado = 'Sim' or DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1) then --domingo ou feriado
				case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem
					--quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm
					(
						COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete /*, frete_faixa_estado.bft_vl_frete*/, frete_faixa_svc.bft_vl_frete) 
						-
						isnull(
							-- case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
								case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
									COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete /*, frete_faixa_estado.bft_vl_frete */, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
								else --Valor
									isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
								end
							/*else
								0
							end*/
						,0)
					)
					* 
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100
				else --Valor
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)
				end
			else
				0
			end RecebimentoDomingo,

			

			-- case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
				case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
					COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete /*, frete_faixa_estado.bft_vl_frete */, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
				else --Valor
					isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
				end
			/* else
				 0
			end*/
             DescontoCicloPM,

			
			case when  (alteracao.DomingoOuFeriado = 'Sim' or risco.crt_cd_risco_transportadora is not null) then
				case when isnull(adicional.bfa_tipo_adicional_risco,adicional_svc.bfa_tipo_adicional_risco) = 1 then --Porcentagem
					COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete /*, frete_faixa_estado.bft_vl_frete */, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco) / 100 
				else
					isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco)
				end
			else
				0
			end RecebimentoRisco,
/*
			case when  (alteracao.Ajudante = 'Sim'  or r.PossuiAjudante = 1) then
				case when isnull(adicional.bfa_tipo_adicional_ajudante,adicional_svc.bfa_tipo_adicional_ajudante) = 1 then --Porcentagem
					COALESCE(frete_diaria.bft_vl_frete, frete_faixa.bft_vl_frete /*, frete_faixa_estado.bft_vl_frete*/, frete_faixa_svc.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante) / 100 
				else
					isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante)
				end
			else
				0
			end as RecebimentoAjudante,
*/
			null Pedagio,
			
			-- isnull(frete_faixa_Km0a100.frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)
			isnull(frete_faixa_prefatura.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)
			- --CicloPM
			isnull(
                -- case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
				case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
					isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
				else --Valor
					isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
				end
			/*else
				0
			end
            */,0)
			+ --Adicional Domingo
			isnull(case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem
					--quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm
					(
						isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)
						-
						isnull(
							/*case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then*/
								case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
									isnull(frete_faixa_Km0a100.bft_vl_frete ,frete_faixa_svc_Km0a100.bft_vl_frete)  * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
								else --Valor
									isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
								end
							/*else
								0
							end*/
						,0)
					)
					* 
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100
				else --Valor
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)
				end
			else
				0
			end,0) RecebMeli0a100,

/*
			isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) FretePreFatura,

			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when isnull(adicional.bfa_tipo_adicional_domingo,adicional_svc.bfa_tipo_adicional_domingo) = 1 then --Porcentagem
					--quando é porcentagem, devo considerar o domingo e feriado sobre o valor da rota já descontando o cilco pm
					(
						isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete)
						-
						isnull(
							case when isnull(alteracao.CicloPM, case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
								case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
									isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
								else --Valor
									isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
								end
							else
								0
							end
						,0)
					)
					* 
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo) / 100
				else --Valor
					isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)
				end
			else
				0
			end RecebimentoDomingoPrefatura,

*/

/*
			case when isnull(alteracao.CicloPM,case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end) = 'PM' then
				case when isnull(adicional.bfa_tipo_adicional_ciclo_pm,adicional_svc.bfa_tipo_adicional_ciclo_pm) = 1 then --Porcentagem
					isnull(frete_faixa_prefatura.bft_vl_frete,frete_faixa_svc_prefatura.bft_vl_frete) * isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)  / 100 --alc sempre é calculo percentual e motorista é valor taxado
				else --Valor
					isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm)
				end
			else
				0
			end DescontoCicloPMPrefatura,
*/

			isnull(adicional.bfa_vl_adicional_domingo,adicional_svc.bfa_vl_adicional_domingo)	as tx_adicional_domingo,
			isnull(adicional.bfa_vl_adicional_ciclo_pm,adicional_svc.bfa_vl_adicional_ciclo_pm) as tx_adicional_ciclo_pm,
			isnull(adicional.bfa_vl_adicional_ajudante,adicional_svc.bfa_vl_adicional_ajudante) as tx_adicional_ajudante,
			isnull(adicional.bfa_vl_adicional_risco,adicional_svc.bfa_vl_adicional_risco)		as tx_adicional_risco,
			lst_cd_lista as idmktplace,
			TarifaAplicada
			-- r.UsouAPP,
			-- r.VersaoDA

			
		from
			#vw_rotas_spe_v4 r with(nolock)


			-- left join tb_ml_service_center svc2 on r.ServiceCenter = svc2.svc_cd_service_center
			left join DimData dt on r.DataReferencia = dt.Data
			-- left join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
			-- left join tb_dra_bases b with(nolock) on svc.svc_cd_service_center = b.dab_cd_service_center and b.dab_cd_transportadora = r.IdTransportadora
			
			-- left join tb_dra_tipo_veiculo tv with(nolock) on isnull(r.TipoVeiculoAlterado,r.TipoVeiculo) = tv.tvl_nm_tipo_veiculo
			/*incluir alterações da tela fixa de rota*/
            
            left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
		
            /*pre fatura shopee*/
			left join (
						
						select distinct 
							ano
							,mes
							,quinzena
							,cli_cd_codigo_cliente idtransportadora
							,rota as idrota
							,cast(replace(kmrodado,',','.') as decimal(10,2))  as kmrodado
							,TarifaAplicada
						from [dbo].[tb_fin_spe_prefatura] as a with( nolock)
						inner join tb_clientes as b
						on a.idtransportadora = b.cli_id_shopee

						where idtransportadora  = @IdTransportadora
						and ano			= @ano	
						and mes			= @mes
						and quinzena	= @Quinzena

						
									) pre on r.IdTransportadora = pre.IdTransportadora
												and r.codigorota = cast(pre.IdRota as varchar(20))

            /*risco*/
			left join tb_fin_cidades_risco_transportadora as risco on r.IdTransportadora = risco.crt_cd_transportadora
																	and r.NomeHub = risco.crt_cd_service_center
																	-- and r.CidadeReferencia = risco.crt_nm_cidade

			--frete com valor por dia 
			left join tb_fin_base_frete_transportadora frete_diaria on tv.tvl_cd_tipo_veiculo = frete_diaria.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_diaria.bft_cd_transportadora
																	and frete_diaria.bft_cd_service_center is null 
																	and frete_diaria.bft_estado is null
																	and frete_diaria.bft_vl_inicio_faixa is null
																	and frete_diaria.bft_vl_fim_faixa is null

			--frete por faixa (independente de svc e estado)
			left join tb_fin_base_frete_transportadora frete_faixa on tv.tvl_cd_tipo_veiculo = frete_faixa.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa.bft_cd_transportadora
																	and frete_faixa.bft_cd_service_center is null 
																	and frete_faixa.bft_estado is null
																	and r.KmColetado > (frete_faixa.bft_vl_inicio_faixa - 1)
																	and r.KmColetado <= frete_faixa.bft_vl_fim_faixa

			--frete por faixa (independente de svc e estado) considerando km prefautra
			left join tb_fin_base_frete_transportadora frete_faixa_prefatura on tv.tvl_cd_tipo_veiculo = frete_faixa_prefatura.bft_cd_tipo_veiculo 
																	and 20230008 = frete_faixa_prefatura.bft_cd_transportadora
																	--and frete_faixa_prefatura.bft_cd_service_center is null 
																	--and frete_faixa_prefatura.bft_estado is null
																	and pre.kmrodado >= frete_faixa_prefatura.bft_vl_inicio_faixa
																	and case when pre.kmrodado = 99999 then 9999 else pre.kmrodado end <= frete_faixa_prefatura.bft_vl_fim_faixa

			-- --frete por faixa e estado
			-- left join tb_fin_base_frete_transportadora frete_faixa_estado on tv.tvl_cd_tipo_veiculo = frete_faixa_estado.bft_cd_tipo_veiculo 
			-- 														and r.IdTransportadora = frete_faixa_estado.bft_cd_transportadora
			-- 														and frete_faixa_estado.bft_cd_service_center is null 
			-- 														and frete_faixa_estado.bft_estado =  isnull(b.dab_nm_estado,svc.svc_nm_estado)
			-- 														and r.KmColetado > (frete_faixa_estado.bft_vl_inicio_faixa - 1)
			-- 														and r.KmColetado <= frete_faixa_estado.bft_vl_fim_faixa

			--frete por faixa e svc
			left join tb_fin_base_frete_transportadora frete_faixa_svc on tv.tvl_cd_tipo_veiculo = frete_faixa_svc.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_svc.bft_cd_transportadora
																	and frete_faixa_svc.bft_cd_service_center = r.NomeHub
																	and frete_faixa_svc.bft_estado  is null
																	and r.KmColetado > (frete_faixa_svc.bft_vl_inicio_faixa - 1)
																	and r.KmColetado <= frete_faixa_svc.bft_vl_fim_faixa

			-- --frete por faixa e svc considerando km prefatura
			-- left join tb_fin_base_frete_transportadora frete_faixa_svc_prefatura on tv.tvl_cd_tipo_veiculo = frete_faixa_svc_prefatura.bft_cd_tipo_veiculo 
			-- 														and r.IdTransportadora = frete_faixa_svc_prefatura.bft_cd_transportadora
			-- 														and frete_faixa_svc_prefatura.bft_cd_service_center = isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center)
			-- 														and frete_faixa_svc_prefatura.bft_estado  is null
			-- 														and pre.InicioIntervalo >= frete_faixa_svc_prefatura.bft_vl_inicio_faixa
			-- 														and case when pre.FimIntervalo = 99999 then 9999 else pre.FimIntervalo end <= frete_faixa_svc_prefatura.bft_vl_fim_faixa

			--frete por faixa (independente de svc e estado) km 0 a 100
			left join tb_fin_base_frete_transportadora frete_faixa_Km0a100 on tv.tvl_cd_tipo_veiculo = frete_faixa_Km0a100.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_Km0a100.bft_cd_transportadora
																	and frete_faixa_Km0a100.bft_cd_service_center is null 
																	and frete_faixa_Km0a100.bft_estado is null
																	and frete_faixa_Km0a100.bft_vl_inicio_faixa = 1

			--frete por faixa e svc km 0 a 100
			left join tb_fin_base_frete_transportadora frete_faixa_svc_Km0a100 on tv.tvl_cd_tipo_veiculo = frete_faixa_svc_Km0a100.bft_cd_tipo_veiculo 
																	and r.IdTransportadora = frete_faixa_svc_Km0a100.bft_cd_transportadora
																	and frete_faixa_svc_Km0a100.bft_cd_service_center = r.NomeHub
																	and frete_faixa_svc_Km0a100.bft_estado  is null
																	and frete_faixa_svc_Km0a100.bft_vl_inicio_faixa = 1

			
			left join tb_fin_base_frete_adicional adicional with(nolock) on tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo 
																	and r.IdTransportadora = adicional.bfa_cd_transportadora
																	and adicional.bfa_cd_service_center is null
																	and adicional.bfa_estado  is null


			left join tb_fin_base_frete_adicional adicional_svc with(nolock) on tv.tvl_cd_tipo_veiculo = adicional_svc.bfa_cd_tipo_veiculo 
																	and r.IdTransportadora = adicional_svc.bfa_cd_transportadora
																	and adicional_svc.bfa_cd_service_center =  r.NomeHub
																	and adicional_svc.bfa_estado  is null  

            /*tela fixa de rota*/
			left join 
	
					(
					select a.*,b. cli_id_logistics 
					from tb_fin_resultado_financeiro_alteracao as a
					inner join tb_clientes as b
					on a.idtransportadora = b.cli_cd_codigo_cliente
					) as alteracao

			on r.CodigoRota = cast(alteracao.idrota as varchar(15))
			and r.IdTransportadora = alteracao.cli_id_logistics
			
		where 1=1
			--r.IdTransportadora = @IdTransportadora
			--and isnull(r.TipoOrigemSaida,'') <> 'delivery_cell'
			and r.DataReferencia between @data_inicial and @data_final
			and r.DataReferencia < cast(getdate() as date)

			-- and isnull(r.SubStatusRota,'') not in ('Cancelada','Planejada')
			-- and StatusRota <> 'Planejada'
			
		
	) rotas

where 1=1
--and idrota = 'AT2025022717NMT'
-- and KmColetado > 0 
-- and ServiceCenter = 'LM Hub_CE_Fortaleza-02'
;



-- and RecebMeli > 0 
-- and  rotas.ServiceCenter = 'LM Hub_SP_Piracicaba'
-- and idrota = 'AT2024033012F4H'

-- select distinct NomeHub from #vw_rotas_spe_v4 

-- select
-- 	Ano
-- ,	Mes
-- ,	Quinzena
-- ,	IdRota
-- ,	DataReferencia
-- ,	ServiceCenter
-- ,	XPT
-- ,	Base
-- ,   Placa
-- ,	Motorista
-- ,	TipoVeiculo
-- , 	CicloPM
-- ,	DomingoOuFeriado
-- ,	TipoPagamentoFrete
-- ,	TipoPagamentoAdicional
-- ,	QuantidadePacotes
-- ,	PacotesEntregues
-- ,	Insucessos
-- ,	Pendentes
-- ,	QuantidadeParadas	
-- ,	QuantidadePontos	
-- ,	PgtoSaida
-- ,	PgtoParadas
-- ,	Adicional
-- ,	KmColetado
-- ,	LinkMapa
-- ,	FaixaKm
-- ,	RecebMeli
-- ,	RecebimentoDomingo
-- ,	RecebimentoRisco
-- ,	DescontoCicloPM
-- ,	Pedagio
-- ,	ReceitaTotal
-- ,	PgtoLancamentoManual
-- ,	PgtoValorManual
-- ,	RecebimentoLancamentoManual
-- ,	RecebimentoValorManual
-- ,	RecebMeli0a100
-- ,	DataHoraInicio
-- ,	TxAdicionalDomingo
-- ,	TxAdicionalCiclo_pm
-- ,	TxAdicionalAjudante
-- ,	TxAdicionalRisco

-- from #tabela

GO

--============================================================================
-- 3. POS-CHECKS
--============================================================================
BEGIN TRY
    IF CHARINDEX('@idrota varchar(50)', OBJECT_DEFINITION(OBJECT_ID('dbo.UspSPEGeraResultadoFinanceiro'))) = 0
        THROW 50004, 'Parametro @idrota nao virou varchar(50).', 1;
    IF CHARINDEX('IdTransportadoraClic', OBJECT_DEFINITION(OBJECT_ID('dbo.UspSPEGeraResultadoFinanceiro'))) = 0
        THROW 50005, 'Delete sem resolucao cli_cd_codigo_cliente.', 1;
    IF CHARINDEX('idmktplace = 152', OBJECT_DEFINITION(OBJECT_ID('dbo.UspSPEGeraResultadoFinanceiro'))) = 0
        THROW 50006, 'Delete sem guarda idmktplace=152.', 1;
    IF CHARINDEX('from vw_rotas_spe_v5', OBJECT_DEFINITION(OBJECT_ID('dbo.UspSPEGeraResultadoFinanceiro'))) = 0
        THROW 50007, 'Fonte nao aponta para vw_rotas_spe_v5.', 1;

    PRINT 'SUCESSO: UspSPEGeraResultadoFinanceiro corrigida (CU-86akjfupg).';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    THROW;
END CATCH
GO
