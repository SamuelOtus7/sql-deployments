-- ============================================================
-- BASELINE: dbo.vw_rotas_horario_entrega
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_horario_entrega]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from vw_rotas_horario_entrega_novo where idrota = '326810989'


CREATE  view [dbo].[vw_rotas_horario_entrega] as 

select 
      IdRota,
      dateadd(hour,-3,gps.rgp_dh_data_hora)  as DataHora,
      rgp_dc_latitude as Latitude,
      rgp_dc_longitude as Longitude
--     --   DataHoraInicio,
--       PrimeiraDataHoraEntrega,
--       UltimaDataHoraEntrega
 from (
    select distinct
            rotas.IdRota,
            NomeMotorista,
            rotas.DataReferencia,
            cast(case when svc.svc_cd_service_center is not null then svc.Latitude else svc2.Latitude end as decimal(18, 9)) LatitudeSVC,
            cast(case when svc.svc_cd_service_center is not null then svc.Longitude else svc2.Longitude end as decimal(18, 9)) LongitudeSVC,
            UltimaDataHoraEntrega,
            PrimeiraDataHoraEntrega,
            DataHoraInicio,
			UsuarioDA,
            rotas.idtransportadora

    from (
			select 
			datareferencia
			,idtransportadora
			,idrota
			,UsuarioDA
			,origemsaida
			,ServiceCenter
			--,Estado
			,NomeMotorista
			,DataHoraInicio
			,Excluido

			from tb_ml_rotas with(nolock)
			where datareferencia between cast(getdate()-120 as date) and cast(getdate() as date) --cast(getdate()-1 as date)
			and excluido = 0
            -- and StatusRota = 'close'
		) as rotas 
        inner join (
            select IdRota,
                    DataReferencia,
                    max(DataHoraEntrega) UltimaDataHoraEntrega,
                    min(DataHoraEntrega) PrimeiraDataHoraEntrega
            from tb_ml_pacotes with(nolock)
			where datareferencia between cast(getdate()-120 as date) and cast(getdate() as date) 
			and Excluido = 0
            -- and IdRota = 162147651
            group by IdRota,
                    DataReferencia
        ) as pacotes
        on rotas.IdRota = pacotes.IdRota
            and rotas.DataReferencia = pacotes.DataReferencia
        left join tb_ml_service_center_teste svc with(nolock) on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc.svc_cd_service_center and rotas.idtransportadora = svc.idtransportadora
        left join tb_ml_service_center_teste svc2 with(nolock) on rotas.ServiceCenter = svc2.svc_cd_service_center and rotas.idtransportadora = svc2.idtransportadora
    where rotas.Excluido = 0
) as rotas
--join tb_usuario as users with(nolock)
--on rotas.NomeMotorista = users.usr_nm_usuario

join tb_registro_gps as gps with(nolock)
on rotas.UsuarioDA = gps.rgp_cd_usuario
and rotas.DataReferencia = cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date)

where 1=1
and dateadd(hour,-3,gps.rgp_dh_data_hora) between PrimeiraDataHoraEntrega and UltimaDataHoraEntrega
--and idrota  = 326810989
-- and (
-- dateadd(hour,-3,gps.rgp_dh_data_hora) between PrimeiraDataHoraEntrega and UltimaDataHoraEntrega
-- or 
-- CAST(dateadd(hour,-3,gps.rgp_dh_data_hora) as DATE) = '2024-07-30' AND rotas.IdTransportadora = 2087146923 
-- )
--and idrota = 162147651
--order by rgp_dh_data_hora

-- union ALL

-- select 
-- IdRota,
-- dateadd(hour,-3,gps.rgp_dh_data_hora)  as DataHora,
-- rgp_dc_latitude as Latitude,
-- rgp_dc_longitude as Longitude

-- from vw_rotas_motoristas as rotas

-- join tb_registro_gps as gps with(nolock)
-- on rotas.UsuarioDA = gps.rgp_cd_usuario
-- and rotas.data = cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date)

-- where data = '2024-03-26'
-- --and KmApp > 0.00000
-- and IdTransportadora = 2087146923
-- and FaixaPrimeiroUltimoPacote = 'Não'
-- and UsouAPP = 'Sim'
-- and idrota = 

GO
