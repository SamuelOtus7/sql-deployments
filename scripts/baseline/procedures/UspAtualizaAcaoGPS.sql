-- ============================================================
-- BASELINE: dbo.UspAtualizaAcaoGPS
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaAcaoGPS]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspAtualizaAcaoGPS] 
as
begin
	
	SET NOCOUNT ON
	

	insert into tb_acao_gps
	select distinct
		 a.DataHoraColeta
		,a.CodigoUsuario
		,a.acao
		,a.Latitude
		,a.Longitude
		,a.Duracao
		,a.Km
		,a.versionApp
		,a.uuid
		,a.[Timestamp]

	from
		tb_azure_acaoGPS a
		left join tb_acao_gps r on a.DataHoraColeta = r.agp_dh_data_hora and a.CodigoUsuario = r.agp_cd_usuario
		inner join tb_usuario as usu on a.CodigoUsuario = usu.usr_cd_usuario
	where
		r.agp_cd_acao_gps is null
	order by
		CodigoUsuario, DataHoraColeta
 

end

GO
