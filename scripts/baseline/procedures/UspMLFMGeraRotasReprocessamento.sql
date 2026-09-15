-- ============================================================
-- BASELINE: dbo.UspMLFMGeraRotasReprocessamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLFMGeraRotasReprocessamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 10/01/2026
-- Description:	Gera rotas que precisam ser reprocessadas
-- =============================================
CREATE procedure [dbo].[UspMLFMGeraRotasReprocessamento] 
as 
begin

	declare @IdClienteTransportadora int = (select 
												lst_cd_lista 
											from 
												tb_lista (NOLOCK)
											where 
												lst_nm_lista = 'Reprocessamento - Cliente Transportadora'
												and lst_ds_label = 'Mercado Livre'
											)

	declare @IdTipoOperacao int = (select 
										lst_cd_lista 
									from 
										tb_lista (NOLOCK)
									where 
										lst_nm_lista = 'Reprocessamento - Tipo Operação'
										and lst_ds_label = 'First Mile'
									)

	declare @IdStatus int = (select 
									lst_cd_lista 
								from 
									tb_lista (NOLOCK)
								where 
									lst_nm_lista = 'Reprocessamento - Status'
									and lst_ds_label = 'Aguardando'
								)

	declare @IdAcao int = (select 
								lst_cd_lista 
							from 
								tb_lista (NOLOCK)
							where 
								lst_nm_lista = 'Reprocessamento - Tipo Ação'
								and lst_ds_label = 'Reprocessar Rota First Mile'
							)
	
	drop table if exists #rotas
	select
		*
		into #rotas
	from
		(
			select
				c.cli_cd_codigo_cliente dar_cd_cliente
				,cast(r.IdRota as varchar(30)) dar_cd_rota
			from
				tb_ml_fm_rotas r with(nolock)
				join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_logistics 
													and c.cli_cd_codigo_cliente <> 7
													and c.cli_in_ativo = 1
													and c.cli_in_excluido = 0
			where
				status <> 'close'
				and DataReferencia >= dateadd(day,-30,cast(getdate() as date))
				and DataReferencia < cast(getdate() as date)

			union

			select
				c.cli_cd_codigo_cliente dar_cd_cliente
				,cast(p.IdRota as varchar(30)) dar_cd_rota
			from
				tb_fin_fm_prefatura p with(nolock)
				join tb_clientes c with(nolock) on p.IdTransportadora = c.cli_id_logistics 
													and c.cli_cd_codigo_cliente <> 7
													and c.cli_in_ativo = 1
													and c.cli_in_excluido = 0
				left join tb_ml_lh_rotas r with(nolock) on p.IdTransportadora = r.IdTransportadora
														and p.IdRota = r.IdRota
			where
				p.DataInicio >= dateadd(day,-30,cast(getdate() as date))
				and r.IdRota is null
		) t


	insert into tb_dra_reprocessamento (dar_cd_cliente, dar_cd_lista_transportadora, dar_cd_lista_operacao, dar_cd_rota, dar_cd_lista_status, dar_cd_lista_acao, dar_nr_maximo_tentativas, dar_nr_execucoes, dar_dh_processamento, dar_ds_erro_message, dar_dh_criacao)
	select
		r.dar_cd_cliente
		,@IdClienteTransportadora dar_cd_lista_transportadora
		,@IdTipoOperacao dar_cd_lista_operacao
		,r.dar_cd_rota
		,@IdStatus dar_cd_lista_status
		,@IdAcao dar_cd_lista_acao
		,5 dar_nr_maximo_tentativas
		,0 dar_nr_execucoes
		,null dar_dh_processamento
		,null dar_ds_erro_message
		,getdate() dar_dh_criacao
	from
		#rotas r
		left join tb_dra_reprocessamento d with(nolock) on r.dar_cd_cliente = d.dar_cd_cliente
															and d.dar_cd_lista_transportadora = @IdClienteTransportadora
															and d.dar_cd_lista_operacao = @IdTipoOperacao
															and dar_cd_lista_acao = @IdAcao
															and r.dar_cd_rota = d.dar_cd_rota
															and d.dar_dh_criacao >= cast(getdate() as date)
	where
		d.dar_cd_reprocessamento is null

end
		
GO
