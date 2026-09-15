-- ============================================================
-- BASELINE: dbo.UspControllerAjustesDA
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspControllerAjustesDA]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspControllerAjustesDA]
as 
begin

	SET NOCOUNT ON;

	--Exclui rotas duplicadas mantendo apenas a data mais recente
	exec [UspMLExcluiRotasDuplicadas]

	--Atualiza Rotas em que não vieram o tipo de veiculo
	exec UspMLAtualizaTipoVeiculoRotas

	--Atualiza Rotas em que não vieram o nome do motorista
	exec UspMLAtualizaNomeMotoristaRotas

	--Atualiza Tipos de Veiculos
	exec UspMLAtualizaTipoVeiculo

	--Exclui pacotes em que a rota está como excluida
	exec UspMLExcluiPacoteComRotaExcluida

	--Inclui as rotas para reprocessar
	exec UspMLReprocessarRotas

	--Inclui os pacotes para reprocessar da shopee
	--exec UspSPEReprocessarPacotes
	exec UspSPEReprocessarPacotesV4

	--Atualiza tb_dra_cidades_geo
	exec UspMLAtualizaCidadesParaColeta

	--Atualiza cidades dos pacotes
	exec UspMLAtualizaCidadesPacotes

	--Atualiza cidades das rotas
	exec UspMLAtualizaCidadesRotas

	

end
GO
