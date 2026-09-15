-- ============================================================
-- BASELINE: dbo.UspMLAtualizaCidadesPacotes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaCidadesPacotes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLAtualizaCidadesPacotes]
as
begin

declare @dataini date = cast(getdate()-1 as date)
declare @datafim date = cast(getdate() as date)

	update
		p
	set
		Cidade = geo.dcg_ds_cidade
	--	Cidade_distrito = dcg_ds_cidade_distrito
	from
		tb_ml_pacotes p
		join tb_dra_cidades_geo geo on p.LatitudeEnderecoParada + replicate('0', 13-len(p.LatitudeEnderecoParada))  = cast(geo.dcg_nr_latitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_latitude as varchar(15))))
												and p.LongitudeEnderecoParada + replicate('0', 13-len(p.LongitudeEnderecoParada)) = cast(geo.dcg_nr_longitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_longitude as varchar(15))))
	where
		Excluido = 0
		and DataReferencia >= @dataini
		and DataReferencia < @datafim
		and geo.dcg_ds_cidade is not null
		and p.Cidade is null
	

    --shopee
	update
		p
	set
		Cidade = geo.dcg_ds_cidade
	from
		tb_spe_pacotes_v5 p
		join tb_dra_cidades_geo geo on p.Latitude + replicate('0', 13-len(p.Latitude))  = cast(geo.dcg_nr_latitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_latitude as varchar(15))))
												and p.Longitude + replicate('0', 13-len(p.Longitude)) = cast(geo.dcg_nr_longitude as varchar(15)) + replicate('0', 13-len(cast(geo.dcg_nr_longitude as varchar(15))))
	where
		Excluido = 0
		and DataReferencia >= @dataini
		and DataReferencia < @datafim
		and geo.dcg_ds_cidade is not null
		and p.Cidade is null

end
GO
