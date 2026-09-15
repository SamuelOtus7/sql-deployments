-- ============================================================
-- BASELINE: dbo.UspFinanceiroLimpaDados
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinanceiroLimpaDados]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  procedure [dbo].[UspFinanceiroLimpaDados] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin

	SET NOCOUNT ON
	
	delete tb_fin_prefatura_upload where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	delete tb_fin_prefatura_fm_upload   where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	delete tb_fin_prefatura_mo_upload   where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena


end
GO
