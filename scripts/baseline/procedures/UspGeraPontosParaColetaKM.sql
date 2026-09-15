-- ============================================================
-- BASELINE: dbo.UspGeraPontosParaColetaKM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraPontosParaColetaKM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraPontosParaColetaKM]
as 
begin

	SET NOCOUNT ON;

	--Integra dados gps da Azure para tb_registro_gps
	exec UspAtualizaRegistroGPS

	--Atualiza Km e Mapa
	exec UspMLAtualizaKmRotas

	--Atualiza Km e Mapa
	exec UspSPEAtualizaKmRotas

	--Atualiza cidades dos pacotes
	exec UspMLAtualizaCidadesPacotes

	--Atualiza cidades das rotas
	exec UspMLAtualizaCidadesRotas

	--Gera latitude e longitude para coletar km
	exec UspGeraDistributedPoints

	--Gera latitude e longitude para coletar app
	exec UspGeraDistributedPointsAPP

	--Gera latitude e longitude para coletar geo
	exec UspGeraDistributedPointsGEO

	--Gera latitude e longitude para coletar shopee
	exec UspGeraDistributedPointsShopee

	

end
GO
