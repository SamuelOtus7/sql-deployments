-- ============================================================
-- BASELINE: dbo.UspMLAtualizaKmLogistics
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaKmLogistics]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--================================================
-- Autor: Saulo Barros
-- Data de Criação: 11/08/2025
-- Descrição: Atualiza Km Logistics
--==================================================
CREATE PROCEDURE [dbo].[UspMLAtualizaKmLogistics]
as
begin


	drop table if exists #coleta_km
	select 
		dac_cd_coleta
		,cast(dac_ds_contexto as int) as IdRota
		,cast(dac_cd_transportadora as int) IdTransportadora
		,cast(replace(replace(dac_ds_contexto_json,'{"data":',''),'}','') as decimal(18,4)) Km
		into #coleta_km
	from 
		db_Irisys_Json.dbo.tb_dra_coleta with(nolock)
	where 
		dac_ds_tipo_coleta = 'REPROCESSAR_KM'
		and dac_in_processado = 0
	

	update
		r
	set
		KmLogistics = c.Km
	from
		tb_ml_rotas r
		join #coleta_km c on r.IdRota = c.IdRota
							and r.IdTransportadora = c.IdTransportadora
	where
		c.Km > 0


	update
		c
	set
		dac_in_processado = 1
		,dac_dh_processamento = getdate()
	from
		db_Irisys_Json.dbo.tb_dra_coleta c
		join #coleta_km c2 on c.dac_cd_coleta = c2.dac_cd_coleta

end
GO
