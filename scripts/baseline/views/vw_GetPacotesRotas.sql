-- ============================================================
-- BASELINE: dbo.vw_GetPacotesRotas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_GetPacotesRotas]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 create view [dbo].[vw_GetPacotesRotas] as

select cast(rotas.IdRota as varchar(50)) as IdRota,
        pacotes.DataHoraEntrega as DataHora,
        pacotes.LatitudeEnderecoParada as Latitude,
        pacotes.LongitudeEnderecoParada as Longitude,
        pacotes.SequenciaParada
    from tb_ml_rotas as rotas with(nolock)
      join tb_ml_pacotes as pacotes with(nolock)
      on rotas.IdRota = pacotes.IdRota
      and rotas.IdTransportadora = pacotes.IdTransportadora
      and rotas.DataReferencia = pacotes.DataReferencia
      and pacotes.SequenciaParada is not null 
    where  1=1
    --   rotas.IdRota = ${idRota}
      and rotas.Excluido = 0
    group by
        rotas.IdRota,
        pacotes.DataHoraEntrega,
        pacotes.LatitudeEnderecoParada,
        pacotes.LongitudeEnderecoParada,
        pacotes.SequenciaParada
    --order by 5

union all

select
	rotas.codigorota,
	pacotes.DataHoraEntrega as DataHora,
	pacotes.Latitude	,
	pacotes.Longitude,
	row_number() over(partition by rotas.codigorota, cast(pacotes.DataHoraEntrega as date ) order by pacotes.DataHoraEntrega  ) as SequenciaParada

from vw_rotas_spe_v4 as rotas
join vw_pacotes_spe_v4 as pacotes
on rotas.codigorota = pacotes.codigorota
and rotas.DataReferencia = pacotes.DataReferencia

GO
