-- ============================================================
-- BASELINE: dbo.USPAtualizaUsouApp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USPAtualizaUsouApp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[USPAtualizaUsouApp]
as
declare @data date  = getdate()-14

update a
set 
UsouAPP = case when b.Total > 0 then 'Sim' else 'Não' end

from tb_ml_rotas as a with(nolock)
left join 
        (
            select 
                rgp_cd_usuario,
                cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date) as Data
                ,count(*) as Total
            from 
            tb_registro_gps as gps with(nolock)
            where cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date) >= @data
            group by rgp_cd_usuario,
                cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date)
        ) as b
on a.UsuarioDA = b.rgp_cd_usuario
and a.DataReferencia = b.Data

where a.Excluido = 0 
and UsouAPP is NULL
--and a.IdRota = 308108725
and StatusRota <> 'planned' 
and a.DataReferencia >= @data
GO
