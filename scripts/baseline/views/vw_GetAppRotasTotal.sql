-- ============================================================
-- BASELINE: dbo.vw_GetAppRotasTotal
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_GetAppRotasTotal]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_GetAppRotasTotal] as 



 select 
	cast(IdRota as varchar(50)) as IdRota ,
    rgp_dh_data_hora as DataHora,
    rgp_dc_latitude as Latitude,
    rgp_dc_longitude as Longitude

  from (
     select distinct
            rotas.IdRota,
            NomeMotorista,
            UsuarioDA,
            rotas.DataReferencia,
            cast(case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end as decimal(18, 9)) LatitudeSVC,
            cast(case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end as decimal(18, 9)) LongitudeSVC,
            UltimaDataHoraEntrega,
            PrimeiraDataHoraEntrega
     from tb_ml_rotas as rotas with(nolock)
         inner join (
             select IdRota,
                    DataReferencia,
                    max(DataHoraEntrega) UltimaDataHoraEntrega,
                    min(DataHoraEntrega) PrimeiraDataHoraEntrega
             from tb_ml_pacotes with(nolock)
             --where IdRota = ${idRota}
             group by IdRota,
                      DataReferencia
         ) as pacotes
         on rotas.IdRota = pacotes.IdRota
            and rotas.DataReferencia = pacotes.DataReferencia
         left join tb_ml_service_center svc with(nolock) 
		 on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc.svc_cd_service_center 
		 and rotas.idtransportadora = svc.idtransportadora
         left join tb_ml_service_center svc2 with(nolock) on rotas.ServiceCenter = svc2.svc_cd_service_center and rotas.idtransportadora = svc2.idtransportadora

     where rotas.Excluido = 0
  ) as rotas
  join tb_usuario as users with(nolock)
  on rotas.usuarioda = users.usr_cd_usuario
  join tb_registro_gps as gps with(nolock)
  on users.usr_cd_usuario = gps.rgp_cd_usuario
  and rotas.DataReferencia = cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date)

   
  union all

 
 select 
	codigorota as IdRota,
    rgp_dh_data_hora as DataHora,
    rgp_dc_latitude as Latitude,
    rgp_dc_longitude as Longitude
 
from vw_rotas_spe_v4 as rotas

inner join tb_spe_station as b
on rotas.idstation = b.idstation

join tb_registro_gps as gps with(nolock)
on rotas.UsuarioIrisys = gps.rgp_cd_usuario
and rotas.DataReferencia = cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date)


GO
