-- ============================================================
-- BASELINE: dbo.UspAtualizaRegistroGPS
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaRegistroGPS]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspAtualizaRegistroGPS] 
as
begin
	
	SET NOCOUNT ON
	

	insert into tb_registro_gps (rgp_dh_data_hora, rgp_cd_usuario, rgp_dc_latitude, rgp_dc_longitude, rgp_ds_uuid, rgp_in_coordenada_fantasma)
	select distinct
		a.DataHoraColeta,
		a.CodigoUsuario,
		a.Latitude,
		a.Longitude,
		a.uuid,
		0 rgp_in_coordenada_fantasma
	from
		tb_azure_registroGPS a
		left join tb_registro_gps r on a.DataHoraColeta = r.rgp_dh_data_hora and a.CodigoUsuario = r.rgp_cd_usuario
		inner join tb_usuario as usu on a.CodigoUsuario = usu.usr_cd_usuario
	where
		r.rgp_cd_registro_gps is null
	order by
		CodigoUsuario, DataHoraColeta
 

end

GO
