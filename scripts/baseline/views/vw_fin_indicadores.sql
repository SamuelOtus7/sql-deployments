-- ============================================================
-- BASELINE: dbo.vw_fin_indicadores
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_indicadores]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_fin_indicadores]
as
select
	prefatura.fid_cd_transportadora,
	prefatura.fid_nr_ano,
	prefatura.fid_nr_mes,
	prefatura.fid_nr_quinzena,
	prefatura.fid_nm_indicador,
	prefatura.fid_vl_indicador PreFatura,
	faturamento.fid_vl_indicador DriveAnalytics,
	faturamento.fid_vl_indicador - prefatura.fid_vl_indicador Delta,
	(faturamento.fid_vl_indicador - prefatura.fid_vl_indicador)
		/ nullif(prefatura.fid_vl_indicador,0) PercentualDelta,
	fid_nr_ordem
from
	(
		select 
			fid_cd_transportadora,
			fid_nr_ano,
			fid_nr_mes,
			fid_nr_quinzena,
			fid_nm_indicador,
			fid_vl_indicador,
			fid_nr_ordem
		from	
			tb_fin_indicadores
		where
			fid_nm_etapa = 'Prefatura'
	) prefatura
	join 
	(
		select 
			fid_cd_transportadora,
			fid_nr_ano,
			fid_nr_mes,
			fid_nr_quinzena,
			replace(replace(fid_nm_indicador,'Rotas Processadas','Quantidade de Rotas'),'Valor Drive Analytics', 'Valor Total') fid_nm_indicador,
			fid_vl_indicador
		from	
			tb_fin_indicadores
		where
			fid_nm_etapa = 'Faturamento'
			and fid_nm_indicador in ('Rotas Processadas', 'Quantidade de Veiculos', 'Quantidade de Motoristas', 'Valor Drive Analytics')
	) faturamento on prefatura.fid_cd_transportadora = faturamento.fid_cd_transportadora
				and	prefatura.fid_nr_ano = faturamento.fid_nr_ano
				and prefatura.fid_nr_mes = faturamento.fid_nr_mes
				and prefatura.fid_nr_quinzena = faturamento.fid_nr_quinzena
				and prefatura.fid_nm_indicador = faturamento.fid_nm_indicador
GO
