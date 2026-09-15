-- ============================================================
-- BASELINE: dbo.UspCargaNoturna
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspCargaNoturna]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspCargaNoturna]
as 


--esta procedure pega os carregamentos noturnos dos motoristas que farão as entregas no dia seguinte 

declare @data date = cast(getdate() as date)

drop table if exists #pacotes_antigos
select 
    a.CodigoRota
    ,a.CodigoPacote
    ,a.IdTransportadora
    ,@data DataReferencia
    ,a.DataHoraColeta
    ,a.DataHoraEntrega
    ,a.StatusEntrega
    ,a.SubStatus
    ,a.IdMotorista
    ,a.RecebidoPor
    ,a.CEP
    ,a.Latitude
    ,a.Longitude
    ,a.URLImagem
    ,a.DataAtualizacao
    ,a.DataAtualizacaoDetalhe
    ,a.Excluido
    ,a.SubStatusAnterior
    ,a.StatusPacote

into #pacotes_antigos 

from
    (
        select * from [tb_spe_pacotes_v4] where  DataReferencia = DATEADD(dd,-1,@data) and StatusEntrega = 'Assigned' and excluido = 0
    ) as a
left join
        (
            select codigopacote from [tb_spe_pacotes_v4] where DataReferencia = @data and Excluido = 0
        ) as B

on a.CodigoPacote = b.CodigoPacote

where b.CodigoPacote is null


update a
set a.excluido = 1

from  tb_spe_pacotes_v4 as a
inner join  #pacotes_antigos as B
on a.CodigoPacote = b.CodigoPacote
and a.CodigoRota = b.CodigoRota
and a.IdTransportadora = b.IdTransportadora
where a.Excluido = 0


insert into tb_spe_pacotes_v4 
select
 	a.CodigoRota
,	a.CodigoPacote
,	a.IdTransportadora
,	a.DataReferencia
,	a.DataHoraColeta
,	a.DataHoraEntrega
,	a.StatusEntrega
,	a.SubStatus
,	a.IdMotorista
,	a.RecebidoPor
,	a.CEP
,	a.Latitude
,	a.Longitude
,	a.URLImagem
,	a.DataAtualizacao
,	a.DataAtualizacaoDetalhe
,	a.Excluido
,	a.SubStatusAnterior
,	a.StatusPacote

from #pacotes_antigos as a
left join tb_spe_pacotes_v4 as b
on  a.CodigoPacote = b.CodigoPacote
and a.CodigoRota = b.CodigoRota
and a.IdTransportadora = b.IdTransportadora
and a.DataReferencia = b.DataReferencia

where b.DataReferencia is null



GO
