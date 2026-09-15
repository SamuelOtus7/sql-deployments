-- ============================================================
-- BASELINE: dbo.UspMLGetCorrigeRotasExcluidas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLGetCorrigeRotasExcluidas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLGetCorrigeRotasExcluidas] 
 as

declare @DataReferencia date = cast(getdate() as date)


	drop table if exists #rotas_exclusao
	select
		r.IdRota,
		r.DataReferencia,
		r.IdTransportadora
		into #rotas_exclusao
	from
		tb_ml_rotas r with(nolock)
		--left join #rotas as i on r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora
	where 1=1
		--i.IdRota is null
		and r.DataReferencia = @DataReferencia
		--and r.ServiceCenter = @ServiceCenter
		--and r.IdTransportadora = @Transportadora
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
			--left join #rotas as i on r.IdRota = i.IdRota and r.DataReferencia = i.DataReferencia and r.IdTransportadora = i.IdTransportadora
			join tb_ml_rotas r2 on r.IdRota = r2.IdRota and dateadd(day,-1,r.DataReferencia) = r2.DataReferencia and r.IdTransportadora = r2.IdTransportadora
		where 1=1
			--i.IdRota is null
			and r.DataReferencia = @DataReferencia
			--and r.ServiceCenter = @ServiceCenter
			--and r.IdTransportadora = @Transportadora
			and r.PacotesEntregues <> 0
			and r2.Excluido = 1


		drop table if exists #verifica_rotas_excluidas
		select
			*
			into #verifica_rotas_excluidas
		from
			(
				select IdRota from #rotas_exclusao
				union
				select IdRota from #voltar_rota_excluida
				union
				select IdRotaVoltar from #voltar_rota_excluida
				union
				select 
					IdRota
				from
					(
					select
						IdRota,
						IdTransportadora, 
						count(1) qtde 
					from 
						tb_ml_rotas with(nolock)
					where 
						Excluido=0 
					group by 
						IdRota, IdTransportadora 
					having 
						count(1) > 1
					) d
			) t

while exists (select 1 from #verifica_rotas_excluidas)
begin

	declare @IdRotaVerificar int = (select top 1 IdRota from #verifica_rotas_excluidas)
	exec [UspMLCorrigeRotasExcluidas] null, @IdRotaVerificar
	delete #verifica_rotas_excluidas where IdRota=@IdRotaVerificar

end
GO
