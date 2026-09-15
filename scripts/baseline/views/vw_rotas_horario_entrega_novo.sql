-- ============================================================
-- BASELINE: dbo.vw_rotas_horario_entrega_novo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_horario_entrega_novo]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_rotas_horario_entrega_novo] as 

select 
      cast(IdRota as varchar(50)) as IdRota,
      dateadd(hour,-3,gps.rgp_dh_data_hora)  as DataHora,
      rgp_dc_latitude as Latitude,
      rgp_dc_longitude as Longitude
      -- DataHoraInicio,
      -- UltimaDataHoraEntrega
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
			UsuarioDA

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
			where datareferencia >= cast(getdate()-120 as date)--cast(getdate()-1 as date)
			and excluido = 0
            -- and StatusRota = 'close'
		) as rotas 
        inner join (
            select IdRota,
                    DataReferencia,
                    max(DataHoraEntrega) UltimaDataHoraEntrega,
                    min(DataHoraEntrega) PrimeiraDataHoraEntrega
            from tb_ml_pacotes with(nolock)
			where datareferencia >= cast(getdate()-120 as date)
			and Excluido = 0
            --where IdRota = 128079330
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
and rgp_in_coordenada_fantasma = 0

where 1=1
and rgp_dc_latitude not in ('-22.26789341'

)
and rgp_ds_uuid not in('917f472df5c09146', 'ea6183e569192741','6a598b553af04491','93d9703a58eb1c35','ab8f1791477b5fe3'
,'64728ece3887fd62'
,'03a48a4e982581ed'
,'15dbb808c46417bc'
,'598ec8bf89c4e1e6'
,'a5099d9f5a2317d9'
,'b08adb78ae31ca0a'
,'94fb447233a43f18'
,'64728ece3887fd62'
,'03a48a4e982581ed'
,'15dbb808c46417bc'
,'94987d477c9d73e0'
,'b377d7af5a7c10af'
,'eae462d71d477005'
,'73778874895183ac'
,'f2c2e25c5d321f3f'
,'41b6d2b8adf431fb'


)

and dateadd(hour,-3,gps.rgp_dh_data_hora) between DataHoraInicio and UltimaDataHoraEntrega


union all



select 
      codigorota,
      dateadd(hour,-3,gps.rgp_dh_data_hora)  as DataHora,
      rgp_dc_latitude as Latitude,
      rgp_dc_longitude as Longitude
      -- DataHoraInicio,
      -- UltimaDataHoraEntrega
from (
    select distinct
            rotas.codigorota,
            NomeMotorista,
            rotas.DataReferencia,
            UltimaDataHoraEntrega,
            PrimeiraDataHoraEntrega,
            DataHoraInicio,
			UsuarioIrisys

    from (
			select 
			datareferencia
			,idtransportadora
			,codigorota 
			,UsuarioIrisys
			,Motorista as NomeMotorista
			,DataHoraInicio
			--,Excluido

			from vw_rotas_spe_v4 with(nolock)
			where datareferencia >= cast(getdate()-120 as date)
			
            -- and StatusRota = 'close'
		) as rotas 
        inner join (
            select codigorota,
                    DataReferencia,
                    max(DataHoraEntrega) UltimaDataHoraEntrega,
                    min(DataHoraEntrega) PrimeiraDataHoraEntrega
            from vw_pacotes_spe_v4 with(nolock)
			where datareferencia >= cast(getdate()-120 as date)
			and DataHoraEntrega is not null
			--and Excluido = 0
            --where IdRota = 128079330
            group by codigorota,
                    DataReferencia
        ) as pacotes
        on rotas.codigorota = pacotes.codigorota
		and rotas.DataReferencia = pacotes.DataReferencia

    --where rotas.Excluido = 0
) as rotas
--join tb_usuario as users with(nolock)
--on rotas.NomeMotorista = users.usr_nm_usuario

join tb_registro_gps as gps with(nolock)
on rotas.UsuarioIrisys = gps.rgp_cd_usuario
and rotas.DataReferencia = cast(dateadd(hour,-3,gps.rgp_dh_data_hora) as date)

where 1=1

and dateadd(hour,-3,gps.rgp_dh_data_hora) between DataHoraInicio and UltimaDataHoraEntrega

GO
