-- ============================================================
-- BASELINE: dbo.UspGeraAtualizaCidadesDistanteDiaPacoteHistorico
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraAtualizaCidadesDistanteDiaPacoteHistorico]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraAtualizaCidadesDistanteDiaPacoteHistorico] as

begin

declare @datainicio date = cast(getdate()-1 as date)
declare @datafim date = cast(getdate()-1 as date)

    update
		p
	set
		Cidade = geo.dcg_ds_cidade
		from tb_ml_pacotes p

		left join tb_dra_cidades_geo as geo with(nolock)
	on p.LatitudeEnderecoParada = geo.dcg_nr_latitude
	and p.LongitudeEnderecoParada = geo.dcg_nr_longitude
		--join tb_dra_cidades_geo geo on p.LatitudeEnderecoParada + replicate('0', 13-len(p.LatitudeEnderecoParada))  = cast(geo.dcg_nr_latitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_latitude as varchar(15))))
											--	and p.LongitudeEnderecoParada + replicate('0', 13-len(p.LongitudeEnderecoParada)) = cast(geo.dcg_nr_longitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_longitude as varchar(15))))
	where
		Excluido = 0
		-- and DataReferencia = '2025-02-21'
		and DataReferencia between @datainicio and @datafim
        and p.cidadedistante = 1
    	and geo.dcg_ds_cidade is not null
		--and p.Cidade is null
		--and p.IdRota = 215782029

    
    
    update a 
	set
		a.CidadeDistante = b.Cidade
	
	from tb_ml_rotas as a
	inner join 
	(
		select 
            DataReferencia,
			IdRota,
			Cidade

		from
			(
				select 
                DataReferencia,
				idrota,
                cidade
				-- , row_number() over(partition by idrota order by distancia desc) ordem
				from tb_ml_pacotes nolock
                where cidadedistante = 1
                and cidade is not null
                and DataReferencia between @datainicio and @datafim
                and excluido = 0
			) as a
	) as b
	on a.idrota = b.idrota 
    and a.DataReferencia = b.datareferencia
    
	where a.excluido = 0;


end
GO
