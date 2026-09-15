-- ============================================================
-- BASELINE: dbo.UspSpeFinGeraPagamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSpeFinGeraPagamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSpeFinGeraPagamento]     (
   @CodPeriodoPagamento int ,
	@idrota varchar(50) = null,
	@avulso int = null -- codigo espelho,
)
as


set nocount on


if @avulso is not null
begin

update a
set
	 mtn_vl_nfs = ppr_vl_total
	,mtn_nome_motorista = ppr_nome_motorista
	,mtn_cd_motorista = ppr_cd_motorista


	from tb_pag_espelhos as a
	inner join (
		select
			ppr_cd_pgto_espelho
			,ppr_nome_motorista
			,ppr_cd_motorista
			,sum(ppr_vl_total) as ppr_vl_total
		FROM [tb_pgto_periodo_rota] AS a
		where ppr_cd_pgto_espelho = @avulso
		and ppr_cd_periodo  = @CodPeriodoPagamento
		group by ppr_cd_pgto_espelho,ppr_nome_motorista,ppr_cd_motorista
	) as b
	on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho


end

else

begin
	declare
      @IdTransportadora int
  --  , @CodPeriodoPagamento int = 166
    , @data_inicial date
    , @data_final date
	, @clienteid int
	, @usuarioIrisys int
	, @Motorista varchar(250)
	, @IdCliTransportadora int
	--, @idrota varchar(50) = null
	--, @avulso int = null
    ,@tipocontrato int = null



	set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)



	if @idrota is not null
		begin
			set @usuarioIrisys = (select distinct UsuarioIrisys from vw_rotas_spe_v4 where codigorota = @idrota)
			set @Motorista = (select distinct Motorista from vw_rotas_spe_v4 where codigorota = @idrota)
		end

	set @IdTransportadora = (
							select cli_id_shopee
							from [tb_pgto_periodo] as a
							left join tb_clientes as b
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)


	set @tipocontrato = (
							select pgp_cd_tipo_contratos
							from [tb_pgto_periodo] as a
							left join tb_clientes as b
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)



	set @IdCliTransportadora = (

						select lst_cd_lista from tb_lista
						where lst_nm_lista = 'Clientes transportadoras'
						and lst_ds_label = 'shopee'
						and lst_cd_cliente in (
												select pgp_cd_cliente
												from [tb_pgto_periodo] as a
												left join tb_clientes as b
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
												)
												)



	set @clienteid = (
						select pgp_cd_cliente
						from [tb_pgto_periodo] as a
						left join tb_clientes as b
						on a.pgp_cd_cliente = cli_cd_codigo_cliente
						where pgp_cd_periodo  = @CodPeriodoPagamento
						)
	
	declare @DataPrevistaPagamento date = (  
      
		select pgp_dt_prevista_pagamento  
		from [tb_pgto_periodo] as a (NOLOCK)  
		where pgp_cd_periodo  = @CodPeriodoPagamento
     
		)

drop table if exists #vw_rotas_spe_v4
select * 
into #vw_rotas_spe_v4
from vw_rotas_spe_v4 
where idtransportadora = @IdTransportadora
and DataReferencia between @data_inicial and @data_final
and (@idrota is null or codigorota = @idrota)
and (
        @tipocontrato = '-1' 
        or UsuarioIrisys in (
                       select
                       usr_cd_usuario
                       from tb_usuario as a
                       left join tb_tipo_contrato as b
                       on a.usr_cd_tipo_contrato = b.ttc_cd_tipo_contrato
                       where cli_cd_codigo_cliente =
                                               (
                                               select pgp_cd_cliente
	 											from [tb_pgto_periodo] as a
	 											left join tb_clientes as b
	 											on a.pgp_cd_cliente = cli_cd_codigo_cliente
	 											where pgp_cd_periodo  = @CodPeriodoPagamento
                                               )
                                    and (@tipocontrato = '-1'
        or a.usr_cd_tipo_contrato = @tipocontrato)
                       )
     )



	drop table if exists #tb_pgto_periodo_rota_edit
	select *
	into #tb_pgto_periodo_rota_edit
	from(
		select top 1
			*
			,cast(SUBSTRING(edit_Faixa_KM, 1, CHARINDEX('/', edit_Faixa_KM) - 1) as decimal(12,4)) as edit_km_selecionado
			,row_number() over(partition by edit_rota order by edit_dh_criacao desc) as ordem

		from tb_pgto_periodo_rota_edit
		--where (@idrota is null or edit_rota = @idrota)

		) as a
	where ordem = 1;

update a
	set	a.nomehub = isnull(edit_Service_Center,b.servicecenter)
	-- ,nomehub = b.servicecenter --  b.NomeServiceCenter

	from #vw_rotas_spe_v4 as a

	left join #tb_pgto_periodo_rota_edit as edit
		  on a.CodigoRota = edit.edit_rota

	left join (
			select *
			,row_number() over(partition by nomemotorista order by qtd desc) ordem
			from(
				select
					 motorista nomemotorista
					,nomehub servicecenter
					,count(*) qtd
				from #vw_rotas_spe_v4
				group by motorista,nomehub
			) as a
	) as b
	on a.Motorista = b.nomemotorista
	where b.ordem = 1


update #vw_rotas_spe_v4 
set TipoVeiculo = case 
					when TipoVeiculo = 'PASSEIO' then 'Veículo de Passeio'
					when TipoVeiculo = 'FIORINO' then 'Utilitários'
					when TipoVeiculo = 'HR' then 'BULK'
					else TipoVeiculo end
, idtransportadora  = @clienteid




	drop table if exists #tabela_insert
	CREATE TABLE #tabela_insert(
		[ppr_cd_periodo] [int] NULL,
		[ppr_cd_rota] [varchar](50) NULL,
		[ppr_cd_faixa_km] [varchar](20) NULL,
		[ppr_ds_placa] [varchar](50) NULL,
		[ppr_ds_tipo_veiculo] [varchar](50) NULL,
		[ppr_ds_ciclo] [varchar](50) NULL,
		[ppr_qt_pacotes] [int] NULL,
		[ppr_qt_pontos] [int] NULL,
		[ppr_qt_paradas] [int] NULL,
		[ppr_in_area_risco] [bit] NULL,
		[ppr_in_ajudante] [bit] NULL,
		[ppr_in_dom_fer] [bit] NULL,
		[ppr_vl_base] [decimal](10, 2) NULL,
		[ppr_vl_paradas] [decimal](10, 2) NULL,
		[ppr_vl_risco] [decimal](10, 2) NULL,
		[ppr_vl_ajudante] [decimal](10, 2) NULL,
		[ppr_vl_dom_fer] [decimal](10, 2) NULL,
		[ppr_vl_lancamentos] [decimal](10, 2) NULL,
		[ppr_vl_total_km_real] [decimal](10, 2) NULL,
		[ppr_vl_total_km_minimo] [decimal](10, 2) NULL,
		[ppr_vl_total_km_prefatura] [decimal](10, 2) NULL,
		[ppr_vl_total] [decimal](10, 2) NULL,
		[ppr_dh_criacao] [datetime]  NULL,
		[ppr_cd_usr_criacao] [int]  NULL,
		[ppr_dh_modificacao] [datetime]  NULL,
		[ppr_cd_usr_modificacao] [int]  NULL,
		[ppr_in_ativo] [bit]  NULL,
		[ppr_in_excluido] [bit]  NULL,
		[ppr_cd_motorista] [int] NULL,
		[ppr_vl_insucessos] [int] NULL,
		[ppr_vl_success_delivery] [decimal](10, 5) NULL,
		[ppr_qt_pacotes_entregues] [int] NULL,
		[ppr_qt_pacotes_pendentes] [int] NULL,
		[ppr_bfm_vl_FaixaKM] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_domingo] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_ciclo_pm] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas0_60] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas61_75] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas76_85] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas86_90] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas_acima_90] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_ajudante] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_risco] [decimal](10, 2) NULL,
		[ppr_bfm_vl_insucesso] [decimal](10, 2) NULL,
		[ppr_lcto_dt_lancamento] [date] NULL,
		[ppr_lcto_ciclo] [varchar](10) NULL,
		[ppr_lcto_tipo] [varchar](50) NULL,
		[ppr_lcto_vl_risco_ajudante] [decimal](10, 2) NULL,
		[ppr_lcto_qt_pacotes] [int] NULL,
		[ppr_lcto_qt_pontos] [int] NULL,
		[ppr_lcto_observacao] [varchar](1000) NULL,
		[ppr_lcto_usr_criacao] [int] NULL,
		[ppr_lcto_dh_modificacao] [datetime] NULL,
		[ppr_lcto_usr_modificacao] [int] NULL,
		[ppr_lcto_vl_apoio] [decimal](10, 2) NULL,
		[ppr_id_transportadora] [int] NULL,
		[ppr_usou_app] [varchar](10) NULL,
		[ppr_data_referencia] [date] NULL,
		[ppr_base_principal] varchar(50) null,
		[ppr_tipo_rota] varchar(30) null,
		ppr_nome_motorista varchar(300) null,
		ppr_vl_bonus [decimal](10, 2) NULL,
		svc_espelho  varchar(50),
		bkt_vl_km_ideal [decimal](10, 2) NULL,
		ppr_vl_trevo [decimal](10, 2) NULL,
		ppr_vl_pm [decimal](10, 2) NULL,
        ppr_vl_valor_frete [decimal](10, 2) NULL,
        ppr_total_km	decimal(10,2) null,
        ppr_nm_cidade	varchar(100) null,
        ppr_vl_pedagio  decimal(10,2) null
	)



insert into #tabela_insert
	(ppr_cd_periodo
	,ppr_cd_rota
	,ppr_cd_faixa_km
	,ppr_ds_placa
	,ppr_ds_tipo_veiculo
	,ppr_ds_ciclo
	,ppr_qt_pacotes
	,ppr_qt_pontos
	,ppr_qt_paradas
	,ppr_in_area_risco
	,ppr_in_ajudante
	,ppr_in_dom_fer
	,ppr_vl_base
	,ppr_vl_paradas
	,ppr_vl_risco
	,ppr_vl_ajudante
	,ppr_vl_dom_fer
	,ppr_vl_lancamentos
	,ppr_vl_total_km_real
	,ppr_vl_total_km_minimo
	,ppr_vl_total_km_prefatura
	,ppr_vl_total
	,ppr_dh_criacao
	,ppr_cd_usr_criacao
	,ppr_dh_modificacao
	,ppr_cd_usr_modificacao
	,ppr_in_ativo
	,ppr_in_excluido
	,ppr_cd_motorista
	,ppr_vl_insucessos
	,ppr_vl_success_delivery
	,ppr_qt_pacotes_entregues
	,ppr_qt_pacotes_pendentes
	,ppr_usou_app
	,ppr_data_referencia
	,ppr_base_principal
	,ppr_tipo_rota
	,ppr_nome_motorista
	,ppr_vl_bonus
	,svc_espelho
	,bkt_vl_km_ideal
	,ppr_vl_trevo
	,ppr_lcto_observacao
    ,ppr_vl_pm
    ,ppr_vl_valor_frete
    ,ppr_total_km
    ,ppr_nm_cidade
    ,ppr_vl_pedagio
	)
	
	SELECT  DISTINCT
	 @CodPeriodoPagamento as ppr_cd_periodo
	,IdRota ppr_cd_rota
	,FaixaKm ppr_cd_faixa_km
	,Placa ppr_ds_placa
	,TipoVeiculo ppr_ds_tipo_veiculo
	,CicloPM ppr_ds_ciclo
	,TotalPacotes ppr_qt_pacotes
	,0 ppr_qt_pontos
	,Paradas as ppr_qt_paradas
	,0 as ppr_in_area_risco
	,0 as ppr_in_ajudante
	,case when DomingoFeriado > 0 then 1 else 0 end as ppr_in_dom_fer
	,case when IdTransportadora = 40 then Saida * TotalPacotes else Saida end  ppr_vl_base
	,ValorAdicionalPaocte as ppr_vl_paradas
	,0 as ppr_vl_risco 
	,AJUDANTE as ppr_vl_ajudante
	,DomingoFeriado as ppr_vl_dom_fer
	,0 as ppr_vl_lancamentos
	,0 as ppr_vl_total_km_real
	,0 as ppr_vl_total_km_minimo
	,SaidaKmPreFatura as ppr_vl_total_km_prefatura
	,isnull(Saida,0) + isnull(DomingoFeriado,0) + isnull(Bonificao,0) + isnull(AJUDANTE,0) + isnull(ValorAdicionalPaocte,0) as ppr_vl_total

	,getdate() ppr_dh_criacao
	,7431 ppr_cd_usr_criacao
	,getdate() ppr_dh_modificacao
	,7431  ppr_cd_usr_modificacao
	,1 ppr_in_ativo
	,0 ppr_in_excluido

	,UsuarioIrisys ppr_cd_motorista
	,PacotesNaoEntregue ppr_vl_insucessos
	,ppr_vl_success_delivery
	,PacotesEntregues ppr_qt_pacotes_entregues
	,PacotesPendentes ppr_qt_pacotes_pendentes

	,0 ppr_usou_app
	,data ppr_data_referencia
	,serviceCenter ppr_base_principal
	,'Inteira' ppr_tipo_rota
	,Motorista as ppr_nome_motorista
	,Bonificao as ppr_vl_bonus
	,NomeHub as svc_espelho
	,null as bkt_vl_km_ideal
	,null as ppr_vl_trevo
	,null as ppr_lcto_observacao
	,0 as ppr_vl_pm
	,ppr_vl_valor_frete --Matheus
	,DistanciaTotal as ppr_total_km
	,CidadeDistante as ppr_nm_cidade
	,null as ppr_vl_pedagio
	--,null as ppr_lcto_cd_lancamento



		
	FROM
	(
		SELECT
			-- @IdTransportadora IdTransportadora,
			r.idTransportadora,
			r.dataReferencia AS Data,
			r.nomehub serviceCenter ,
			cast(freteKm2.bfm_vl_inicio_faixa as varchar)
                + '/' + cast(freteKm2.bfm_vl_fim_faixa as varchar) as FaixaKm,
			-- r.CidadeReferencia,
			freteKm2.bfm_vl_inicio_faixa as FaixaKmInicio ,
			freteKm2.bfm_vl_fim_faixa as FaixaKmFim,
			'' as Placa,
			r.TipoVeiculo,
			r.Motorista,
			UsuarioIrisys,
			r.CidadeDistante,
			-- tvl_nm_tipo_veiculo as TipoVeiculo,
			r.CodigoRota as IdRota,
			freteKm2.bfm_cd_service_center,
			case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end CicloPM,
			TotalPacotes,
			PacotesNaoEntregue,
			PacotesEntregues,
			PacotesPendentes,
			Paradas,
			-- QuantidadePontos,
			KmColetado,
			kmrodado as KmRodado,
			freteKm2.bfm_vl_frete kmbase, 
			

			isnull(
			case when 1 = 0 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					adicional.bfa_vl_adicional_domingo
				else
			case when 1=1 then
				case when isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm) is not null then
					isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm)
				else
					isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
			end 
			*
					adicional.bfa_vl_adicional_domingo / 100
			end
				end,0) as DomingoFeriado,

			isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) as Saida,

			-- Saida,


            case when PacotesEntregues > adicional.bfa_qtd_pacote then adicional.bfa_vl_qtd_pacote
		   when adicional.bfa_cd_transportadora = 62 and adicional.bfa_cd_tipo_veiculo = 26 then (PacotesEntregues * adicional.bfa_vl_adicional) -- Matheus
		   when adicional.bfa_cd_transportadora = 62 and adicional.bfa_cd_service_center in('LES-09-Viana','LRJ-021-Cabo Frio','XPT-MA-Cururupu') and adicional.bfa_cd_tipo_veiculo in(14,15,17,18) and PacotesEntregues >120 then 40
		   when adicional.bfa_cd_transportadora = 62 and adicional.bfa_cd_service_center in('LRJ-04-Campo Grande','LRJ-07- São Cristovão') and adicional.bfa_cd_tipo_veiculo in(14,15,17,18) and PacotesEntregues >120 then 30
			else 0  end as  ValorAdicionalPaocte, 

			case when adicional.bfa_cd_transportadora = 62 and adicional.bfa_cd_tipo_veiculo = 26 then ( PacotesEntregues * frete.bfm_vl_frete) else isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) end  as ppr_vl_valor_frete,


			/*calculo adicional */
			isnull(
			/*	case when r.IdTransportadora = 1491631999 and r.Ambulancia = 1 then
					0
				else
					CASE 
					WHEN adicional.bfa_calcula_por_parada = 0
						THEN 
							CASE 
								WHEN r.QuantidadePontos <= 60
									THEN r.QuantidadePontos * adicional.bfa_vl_paradas0_60
								WHEN r.QuantidadePontos <= 75
									THEN 60 * adicional.bfa_vl_paradas0_60 + (r.QuantidadePontos - 60) * adicional.bfa_vl_paradas61_75
								WHEN r.QuantidadePontos <= 85
									THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + (r.QuantidadePontos - 75) * adicional.bfa_vl_paradas76_85
								WHEN r.QuantidadePontos <= 90
									THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + (r.QuantidadePontos - 85) * adicional.bfa_vl_paradas86_90
							ELSE 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + 5 * adicional.bfa_vl_paradas86_90 + (r.QuantidadePontos - 90) * adicional.bfa_vl_paradas_acima_90
							END
					WHEN adicional.bfa_calcula_por_parada = 1
						THEN
						CASE 
								WHEN r.QuantidadeParadas <= 60
									THEN r.QuantidadeParadas * adicional.bfa_vl_paradas0_60
								WHEN r.QuantidadeParadas <= 75
									THEN 60 * adicional.bfa_vl_paradas0_60 + (r.QuantidadeParadas - 60) * adicional.bfa_vl_paradas61_75
								WHEN r.QuantidadeParadas <= 85
									THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + (r.QuantidadeParadas - 75) * adicional.bfa_vl_paradas76_85
								WHEN r.QuantidadeParadas <= 90
									THEN 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + (r.QuantidadeParadas - 85) * adicional.bfa_vl_paradas86_90
							ELSE 60 * adicional.bfa_vl_paradas0_60 + 15 * adicional.bfa_vl_paradas61_75 + 10 * adicional.bfa_vl_paradas76_85 + 5 * adicional.bfa_vl_paradas86_90 + (r.QuantidadeParadas - 90) * adicional.bfa_vl_paradas_acima_90
							END
					END 
				end
            +	*/		
			/*calculo adicional pool */			
			case 
			when ADICIONAL_POOL.bfa_vl_adicional is not null  
				then
					ADICIONAL_POOL.bfa_vl_adicional
				else
					0
				 end
				 +
		  /*calculo adicional fixo */			
            case 
			when adicional_fixo.bfm_vl_frete_fixo is not null  
				then
					adicional_fixo.bfm_vl_frete_fixo
				else
					0
				 end,0) AS [ADD],     
			
			ISNULL(
					case 
						when adicional.bfa_tipo_adicional_risco = 2 and FlagRisco > 0 
							then adicional.bfa_vl_adicional_risco 
						
						when r.IdTransportadora = 53  and adicional.bfa_tipo_adicional_risco = 2 and FlagRisco > 0 and TotalPacotes < 120
							then adicional.bfa_vl_adicional_risco 
					end 
			, 0) AS RISCO,

			ISNULL(
					case 
						when r.IdTransportadora = 27 and TotalPacotes > 180   
							then  adicional.bfa_vl_adicional_ajudante 
					
						when r.IdTransportadora = 53  and TotalPacotes >= 120   
							then  adicional.bfa_vl_adicional_ajudante
						else 0 end
					 ,0) AS AJUDANTE,

			ISNULL(NULL,0) AS ASCRESC,




			-- isnull(case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
			-- 	case when freteKmMotorista.bfm_vl_frete_pm is not null then
			-- 		freteKmMotorista.bfm_vl_frete_pm
			-- 	else
			-- 		freteKmMotorista.bfm_vl_frete
			-- 		-
			-- 		case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
			-- 			adicional.bfa_vl_adicional_ciclo_pm 
			-- 		else
			-- 			freteKmMotorista.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
			-- 		end 
			-- 	end
			-- else
			-- 	freteKmMotorista.bfm_vl_frete
			-- end,0)
			-- +
			-- /*calculo saida domingo */
			-- isnull(
			-- case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
			-- 	case when adicional.bfa_tipo_adicional_domingo = 2 then
			-- 		adicional.bfa_vl_adicional_domingo
			-- 	else
			-- case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
			-- 	case when freteKmMotorista.bfm_vl_frete_pm is not null then
			-- 		freteKmMotorista.bfm_vl_frete_pm
			-- 	else
			-- 		freteKmMotorista.bfm_vl_frete
			-- 		-
			-- 		case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
			-- 			adicional.bfa_vl_adicional_ciclo_pm 
			-- 		else
			-- 			freteKmMotorista.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
			-- 		end 
			-- 	end
			-- else
			-- 	freteKmMotorista.bfm_vl_frete
			-- end 
			-- *
			-- 		adicional.bfa_vl_adicional_domingo / 100
			-- end
			-- 	end,0)
			-- SaidaKmMotorista,

		
		isnull(case when 1=1 then
				case when freteKm0a100.bfm_vl_frete_pm is not null then
					freteKm0a100.bfm_vl_frete_pm
				else
					freteKm0a100.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKm0a100.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKm0a100.bfm_vl_frete
			end,0)
			+
			/*calculo saida domingo */
			isnull(
			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					adicional.bfa_vl_adicional_domingo
				else
			case when 1=1 then
				case when freteKm0a100.bfm_vl_frete_pm is not null then
					freteKm0a100.bfm_vl_frete_pm
				else
					freteKm0a100.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKm0a100.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKm0a100.bfm_vl_frete
			end 
			*
					adicional.bfa_vl_adicional_domingo / 100
			end
				end,0)
			SaidaKm0a100,


			isnull(case when 1=1 then
				case when freteKmPreFatura.bfm_vl_frete_pm is not null then
					freteKmPreFatura.bfm_vl_frete_pm
				else
					freteKmPreFatura.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKmPreFatura.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKmPreFatura.bfm_vl_frete
			end,0)
			+
			/*calculo saida domingo */
			isnull(
			case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
				case when adicional.bfa_tipo_adicional_domingo = 2 then
					adicional.bfa_vl_adicional_domingo
				else
			case when case when datepart(hour,r.DataHoraInicio) <= 12 then 'AM' else 'PM' end = 'PM' then
				case when freteKmPreFatura.bfm_vl_frete_pm is not null then
					freteKmPreFatura.bfm_vl_frete_pm
				else
					freteKmPreFatura.bfm_vl_frete
					-
					case when adicional.bfa_tipo_adicional_ciclo_pm = 2 then --PM
						adicional.bfa_vl_adicional_ciclo_pm 
					else
						freteKmPreFatura.bfm_vl_frete * adicional.bfa_vl_adicional_ciclo_pm  / 100
					end 
				end
			else
				freteKmPreFatura.bfm_vl_frete
			end 
			*
					adicional.bfa_vl_adicional_domingo / 100
			end
				end,0)	SaidaKmPreFatura,
			 r.nomehub 
			,freteKmPreFatura.bfm_cd_service_center as bfm_cd_service_center2
			,tv.tvl_cd_tipo_veiculo as tipo_veiculo
			,freteKmPreFatura.bfm_cd_tipo_veiculo as bfm_cd_tipo_veiculo
			,nullif(r.PacotesEntregues,0) / CAST(NULLIF(R.TotalPacotes,0) as decimal(9,2))   as ppr_vl_success_delivery
			,case
				 when r.idtransportadora = 27 and NULLIF(R.PacotesEntregues,0) / CAST(NULLIF(R.TotalPacotes,0) as decimal(9,2)) = 1 or PacotesNaoEntregue <= 1
					then adicional.bfa_vl_insucesso
				when r.idtransportadora = 53 and NULLIF(R.PacotesEntregues,0) / CAST(NULLIF(R.TotalPacotes,0) as decimal(9,2)) > 0.98 and NULLIF(R.TotalPacotes,0) > 50
					then 20
				else 0 end  as Bonificao

			,DistanciaTotal


		FROM
			#vw_rotas_spe_v4 r with(nolock)
			left join (
					select distinct 
							ano
							,mes
							,quinzena
							,idtransportadora
							,rota as idrota
							,cast(replace(kmrodado,',','.') as decimal(10,2))  as kmrodado
							,FlagRisco
							,TarifaAplicada
						from [dbo].[tb_fin_spe_prefatura] nolock
						where idtransportadora  = @clienteid
			) pre on r.IdTransportadora = pre.IdTransportadora
												and r.codigorota = cast(pre.IdRota as varchar(20))
												--and r.DataReferencia = pre.DataTermino
											
			left join 
			(
				select
					usr_nm_usuario NomeMotorista,
					c.cli_id_logistics IdTransportadora,
					u.usr_cd_tipo_contrato TipoContrato
				from
					tb_usuario u
					join tb_clientes c on u.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
					join tb_ml_aprovacao_usuario a on u.usr_cd_usuario = a.mau_cd_usuario_gerado and a.mau_ds_status = 'Aprovado'
				where
					usr_in_ativo = 1
					and c.cli_id_logistics <> 0
			) m on r.Motorista = m.NomeMotorista 
			and r.IdTransportadora = m.IdTransportadora

			-- left join tb_ml_service_center svc2 on r.ServiceCenter = svc2.svc_cd_service_center
			-- left join tb_ml_service_center svc with(nolock) on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center

			left join DimData dt on r.DataReferencia = dt.Data
			left join tb_dra_tipo_veiculo tv with(nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo
	

			left join tb_fin_cidades_risco_transportadora as risco on r.IdTransportadora = risco.crt_cd_transportadora
																	and r.nomehub = risco.crt_cd_service_center
																	-- and r.CidadeReferencia = risco.crt_nm_cidade
		
		left join tb_fin_base_km_trevo trevo with(nolock) on r.IdTransportadora = trevo.bkt_cd_transportadora
												and r.nomehub = trevo.bkt_cd_service_center
												-- and r.Cidades = trevo.bkt_nm_cidades

			
			left join tb_fin_base_frete_motorista frete on r.IdTransportadora = frete.bfm_cd_transportadora
																	and r.nomehub = frete.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo
																	and r.CidadeReferencia = frete.bfm_nm_cidade	
																--	and isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)

			left join tb_fin_base_frete_adicional_motorista adicional on r.IdTransportadora = adicional.bfa_cd_transportadora
																	and r.nomehub = adicional.bfa_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo
																	-- and (r.CidadeReferencia = adicional.bfa_nm_cidade or adicional.bfa_nm_cidade is null)
																	--and isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)
																		 or 1=1	)

            left join (
			SELECT 
			* 
			FROM 
			tb_fin_base_frete_adicional_motorista  
			with(nolock) 
			WHERE bfa_cd_tipo_veiculo IN (1,4)
			and bfa_cd_base_frete_adicional_motorista <> 1309
			) adicional_pool  on r.IdTransportadora = adicional_pool.bfa_cd_transportadora
																	and r.nomehub = adicional_pool.bfa_cd_service_center
                                                                    and tv.tvl_cd_tipo_veiculo = adicional_pool.bfa_cd_tipo_veiculo 
																	--and (r.CidadeReferencia = adicional_pool.bfa_nm_cidade or adicional_pool.bfa_nm_cidade is null)                                      
																	--and isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)
																		 or 1=1	)

			left join tb_fin_base_frete_motorista_adicional_km as adicionalkm
			on r.IdTransportadora = adicionalkm.idtransportadora
			and tv.tvl_cd_tipo_veiculo = adicionalkm.TipoVeiculo
			and r.nomehub = adicionalkm.ServiceCenter
			and r.DistanciaTotal >= (adicionalkm.InicioFaixa)
			and r.DistanciaTotal <= adicionalkm.FimFaixa


			left join tb_fin_base_frete_motorista freteKm with(nolock)  on r.IdTransportadora = freteKm.bfm_cd_transportadora
																	and r.nomehub = freteKm.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKm.bfm_cd_tipo_veiculo
																	and isnull(m.TipoContrato,-1) = freteKm.bmf_cd_tipo_contrato
																	and freteKm.bfm_nm_cidade is null 
																	and trevo.bkt_vl_km_ideal > (freteKm.bfm_vl_inicio_faixa - 1)
																	--and isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)

		left join tb_fin_base_frete_motorista freteKm2 with(nolock)  on 1=1
																	and r.IdTransportadora = freteKm2.bfm_cd_transportadora
																	and r.nomehub = freteKm2.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKm2.bfm_cd_tipo_veiculo
																	and freteKm2.bfm_nm_cidade is null 
																	and r.DistanciaTotal >= (freteKm2.bfm_vl_inicio_faixa)
																	and r.DistanciaTotal <= freteKm2.bfm_vl_fim_faixa
																	-- and (isnull(m.TipoContrato,-1) = isnull(freteKm2.bmf_cd_tipo_contrato,-1)
																	-- or 1=1)
																	

        left join tb_fin_base_frete_motorista adicional_fixo with(nolock) on adicional_fixo.bfm_vl_frete_fixo is NOT null 
																	AND r.IdTransportadora = adicional_fixo.bfm_cd_transportadora
																	and r.nomehub = adicional_fixo.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = adicional_fixo.bfm_cd_tipo_veiculo
																	--and isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)
																	or 1=1)
																	-- and r.Cidades = r.CidadeReferencia
																	--and r.cidades = adicional_fixo.bfm_nm_cidade
																	-- and r.CidadeReferencia = adicional_fixo.bfm_nm_cidade

		-- left join tb_fin_base_frete_motorista freteKmMotorista with(nolock)  on r.IdTransportadora = freteKmMotorista.bfm_cd_transportadora
		-- 															and r.nomehub = freteKmMotorista.bfm_cd_service_center
		-- 															and tv.tvl_cd_tipo_veiculo = freteKmMotorista.bfm_cd_tipo_veiculo
		-- 															--and isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)
		-- 															and (isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)
		-- 																 or 1=1	)
		-- 															and freteKmMotorista.bfm_nm_cidade is null
		-- 															and r.KmMotorista > (freteKmMotorista.bfm_vl_inicio_faixa - 1)
		-- 															and r.KmMotorista <= freteKmMotorista.bfm_vl_fim_faixa

		left join tb_fin_base_frete_motorista freteKm0a100 with(nolock)  on r.IdTransportadora = freteKm0a100.bfm_cd_transportadora
																	and r.nomehub = freteKm0a100.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKm0a100.bfm_cd_tipo_veiculo
																	--and isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)
																	and (isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)
																		 or 1=1	)
																	and freteKm0a100.bfm_nm_cidade is null 
																	and freteKm0a100.bfm_vl_inicio_faixa = 1

		left join tb_fin_base_frete_motorista freteKmPreFatura with(nolock)  on r.IdTransportadora = freteKmPreFatura.bfm_cd_transportadora
																	and r.nomehub = freteKmPreFatura.bfm_cd_service_center
																	and tv.tvl_cd_tipo_veiculo = freteKmPreFatura.bfm_cd_tipo_veiculo
																	--and isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)
																	--and (isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)
																	--	 or 1=1	)
																	and freteKmPreFatura.bfm_nm_cidade is null
																	and pre.kmrodado >= freteKmPreFatura.bfm_vl_inicio_faixa
																	and case when pre.kmrodado = 99999 then 9999 else pre.kmrodado end <= freteKmPreFatura.bfm_vl_fim_faixa

		where
		 r.DataReferencia between @data_inicial and @data_final
			and r.DataReferencia < cast(getdate() as date)
			--and r.CodigoRota = 'AT202405151PY5L'
		
		--and r.codigorota = 'AT202405091MT1X'
			--and adicional.bfa_cd_base_frete_adicional_motorista <> 1308
	) AS ROTAS
where 1=1
--and serviceCenter in ('LM Hub_MG_Contagem')
--and idrota = 'AT2024100142H7Q'

order by 5 desc ,2



	drop table if exists #espelho
	select
		 usu.usr_cd_usuario as mtn_cd_motorista
		--,a.*
		,ppr_nome_motorista as mtn_nome_motorista
		,ppr_cd_periodo as mtn_cd_pgto_periodo
		,228 mtn_cd_status
		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,null mtn_ds_link_nfs
		,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
		,getdate() mtn_dh_criacao
		,7174 as mtn_cd_usr_criacao
		,getdate() mtn_dh_modificacao
		,7174 as mtn_cd_usr_modificacao
		,0 as mtn_in_excluido
		,periodo.pgp_cd_cliente as mtn_cod_cliente
		,count(*) as mtn_qt_rotas
		,94  as mtn_cd_tipo_espelho
		,@IdCliTransportadora as mtn_cd_cliente_transportadora
		,bss_cd_base as mtn_cd_base
		--,case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end as mtn_base_principal
		,svc_espelho mtn_base_principal
		,periodo.pgp_tipo_operacao as mtn_cd_operacao

		into #espelho

	from #tabela_insert as a

	left join [tb_pgto_periodo] as periodo
	on a.ppr_cd_periodo = periodo.pgp_cd_periodo

	left join tb_usuario as usu
	on ppr_nome_motorista = usr_nm_usuario
	and usu.usr_in_ativo = 1
    and usu.cli_cd_codigo_cliente = @clienteid
	
	left join tb_clientes (NOLOCK) AS CLI ON CLI.cli_cd_codigo_cliente = periodo.pgp_cd_cliente

	left join #vw_rotas_spe_v4 as b
	on a.ppr_cd_rota = b.CodigoRota

	left join tb_bases as c
	on a.svc_espelho = c.bss_ds_nome
	and CLI.cli_id_shopee = c.bss_cd_idtransportadora

	--where ppr_cd_periodo = 4298
	--where ppr_cd_rota = 146941866

	group by  usr_cd_usuario ,ppr_cd_periodo,periodo.pgp_cd_cliente,bss_cd_base,ppr_nome_motorista,
	svc_espelho,pgp_tipo_operacao;
	--case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end;


	update b
	set
		mtn_vl_nfs = isnull(ppr_vl_total,0)+isnull(mtn_vl_nfs,0)

	from #tabela_insert as a
	inner join #espelho as b
	on ppr_cd_periodo = mtn_cd_pgto_periodo
	and ppr_nome_motorista = mtn_nome_motorista
	where ppr_cd_periodo = @CodPeriodoPagamento
	--and ppr_cd_motorista = 4298
	and ppr_cd_rota is NULL

	update b
	set
		mtn_vl_nfs = isnull(ppr_vl_total,0)+isnull(mtn_vl_nfs,0)

	from tb_pgto_periodo_rota as a
	inner join #espelho as b
	on ppr_cd_periodo = mtn_cd_pgto_periodo
	and ppr_cd_motorista = mtn_cd_motorista
	where ppr_cd_periodo = @CodPeriodoPagamento
	--and ppr_cd_motorista = 4298
	and ppr_cd_rota is NULL



	MERGE tb_pag_espelhos AS target
	USING (
		SELECT
			 mtn_cd_motorista
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
			,mtn_base_principal
			,mtn_nome_motorista
			,mtn_cd_operacao
			,@DataPrevistaPagamento mtn_dt_prevista_pagamento

		FROM #espelho
		where mtn_nome_motorista is not null

	) AS source
	ON (
		target.mtn_nome_motorista = source.mtn_nome_motorista
		AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
		--and target.mtn_cd_motorista = source.mtn_cd_motorista

--		AND target.mtn_cd_base = source.mtn_cd_base
		)
	WHEN MATCHED THEN
		UPDATE SET
			-- mtn_cd_status = source.mtn_cd_status
			--,
			mtn_vl_nfs = source.mtn_vl_nfs
			--,mtn_ds_link_nfs = source.mtn_ds_link_nfs
			,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
			,mtn_dh_criacao = source.mtn_dh_criacao
			,mtn_cd_usr_criacao = source.mtn_cd_usr_criacao
			,mtn_dh_modificacao = source.mtn_dh_modificacao
			,mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
			,mtn_in_excluido = source.mtn_in_excluido
			,mtn_cod_cliente = source.mtn_cod_cliente
			,mtn_qt_rotas = source.mtn_qt_rotas
			,mtn_cd_tipo_espelho = source.mtn_cd_tipo_espelho
			,mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
			,mtn_base_principal = source.mtn_base_principal
			,mtn_nome_motorista =  source.mtn_nome_motorista
			,mtn_cd_base = source.mtn_cd_base
			,mtn_cd_operacao = source.mtn_cd_operacao
			--ajuste para atualizar somente quando a data não for atualizada manualmente
			,mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end

	WHEN NOT MATCHED THEN
		INSERT (
			 mtn_cd_motorista
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
			,mtn_base_principal
			,mtn_nome_motorista
			,mtn_cd_base
			,mtn_cd_operacao
			,mtn_dt_prevista_pagamento
		)
		VALUES (
			 source.mtn_cd_motorista
			,source.mtn_cd_pgto_periodo
			,source.mtn_cd_status
			,source.mtn_vl_nfs
			,source.mtn_ds_link_nfs
			,source.mtn_dt_prazo_contestacao
			,source.mtn_dh_criacao
			,source.mtn_cd_usr_criacao
			,source.mtn_dh_modificacao
			,source.mtn_cd_usr_modificacao
			,source.mtn_in_excluido
			,source.mtn_cod_cliente
			,source.mtn_qt_rotas
			,source.mtn_cd_tipo_espelho
			,source.mtn_cd_cliente_transportadora
			,source.mtn_base_principal
			,source.mtn_nome_motorista
			,source.mtn_cd_base
			,source.mtn_cd_operacao
			,source.mtn_dt_prevista_pagamento
		);



	MERGE INTO [tb_pgto_periodo_rota] AS target
	USING (
		SELECT
			a.ppr_cd_periodo,
			a.ppr_cd_rota,
			a.ppr_cd_faixa_km,
			a.ppr_ds_placa,
			a.ppr_ds_tipo_veiculo,
			a.ppr_ds_ciclo,
			a.ppr_qt_pacotes,
			a.ppr_qt_pontos,
			a.ppr_qt_paradas,
			a.ppr_in_area_risco,
			a.ppr_in_ajudante,
			a.ppr_in_dom_fer,
			a.ppr_vl_base,
			a.ppr_vl_paradas,
			a.ppr_vl_risco,
			a.ppr_vl_ajudante,
			a.ppr_vl_dom_fer,
			a.ppr_vl_lancamentos,
			a.ppr_vl_total_km_real,
			a.ppr_vl_total_km_minimo,
			a.ppr_vl_total_km_prefatura,
			a.ppr_vl_total,
			a.ppr_cd_usr_criacao,
			a.ppr_dh_modificacao,
			a.ppr_cd_usr_modificacao,
			a.ppr_in_ativo,
			a.ppr_in_excluido,
			a.ppr_cd_motorista,
			a.ppr_vl_insucessos,
			a.ppr_vl_success_delivery,
			a.ppr_qt_pacotes_entregues,
			a.ppr_qt_pacotes_pendentes,
			b.mtn_cd_motorista_nfs AS ppr_cd_motorista_nfs,
			a.ppr_usou_app,
			a.ppr_data_referencia,
			a.ppr_base_principal,
			a.ppr_tipo_rota,
			a.ppr_nome_motorista,
			b.mtn_cd_motorista_nfs as ppr_cd_pgto_espelho,
			a.ppr_vl_bonus,
			ppr_lcto_observacao,
            a.ppr_vl_pm,
            ppr_vl_valor_frete,
            ppr_total_km,
            ppr_nm_cidade,
            ppr_vl_pedagio

		FROM #tabela_insert AS a
		INNER JOIN tb_pag_espelhos AS b
		ON a.ppr_cd_periodo = b.mtn_cd_pgto_periodo
		AND a.ppr_nome_motorista = b.mtn_nome_motorista
		--and a.ppr_base_principal = b.mtn_base_principal

		--WHERE (@idrota IS NULL OR a.ppr_cd_rota = @idrota)

	) AS source
	ON target.ppr_cd_periodo = source.ppr_cd_periodo
	AND target.ppr_cd_rota = source.ppr_cd_rota
	--and target.ppr_base_principal = source.ppr_base_principal


	WHEN MATCHED THEN
		UPDATE SET
			target.ppr_cd_faixa_km = source.ppr_cd_faixa_km,
			target.ppr_ds_placa = source.ppr_ds_placa,
			target.ppr_ds_tipo_veiculo = source.ppr_ds_tipo_veiculo,
			target.ppr_ds_ciclo = source.ppr_ds_ciclo,
			target.ppr_qt_pacotes = source.ppr_qt_pacotes,
			target.ppr_qt_pontos = source.ppr_qt_pontos,
			target.ppr_qt_paradas = source.ppr_qt_paradas,
			target.ppr_in_area_risco = source.ppr_in_area_risco,
			target.ppr_in_ajudante = source.ppr_in_ajudante,
			target.ppr_in_dom_fer = source.ppr_in_dom_fer,
			target.ppr_vl_base = source.ppr_vl_base,
			target.ppr_vl_paradas = source.ppr_vl_paradas,
			target.ppr_vl_risco = source.ppr_vl_risco,
			target.ppr_vl_ajudante = source.ppr_vl_ajudante,
			target.ppr_vl_dom_fer = source.ppr_vl_dom_fer,
			target.ppr_vl_lancamentos = source.ppr_vl_lancamentos,
			target.ppr_vl_total_km_real = source.ppr_vl_total_km_real,
			target.ppr_vl_total_km_minimo = source.ppr_vl_total_km_minimo,
			target.ppr_vl_total_km_prefatura = source.ppr_vl_total_km_prefatura,
			target.ppr_vl_total = source.ppr_vl_total,
			target.ppr_cd_usr_criacao = source.ppr_cd_usr_criacao,
			target.ppr_dh_modificacao = source.ppr_dh_modificacao,
			target.ppr_cd_usr_modificacao = source.ppr_cd_usr_modificacao,
			target.ppr_in_ativo = source.ppr_in_ativo,
			target.ppr_in_excluido = source.ppr_in_excluido,
			target.ppr_cd_motorista = source.ppr_cd_motorista,
			target.ppr_vl_insucessos = source.ppr_vl_insucessos,
			target.ppr_vl_success_delivery = source.ppr_vl_success_delivery,
			target.ppr_qt_pacotes_entregues = source.ppr_qt_pacotes_entregues,
			target.ppr_qt_pacotes_pendentes = source.ppr_qt_pacotes_pendentes,
			target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
			target.ppr_usou_app = source.ppr_usou_app,
			target.ppr_data_referencia = source.ppr_data_referencia,
			target.ppr_base_principal = source.ppr_base_principal,
			target.ppr_tipo_rota = source.ppr_tipo_rota,
			target.ppr_nome_motorista = source.ppr_nome_motorista,
			target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
			target.ppr_vl_bonus = source.ppr_vl_bonus,
			target.ppr_lcto_observacao = source.ppr_lcto_observacao,
            target.ppr_vl_pm = source.ppr_vl_pm,
            target.ppr_vl_valor_frete = source.ppr_vl_valor_frete,
            target.ppr_total_km = source.ppr_total_km,
            target.ppr_nm_cidade = source.ppr_nm_cidade,
            target.ppr_vl_pedagio = source.ppr_vl_pedagio



	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			ppr_cd_periodo,
			ppr_cd_rota,
			ppr_cd_faixa_km,
			ppr_ds_placa,
			ppr_ds_tipo_veiculo,
			ppr_ds_ciclo,
			ppr_qt_pacotes,
			ppr_qt_pontos,
			ppr_qt_paradas,
			ppr_in_area_risco,
			ppr_in_ajudante,
			ppr_in_dom_fer,
			ppr_vl_base,
			ppr_vl_paradas,
			ppr_vl_risco,
			ppr_vl_ajudante,
			ppr_vl_dom_fer,
			ppr_vl_lancamentos,
			ppr_vl_total_km_real,
			ppr_vl_total_km_minimo,
			ppr_vl_total_km_prefatura,
			ppr_vl_total,
			ppr_cd_usr_criacao,
			ppr_dh_modificacao,
			ppr_cd_usr_modificacao,
			ppr_in_ativo,
			ppr_in_excluido,
			ppr_cd_motorista,
			ppr_vl_insucessos,
			ppr_vl_success_delivery,
			ppr_qt_pacotes_entregues,
			ppr_qt_pacotes_pendentes,
			ppr_cd_motorista_nfs,
			ppr_usou_app,
			ppr_data_referencia,
			ppr_base_principal,
			ppr_tipo_rota,
			ppr_nome_motorista,
			ppr_cd_pgto_espelho,
			ppr_vl_bonus,
			ppr_lcto_observacao,
            ppr_vl_pm,
            ppr_vl_valor_frete,
            ppr_total_km,
            ppr_nm_cidade,
            ppr_vl_pedagio
		)
		VALUES (
			source.ppr_cd_periodo,
			source.ppr_cd_rota,
			source.ppr_cd_faixa_km,
			source.ppr_ds_placa,
			source.ppr_ds_tipo_veiculo,
			source.ppr_ds_ciclo,
			source.ppr_qt_pacotes,
			source.ppr_qt_pontos,
			source.ppr_qt_paradas,
			source.ppr_in_area_risco,
			source.ppr_in_ajudante,
			source.ppr_in_dom_fer,
			source.ppr_vl_base,
			source.ppr_vl_paradas,
			source.ppr_vl_risco,
			source.ppr_vl_ajudante,
			source.ppr_vl_dom_fer,
			source.ppr_vl_lancamentos,
			source.ppr_vl_total_km_real,
			source.ppr_vl_total_km_minimo,
			source.ppr_vl_total_km_prefatura,
			source.ppr_vl_total,
			source.ppr_cd_usr_criacao,
			source.ppr_dh_modificacao,
			source.ppr_cd_usr_modificacao,
			source.ppr_in_ativo,
			source.ppr_in_excluido,
			source.ppr_cd_motorista,
			source.ppr_vl_insucessos,
			source.ppr_vl_success_delivery,
			source.ppr_qt_pacotes_entregues,
			source.ppr_qt_pacotes_pendentes,
			source.ppr_cd_motorista_nfs,
			source.ppr_usou_app,
			source.ppr_data_referencia,
			source.ppr_base_principal,
			source.ppr_tipo_rota,
			source.ppr_nome_motorista,
			source.ppr_cd_pgto_espelho,
			source.ppr_vl_bonus,
			source.ppr_lcto_observacao,
            source.ppr_vl_pm,
            source.ppr_vl_valor_frete,
            source.ppr_total_km,
            source.ppr_nm_cidade,
            source.ppr_vl_pedagio

		);


--insere os lancamentos manuis sem rota
drop table if exists #lancamento_sem_rota
select 
	case when cast(tlm_cd_rota as varchar(50)) = 'null' then null else cast(tlm_cd_rota as varchar(50)) end  as ppr_cd_rota
	,tlm_cd_motorista as ppr_nome_motorista 
	,cast(tlm_dh_referencia as date) ppr_data_referencia
	,tlm_ds_observacao as ppr_lcto_observacao
	,(-1*isnull(tlm_vl_valor_descontos,0)) + isnull(tlm_vl_valor_apoio,0)  as ppr_vl_lancamentos
	,(-1*isnull(tlm_vl_valor_descontos,0)) + isnull(tlm_vl_valor_apoio,0)  as ppr_vl_total
	,ppr_cd_periodo
	,ppr_cd_pgto_espelho
	,getdate() ppr_dh_criacao
	,ppr_cd_usr_criacao
	,getdate() ppr_dh_modificacao
	,ppr_cd_usr_modificacao
	,ppr_in_ativo
	,ppr_in_excluido
	,ppr_cd_motorista
	,ppr_cd_motorista_nfs
	,tlm_cd_lancamento_manual as ppr_lcto_cd_lancamento
	
	into #lancamento_sem_rota

from (
			select a.*
			from [dbo].[tb_lancamentos_manuais] as a
			inner join [tb_aprovacao_lancamento_manual] as b
			on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
			where alm_ds_status = 'Aprovado'
		) as a

left join tb_usuario as b
on a.tlm_cd_usuario_criacao = b.usr_cd_usuario

inner join [tb_pgto_periodo] as c
on cast(a.tlm_dh_referencia as date) between pgp_dt_inicio and pgp_dt_fim


inner join (
	select distinct 
		 ppr_cd_periodo
		,ppr_cd_pgto_espelho
		,ppr_nome_motorista
		,getdate() ppr_dh_criacao
		,ppr_cd_usr_criacao
		,getdate() ppr_dh_modificacao
		,ppr_cd_usr_modificacao
		,ppr_in_ativo
		,ppr_in_excluido
		,ppr_cd_motorista
		,ppr_cd_motorista_nfs

	from [tb_pgto_periodo_rota] 
	where ppr_cd_periodo = @CodPeriodoPagamento 
	--and ppr_nome_motorista = 'William Felipe Paixao'
	and ppr_cd_usr_criacao = 8851

)as d
on c.pgp_cd_periodo = d.ppr_cd_periodo
and a.tlm_cd_motorista = d.ppr_nome_motorista


where tlm_in_ativo = 1
and (cast(tlm_cd_rota as varchar(50)) = 'null' 
or cast(tlm_cd_rota as varchar(50)) is null )
and c.pgp_cd_periodo = @CodPeriodoPagamento
and ppr_cd_usr_criacao = 8851


insert into [tb_pgto_periodo_rota] 
(
 ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho
, ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido
,ppr_cd_motorista,ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento
)

select 
 a.ppr_cd_rota, a.ppr_nome_motorista, a.ppr_data_referencia, a.ppr_lcto_observacao, a.ppr_vl_lancamentos, a.ppr_vl_total, a.ppr_cd_periodo, a.ppr_cd_pgto_espelho
,a.ppr_dh_criacao, a.ppr_cd_usr_criacao, a.ppr_dh_modificacao, a.ppr_cd_usr_modificacao, a.ppr_in_ativo, a.ppr_in_excluido
,a.ppr_cd_motorista,a.ppr_cd_motorista_nfs, a.ppr_lcto_cd_lancamento

from #lancamento_sem_rota as a
left  join [tb_pgto_periodo_rota] as b
on a.ppr_lcto_cd_lancamento = b.ppr_lcto_cd_lancamento
and a.ppr_cd_periodo = b.ppr_cd_periodo
where b.ppr_cd_periodo is null 


end
GO
