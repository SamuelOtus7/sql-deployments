-- ============================================================
-- BASELINE: dbo.UspSPEFinAtualizaPagamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEFinAtualizaPagamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPEFinAtualizaPagamento] (
@CodPeriodoPagamento int
,@idrota varchar(max)
,@usuarioIrisys int

) as


declare
      @IdTransportadora int
    --, @CodPeriodoPagamento int = 1040
	--, @usuarioIrisys int
	--, @idrota varchar(50) = null
    , @data_inicial date
    , @data_final date
	, @clienteid int
	, @Motorista varchar(250)
	, @IdCliTransportadora int
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


	declare @UtilizaContrato int = (
						select prm_ds_valor 
						from tb_parametros 
						where prm_ds_categoria = 'Financeiro - Pagamentos'
						and prm_nm_parametro = 'Utiliza contrato'
						and prm_cod_cliente = @clienteid
						)



    declare @Operacao int = (   
						select  pgp_tipo_operacao
						from    [tb_pgto_periodo] as a with(nolock)
						where   pgp_cd_periodo = @CodPeriodoPagamento   
    
		)





drop table if exists #tb_pgto_periodo_rota
select * 
into #tb_pgto_periodo_rota
from tb_pgto_periodo_rota
where ppr_cd_periodo = @CodPeriodoPagamento
and (ppr_cd_rota  = @idrota or @idrota is null )
and ppr_cd_rota is not null




drop table if exists #valores_calculados
SELECT
			
	 ppr_cd_pagamento_rota
	
	,ppr_vl_base
	
	,case when ppr_ds_ciclo = 'AM' then
			
			isnull(case 
			when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
					then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_frete, freteCidade.bfm_vl_frete)

			when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
					then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_frete, freteCidade.bfm_vl_frete)


			when coalesce(frete.bfm_pag_sla,freteCidade.bfm_pag_sla) = 1
					then 
						case 
							when  CheckSLA.SLAIrisys = 'Dentro'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_frete, freteCidade.bfm_vl_frete)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_frete, freteCidade.bfm_vl_frete)
									end

							when  CheckSLA.SLAIrisys = 'Fora'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_frete_pm, freteCidade.bfm_vl_frete_pm)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_frete_pm, freteCidade.bfm_vl_frete_pm)
									end
						end
			


			else coalesce(frete.bfm_vl_frete, freteCidade.bfm_vl_frete)
			end,0) 
		 
		 else 
			isnull(case 
			when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
					then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_frete_pm, freteCidade.bfm_vl_frete_pm)

			when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
					then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_frete_pm, freteCidade.bfm_vl_frete_pm)

			when coalesce(frete.bfm_pag_sla,freteCidade.bfm_pag_sla) = 1
					then 
						case 
							when  CheckSLA.SLAIrisys = 'Dentro'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_frete, freteCidade.bfm_vl_frete)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_frete, freteCidade.bfm_vl_frete)
									end

							when  CheckSLA.SLAIrisys = 'Fora'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_frete_pm, freteCidade.bfm_vl_frete_pm)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_frete_pm, freteCidade.bfm_vl_frete_pm)
									end
						end

			else coalesce(frete.bfm_vl_frete_pm, freteCidade.bfm_vl_frete_pm)
			end,0) 


		 end as Saida

	,case when ppr_ds_ciclo = 'AM' then
			
		case 
			when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
					then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_domfer_am, freteCidade.bfm_vl_domfer_am)

			when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
					then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_domfer_am, freteCidade.bfm_vl_domfer_am)


			when coalesce(frete.bfm_pag_sla,freteCidade.bfm_pag_sla) = 1
					then 
						case 
							when  CheckSLA.SLAIrisys = 'Dentro'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_domfer_am, freteCidade.bfm_vl_domfer_am)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_domfer_am, freteCidade.bfm_vl_domfer_am)
									end

							when  CheckSLA.SLAIrisys = 'Fora'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_domfer_pm, freteCidade.bfm_vl_domfer_pm)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_domfer_pm, freteCidade.bfm_vl_domfer_pm)
									end
						end
			


			else coalesce(frete.bfm_vl_domfer_am, freteCidade.bfm_vl_domfer_am)
			end
		 
		 else 
		case 
			when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
					then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_domfer_pm, freteCidade.bfm_vl_domfer_pm)

			when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
					then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_domfer_pm, freteCidade.bfm_vl_domfer_pm)

			when coalesce(frete.bfm_pag_sla,freteCidade.bfm_pag_sla) = 1
					then 
						case 
							when  CheckSLA.SLAIrisys = 'Dentro'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_domfer_am, freteCidade.bfm_vl_domfer_am)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_domfer_am, freteCidade.bfm_vl_domfer_am)
									end

							when  CheckSLA.SLAIrisys = 'Fora'
								then 
									case 
										when coalesce(frete.bfm_pag_pacote,freteCidade.bfm_pag_pacote) = 1
											then r.ppr_qt_pacotes * coalesce(frete.bfm_vl_domfer_pm, freteCidade.bfm_vl_domfer_pm)
										when coalesce(frete.bfm_pag_pacote_entregues,freteCidade.bfm_pag_pacote_entregues) = 1
											then r.ppr_qt_pacotes_entregues * coalesce(frete.bfm_vl_domfer_pm, freteCidade.bfm_vl_domfer_pm)
									end
						end

		else coalesce(frete.bfm_vl_domfer_pm, freteCidade.bfm_vl_domfer_pm)
		end 

	end as Saida_DomFer

	--Criando uma nova coluna na tabela temporaria
	, coalesce(frete.bfm_vl_frete_fixo, freteCidade.bfm_vl_frete_fixo) FreteFixo


into #valores_calculados

FROM
	(

		select 
			mtn_cod_cliente,
			tvl_cd_tipo_veiculo,
			mot_ctn_cd_tipo_contrato as TipoContrato,
			r.*
		FROM
			#tb_pgto_periodo_rota r with(nolock)
			join tb_pag_espelhos as b
			on ppr_cd_motorista_nfs = mtn_cd_motorista_nfs
			left join tb_motorista as mot
			on b.mtn_cd_motorista = mot.mot_cd_usuario
			left join tb_dra_tipo_veiculo as vic
			on r.ppr_ds_tipo_veiculo = tvl_nm_tipo_veiculo	
	) r 


	left join tb_fin_base_frete_motorista frete  with(nolock)  on r.mtn_cod_cliente = frete.bfm_cd_transportadora
															and r.ppr_base_principal = frete.bfm_cd_service_center
															and r.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo
															and (frete.bfm_nm_cidade is null or frete.bfm_nm_cidade = '')
															and r.ppr_total_km > (frete.bfm_vl_inicio_faixa-1)
															and r.ppr_total_km <= (frete.bfm_vl_fim_faixa)
															--and (isnull(r.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1))
															and (
																		(@UtilizaContrato = 1 and isnull(r.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1))
																		or
																		@UtilizaContrato = 0
																)

															AND r.ppr_data_referencia BETWEEN frete.bfm_data_inicio_vigencia AND ISNULL(frete.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
															--and frete.bfm_cd_operacao = @Operacao

	left join tb_fin_base_frete_motorista freteCidade on mtn_cod_cliente = freteCidade.bfm_cd_transportadora
															and r.ppr_base_principal = freteCidade.bfm_cd_service_center
															and r.tvl_cd_tipo_veiculo = freteCidade.bfm_cd_tipo_veiculo
															and r.ppr_nm_cidade = freteCidade.bfm_nm_cidade	
															and r.ppr_total_km > (freteCidade.bfm_vl_inicio_faixa-1)
															and r.ppr_total_km <= (freteCidade.bfm_vl_fim_faixa)
															--and (isnull(r.TipoContrato,-1) = isnull(freteCidade.bmf_cd_tipo_contrato,-1))
															and (
																		(@UtilizaContrato = 1 and isnull(r.TipoContrato,-1) = isnull(freteCidade.bmf_cd_tipo_contrato,-1))
																		or
																		@UtilizaContrato = 0
																)
															AND r.ppr_data_referencia BETWEEN freteCidade.bfm_data_inicio_vigencia AND ISNULL(freteCidade.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
															--and freteCidade.bfm_cd_operacao = @Operacao


	left join (
				select 
 					 CodigoRota	
					,idtransportadora
					,CodigoPacote	
					,Nomehub
					,SLAIrisys

				from 
				(
					select 
        
						row_number() over(partition by codigopacote  order  by TentativaEntrega desc ) ordem
						,*  
					from tb_spe_sla_pacotes nolock
					--where codigopacote  = 'BR2500223181864'
				) as a
				where ordem = 1 
	) as CheckSLA
	on r.ppr_cd_rota = CheckSLA.codigorota

	

where
	ppr_cd_periodo = @CodPeriodoPagamento



update a
set 
	a.ppr_vl_base  = case when ppr_in_zerar_rota = 1 then 0 else isnull(b.FreteFixo,case when ppr_in_dom = 1	or ppr_in_fer = 1 then isnull(b.Saida_DomFer,b.saida) else b.saida end) end
	,a.ppr_vl_total = case when ppr_in_zerar_rota = 1 then 0 else isnull(b.FreteFixo,(  
						isnull(case when ppr_in_dom = 1	and ppr_in_fer = 1 then isnull(b.Saida_DomFer,b.saida) else b.saida end	,0)
					)) end

from tb_pgto_periodo_rota as a
inner join #valores_calculados as b
on a.ppr_cd_pagamento_rota = b.ppr_cd_pagamento_rota





update b
set b.mtn_vl_nfs = a.ppr_vl_total
from (
	select 
		ppr_cd_motorista_nfs
		,sum(ppr_vl_total) ppr_vl_total
	from tb_pgto_periodo_rota as a

	where
		ppr_cd_periodo = @CodPeriodoPagamento
	group by ppr_cd_motorista_nfs
) as a

inner join tb_pag_espelhos as b
on a.ppr_cd_motorista_nfs = b.mtn_cd_motorista_nfs

GO
