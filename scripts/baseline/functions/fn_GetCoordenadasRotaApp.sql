-- ============================================================
-- BASELINE: dbo.fn_GetCoordenadasRotaApp
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_GetCoordenadasRotaApp]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_GetCoordenadasRotaApp]

(
	@IdRota int,
	@Mod int = 1
)
returns table
as return

select top 10000 *
from (
		select left(cast(rgp_dc_latitude  as varchar(100)),8) + ',' + left(cast(rgp_dc_longitude as varchar(100)),8) as teste,
			   ROW_NUMBER() over(order by rgp_dh_data_hora) as linha
		from db_DriveAnalytics..tb_registro_gps as gps
			join tb_usuario users on gps.rgp_cd_usuario = users.usr_cd_usuario
			join tb_ml_rotas as rotas on cast(gps.rgp_dh_data_hora as date) = rotas.DataReferencia
			and rotas.NomeMotorista = users.usr_nm_usuario
		where rotas.IdRota = @IdRota
	 ) as base
where linha % @Mod = 0
order by linha
GO
