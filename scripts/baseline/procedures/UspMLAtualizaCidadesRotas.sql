-- ============================================================
-- BASELINE: dbo.UspMLAtualizaCidadesRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaCidadesRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLAtualizaCidadesRotas]
as
begin

	select
		r.IdRota,
		r.DataReferencia,
		r.IdTransportadora,
		p.Cidade,
		count(1) QtdePacote
		into #base
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_pacotes p with(nolock) on r.IdRota = p.IdRota and r.DataReferencia = p.DataReferencia and r.IdTransportadora = p.IdTransportadora and p.Excluido = 0 and p.Cidade is not null
		and StatusEntrega in ('delivered', 'not_delivered')
		and isnull(SubStatus,'') not in ('transferred','unvisited_address','cancelled','missing','return')
	where
		r.Excluido = 0
		and r.IdTransportadora <>  2087146923
		and r.DataReferencia >= '2023-05-01'
		and r.DataReferencia < cast(getdate() as date)
		and r.Cidades is null
	group by
		r.IdRota,
		r.DataReferencia,
		r.IdTransportadora,
		p.Cidade
		
		
	select 
		IdRota,
		DataReferencia,
		IdTransportadora,
		Cidade = STUFF((
			SELECT 
				N'' ,', ' + Cidade 
			FROM 
				#base b1
			WHERE 
				b.IdRota = b1.IdRota 
				and b.DataReferencia = b1.DataReferencia 
				and b.IdTransportadora = b1.IdTransportadora
			ORDER BY 
				Cidade
			FOR XML PATH(''), TYPE
		).value(N'.[1]', N'nvarchar(max)'), 1, 2, N''
		)
		into #cidades
	from 
		#base b
	group by 
		IdRota, 
		DataReferencia, 
		IdTransportadora

		
	select 
		distinct
		IdRota,
		DataReferencia,
		IdTransportadora,
		(select top 1 Cidade from #base b2 where b.IdRota = b2.IdRota and b.DataReferencia = b2.DataReferencia and b.IdTransportadora = b2.IdTransportadora order by QtdePacote desc, Cidade) Cidade
		into #principal_cidade
	from 
		#base b


	update
		r
	set
		Cidades = Cidade
	from
		tb_ml_rotas r
		join #cidades c on r.IdRota = c.IdRota and r.DataReferencia = c.DataReferencia and r.IdTransportadora = c.IdTransportadora
	where
		r.Excluido = 0

	update
		r
	set
		CidadeReferencia = Cidade
	from
		tb_ml_rotas r
		join #principal_cidade c on r.IdRota = c.IdRota and r.DataReferencia = c.DataReferencia and r.IdTransportadora = c.IdTransportadora
	where
		r.Excluido = 0;

		
	--exec UspGeraColetaCidadesDistante


end
GO
