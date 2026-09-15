-- ============================================================
-- BASELINE: dbo.UspMLCorrigeRotasExcluidas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLCorrigeRotasExcluidas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLCorrigeRotasExcluidas]
(
	@DataReferencia date = null,
	@IdRota int = null
)
as 
begin

	SET NOCOUNT ON;

	if @DataReferencia is not null or @IdRota is not null
	begin
		drop table if exists #rotas
		select
			rotas.IdRota,
			rotas.IdTransportadora,
			pacotes.DataReferencia,
			rotas.Qtde QuantidadeRotas,
			r.Excluido
			into #rotas
		from
			(
				select 
					IdRota,
					IdTransportadora,
					count(1) qtde
				from 
					tb_ml_rotas r with(nolock)
				where
					(DataReferencia >= @DataReferencia or @DataReferencia is null)
					and
					(IdRota = @IdRota or @IdRota is null)
				group by
					IdRota,
					IdTransportadora
				having
					count(1) > 1
			) rotas

			--considera a maior data de referencia em que teve algum pacote com a mesma data hora entrega
			join (
				select
					IdRota,
					IdTransportadora,
					max(DataReferencia) DataReferencia
				from
					tb_ml_pacotes with(nolock)
				where 
					(DataReferencia >= @DataReferencia or @DataReferencia is null)
					and
					(IdRota = @IdRota or @IdRota is null)
					and DataReferencia = cast(DataHoraEntrega as date)

					-- Alterado em 19/03/2025 por Saulo BArros para incluir também not_delivered. Ao analisar algumas rotas no fechamento, deveria considerar a data de referencia em que houve pacote também não entregue, e não apenas entregue
					and StatusEntrega in ('delivered', 'not_delivered')
					and isnull(SubStatus,'') <> 'transferred'
				group by
					IdRota,
					IdTransportadora
				) pacotes on rotas.IdRota = pacotes.IdRota
						and rotas.IdTransportadora = pacotes.IdTransportadora
			join tb_ml_rotas r with(nolock) on r.IdRota = rotas.IdRota and r.IdTransportadora = rotas.IdTransportadora and r.DataReferencia = pacotes.DataReferencia
	
			-- precisa ter pelo menos alguma rota que não foi excluida
			join (
				select 
					IdRota,
					IdTransportadora,
					count(1) qtde
				from 
					tb_ml_rotas r with(nolock)
				where
					(DataReferencia >= @DataReferencia or @DataReferencia is null)
					and
					(IdRota = @IdRota or @IdRota is null)
					and Excluido = 0
				group by
					IdRota,
					IdTransportadora
			) rotas_existentes on rotas.IdRota = rotas_existentes.IdRota and rotas.IdTransportadora = rotas_existentes.IdTransportadora

			--se a rota existe desde sempre apenas como planned não preciso alterar 
			left join (
				select
					distinct
					IdRota,
					IdTransportadora
				from
					(
						select 
							IdRota,
							IdTransportadora,
							count(1) over (partition by Idrota, IdTransportadora) Qtde,
							StatusRota
						from 
							tb_ml_rotas r with(nolock)
						where
							(DataReferencia >= @DataReferencia or @DataReferencia is null)
					and
					(IdRota = @IdRota or @IdRota is null)
						group by
							IdRota,
							IdTransportadora,
							StatusRota
					) r
				where
					StatusRota = 'planned'
					and qtde = 1
			) rotas_planejadas on rotas.IdRota = rotas_planejadas.IdRota and rotas.IdTransportadora = rotas_planejadas.IdTransportadora

			--se tiver rota duplicada como não excluida tb deve entrar para ser ajustada
			left join (
				select 
					IdRota, 
					IdTransportadora, 
					count(1) qtde 
				from 
					tb_ml_rotas with(nolock) 
				where 
					Excluido=0 
				group by 
					IdRota, 
					IdTransportadora 
				having 
					count(1) > 1
			) rotas_duplicadas  on rotas.IdRota = rotas_duplicadas.IdRota and rotas.IdTransportadora = rotas_duplicadas.IdTransportadora
		where
			rotas_planejadas.IdRota is null
			and (r.Excluido = 1 or rotas_duplicadas.IdRota is not null)
	
	
		-- volta as rotas e pacotes que estavam excluidos como ativo
		update
			rotas
		set
			rotas.Excluido = 0
		from
			tb_ml_rotas rotas
			join #rotas rotas_update on rotas.IdRota = rotas_update.IdRota 
									and rotas.IdTransportadora = rotas_update.IdTransportadora
									and rotas.DataReferencia = rotas_update.DataReferencia

		update
			pacotes
		set
			pacotes.Excluido = 0
		from
			tb_ml_pacotes pacotes
			join #rotas rotas_update on pacotes.IdRota = rotas_update.IdRota 
									and pacotes.IdTransportadora = rotas_update.IdTransportadora
									and pacotes.DataReferencia = rotas_update.DataReferencia
	

		-- altera as rotas e pacotes que para excluido em que a data não for a data de referencia da #rotas
		update
			rotas
		set
			rotas.Excluido = 1
		from
			tb_ml_rotas rotas
			join #rotas rotas_update on rotas.IdRota = rotas_update.IdRota 
									and rotas.IdTransportadora = rotas_update.IdTransportadora
									and rotas.DataReferencia <> rotas_update.DataReferencia

		update
			pacotes
		set
			pacotes.Excluido = 1
		from
			tb_ml_pacotes pacotes
			join #rotas rotas_update on pacotes.IdRota = rotas_update.IdRota 
									and pacotes.IdTransportadora = rotas_update.IdTransportadora
									and pacotes.DataReferencia <> rotas_update.DataReferencia

		-- altera as rotas e pacotes que tiveram 5 tentativas de reprocessamento histótica com 404 para excluído
		
		select distinct
				cast(substring(dec_ds_contexto,charindex('routes/',dec_ds_contexto,1) + 7,10 ) as int) as IdRota
		into #rotas_404
		from tb_dra_erros_coleta with(nolock)
		where dec_ds_tipo_coleta = 'ML_SC_ROUTE_HISTORY'
				and dec_ds_erro = 'Error: Request failed with status code 404'
				and dec_nr_tentativas =  5
				and (cast(dec_dt_referencia as date) = @DataReferencia or cast(dec_dh_escrita as date) = @DataReferencia)
				and (cast(substring(dec_ds_contexto,charindex('routes/',dec_ds_contexto,1) + 7,10 ) as int) = @IdRota or @IdRota is null)
		
		update
			rotas
		set
			rotas.Excluido = 1
		from
			tb_ml_rotas rotas
			inner join #rotas_404 Status404
			on rotas.IdRota = Status404.IdRota
		where rotas.PacotesEntregues = 0
			and (rotas.IdTransportadora <> 678279205 and StatusRota = 'Close') -- Solicitação da Transmaná para considerar as rotas com 0 entregas. Matheus 11/08



		update
			pacotes
		set
			pacotes.Excluido = 1
		from
			tb_ml_pacotes pacotes
			inner join #rotas_404 Status404
			on pacotes.IdRota = Status404.IdRota

		
		--Incluído em 19/02 por Saulo Barros para atualizar DataHoraFim das rotas que não tiverem essa informação
		--Incluído a partir das rotas de 2025
		update
			r
		set
			r.DataHoraFim = r2.DataHoraFim
		from
			tb_ml_rotas r
			join (
				select
					IdRota,
					IdTransportadora,
					max(DataHoraFim) DataHoraFim
				from
					tb_ml_rotas with(nolock)
				where
					DataHoraFim is not null
					and DataReferencia >= '2025-01-01'
				group by
					IdRota,
					IdTransportadora
			) r2 on r.IdRota = r2.IdRota and r.IdTransportadora = r2.IdTransportadora 
		where
			r.DataHoraFim is null
			and r.DataReferencia >= '2025-01-01'

	end
	
	
end
GO
