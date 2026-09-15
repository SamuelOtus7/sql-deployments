-- ============================================================
-- BASELINE: dbo.UspAtualizaDadosAparelhos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaDadosAparelhos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspAtualizaDadosAparelhos] 
as
begin
	
	insert into tb_dados_aparelhos
	select distinct
		 a.PartitionKey
		,a.RowKey
		,a.Timestamp
		,a.DataHoraColeta
		,a.CodigoUsuario
		,a.cordova
		,a.isiOSAppOnMac
		,a.isVirtual
		,a.manufacturer
		,a.model
		,a.platform
		,a.sdkVersion
		,a.serial
		,a.uuid
		,a.version
		,a.versionApp
	from
		tb_azure_DadosAparelhos a
		left join tb_dados_aparelhos r on a.DataHoraColeta = r.DataHoraColeta and a.CodigoUsuario = r.CodigoUsuario
	where
		r.DataHoraColeta is null
	order by
		CodigoUsuario, DataHoraColeta
 

end

GO
