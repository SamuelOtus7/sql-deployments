-- ============================================================
-- BASELINE: dbo.UspMLCorrigeRotasExcluidasV2
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLCorrigeRotasExcluidasV2]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLCorrigeRotasExcluidasV2]

as 
begin

	SET NOCOUNT ON;
		BEGIN TRY			 -- adicionando transação para garantir que não atualize para excluido = 0 e em caso de deadlock duplicar a rota -- Matheus 30/06/25
		BEGIN TRANSACTION;

	declare @DataReferencia date = cast(getdate() as date)
	
	drop table if exists #rotas_exclusao
	select
		r.IdRota,
		r.DataReferencia,
		r.IdTransportadora
		into #rotas_exclusao
	from
		tb_ml_rotas r with(nolock)
	where 1=1
		and r.DataReferencia = @DataReferencia
		and r.PacotesEntregues = 0

	drop table if exists #voltar_rota_excluida
	select
			r.IdRota,
			r.DataReferencia,
			r.IdTransportadora,
			r2.IdRota IdRotaVoltar,
			r2.DataReferencia DataReferenciaVoltar,
			r2.IdTransportadora IdTransportadoraVoltar

			into #voltar_rota_excluida

		from
			tb_ml_rotas  r with(nolock)
			join tb_ml_rotas r2 on r.IdRota = r2.IdRota and dateadd(day,-1,r.DataReferencia) = r2.DataReferencia and r.IdTransportadora = r2.IdTransportadora
		where 1=1
			and r.DataReferencia = @DataReferencia
			and r.PacotesEntregues <> 0
			and r2.Excluido = 1

		drop table if exists #verifica_rotas_excluidas
		select
			*
			into #verifica_rotas_excluidas
		from
			(
				select IdRota, DataReferencia from #rotas_exclusao
				union
				select IdRota ,DataReferencia from #voltar_rota_excluida
				union
				select IdRotaVoltar ,DataReferencia from #voltar_rota_excluida
				union
				select 
					IdRota,DataReferencia
				from
					(
					select
						IdRota,
						IdTransportadora, 
						DataReferencia,
						count(1) qtde 
					from 
						tb_ml_rotas with(nolock)
					where 
						Excluido=0 
					group by 
						IdRota, IdTransportadora ,DataReferencia
					having 
						count(1) > 1
					) d
			) t

--================================================================================================================================--

	if (select Count(1) 
	      from #verifica_rotas_excluidas) >= 1
	begin
		drop table if exists #rotas

		select distinct 		
			     rotas.IdRota,
			     rotas.IdTransportadora,
			   isnull(pacotes.DataReferencia,pacotes2.DataReferencia) DataReferencia,
			     rotas.Qtde QuantidadeRotas,
					 r.Excluido
		into #rotas
		from #verifica_rotas_excluidas vre
		join 
			(select 
					 r.IdRota,
					 IdTransportadora,
					 count(1) qtde
				from 
					tb_ml_rotas r with(nolock)
			   join #verifica_rotas_excluidas v											
				on r.IdRota = v.IdRota
				group by
					r.IdRota,
					IdTransportadora
				having
					count(1) > 1 
			) rotas
			on vre.IdRota = rotas.IdRota
			--considera a maior data de referencia em que teve algum pacote com a mesma data hora entrega
			left join (
				select
						r.IdRota,
						IdTransportadora,
						max(r.DataReferencia) DataReferencia
				from tb_ml_pacotes r with(nolock)
				join #verifica_rotas_excluidas v											
				  on r.IdRota = v.IdRota 
			   where r.DataReferencia = cast(DataHoraEntrega as date)
					-- Alterado em 19/03/2025 por Saulo BArros para incluir também not_delivered. Ao analisar algumas rotas no fechamento, deveria considerar a data de referencia em que houve pacote também não entregue, e não apenas entregue
					and StatusEntrega in ('delivered', 'not_delivered')
					and SubStatus <> 'transferred' -- Alterado por Matheus 24/06 com orientação do Saulo para não considerar transferidos
					and IdTransportadora <> 643493085
				group by
					r.IdRota,
					IdTransportadora
				) pacotes on rotas.IdRota = pacotes.IdRota
						and rotas.IdTransportadora = pacotes.IdTransportadora
						--- Bloco adicionado para a FCA considerar a última data de entrega
				left join (
				select
						r.IdRota,
						IdTransportadora,
						max(cast(r.DataHoraEntrega as date)) DataReferencia
				from tb_ml_pacotes r with(nolock)
				join #verifica_rotas_excluidas v											
				  on r.IdRota = v.IdRota 
			   where r.DataReferencia = cast(DataHoraEntrega as date)
					-- Alterado em 19/03/2025 por Saulo BArros para incluir também not_delivered. Ao analisar algumas rotas no fechamento, deveria considerar a data de referencia em que houve pacote também não entregue, e não apenas entregue
					and StatusEntrega = 'delivered'
					and SubStatus <> 'transferred' -- Alterado por Matheus 24/06 com orientação do Saulo para não considerar transferidos
					and IdTransportadora = 643493085
				group by
					r.IdRota,
					IdTransportadora
				) pacotes2 on rotas.IdRota = pacotes2.IdRota
						and rotas.IdTransportadora = pacotes2.IdTransportadora
			join tb_ml_rotas r with(nolock) on r.IdRota = rotas.IdRota and r.IdTransportadora = rotas.IdTransportadora and( r.DataReferencia = pacotes.DataReferencia or r.DataReferencia = pacotes2.DataReferencia)
	
			-- precisa ter pelo menos alguma rota que não foi excluida
			join (
				select 
					r.IdRota,
					IdTransportadora,
					count(1) qtde
				from 
					tb_ml_rotas r with(nolock)
					join #verifica_rotas_excluidas v
					on r.IdRota = v.IdRota 
					where Excluido = 0
				group by
					r.IdRota,
					IdTransportadora
			) rotas_existentes on rotas.IdRota = rotas_existentes.IdRota and rotas.IdTransportadora = rotas_existentes.IdTransportadora

			--se a rota existe desde sempre apenas como planned não preciso alterar 
			left join (
				select
					distinct
					r.IdRota,
					IdTransportadora
				from
					(
						select 
							r.IdRota,
							IdTransportadora,
							count(1) over (partition by r.Idrota, IdTransportadora) Qtde,
							StatusRota
							from 
							tb_ml_rotas r with(nolock)
							join #verifica_rotas_excluidas v
							on r.idrota = v.IdRota
						group by
							r.IdRota,
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

		
--========================================================================================================

--=========================================================================================================

--================================================================================================================
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
	
--=============================================================================================================================
		

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
			pacotes		-----update já existia antes da alteração, apenas acrescentado para desconsiderar a FCA -- Matheus 24/06
		set
			pacotes.Excluido = 1
		from
			tb_ml_pacotes pacotes
			join #rotas rotas_update on pacotes.IdRota = rotas_update.IdRota 
									and pacotes.IdTransportadora = rotas_update.IdTransportadora
									and pacotes.DataReferencia <> rotas_update.DataReferencia
									and pacotes.IdTransportadora <> 643493085

					
		update
			pacotes				-----update incluído apenas para a FCA para fazer update apenas em casos que não são de not_delivered -- Matheus 24/06
		set
			pacotes.Excluido = 1
		from
			tb_ml_pacotes pacotes
			join #rotas rotas_update on pacotes.IdRota = rotas_update.IdRota 
									and pacotes.IdTransportadora = rotas_update.IdTransportadora
									and pacotes.DataReferencia <> rotas_update.DataReferencia
									and pacotes.IdTransportadora = 643493085
									and pacotes.StatusEntrega <> 'not_delivered'
								
		-- altera as rotas e pacotes que tiveram 5 tentativas de reprocessamento histótica com 404 para excluído
		
		select distinct
				cast(substring(dec_ds_contexto,charindex('routes/',dec_ds_contexto,1) + 7,10 ) as int) as IdRota
		into #rotas_404
		from tb_dra_erros_coleta a with(nolock)
		join #rotas r
		on cast(substring(a.dec_ds_contexto,charindex('routes/',a.dec_ds_contexto,1) + 7,10 ) as int) = r.IdRota
		where dec_ds_tipo_coleta = 'ML_SC_ROUTE_HISTORY'
				and dec_ds_erro = 'Error: Request failed with status code 404'
				and dec_nr_tentativas =  5
				and (cast(dec_dt_referencia as date) = @DataReferencia or cast(dec_dh_escrita as date) = @DataReferencia)
			--	and (cast(substring(dec_ds_contexto,charindex('routes/',dec_ds_contexto,1) + 7,10 ) as int) = @IdRota or @IdRota is null)
		

		update
			rotas
		set
			rotas.Excluido = 1
		from
			tb_ml_rotas rotas
			inner join #rotas_404 Status404
			on rotas.IdRota = Status404.IdRota
		where rotas.PacotesEntregues = 0

		update
			pacotes
		set
			pacotes.Excluido = 1
		from
			tb_ml_pacotes pacotes
			inner join #rotas_404 Status404
			on pacotes.IdRota = Status404.IdRota
--==================================================================================================================================================
	
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
	
	  COMMIT TRANSACTION;
END TRY
	BEGIN CATCH
	    IF @@TRANCOUNT > 0
	        ROLLBACK TRANSACTION;
	
	    DECLARE 
	        @ErrMsg NVARCHAR(4000),
	        @ErrSeverity INT,
	        @ErrState INT;
	
	    SELECT 
	        @ErrMsg = ERROR_MESSAGE(),
	        @ErrSeverity = ERROR_SEVERITY(),
	        @ErrState = ERROR_STATE();
	
	    RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
	END CATCH
	
end
GO
